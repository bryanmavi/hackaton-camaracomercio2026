-- Hito 1 · Migración 10: funciones de escritura y administración (SECURITY DEFINER, search_path vacío).
-- Cada función verifica permiso, alcance y MFA por sí misma: ningún rol de API tiene INSERT/UPDATE/DELETE directo.
-- es_simulado: las cuentas de demostración (idn.perfiles.es_simulado) marcan como simulado todo lo que escriben.

-- ───────────── Recomendar (no decide) ─────────────
create function api.registrar_recomendacion(
  p_amenaza         text,
  p_personas        integer,
  p_origen_espacio  text,
  p_ambito          text,
  p_version_reglas  text,
  p_candidatos      jsonb,
  p_resumen_cribado jsonb,
  p_advertencias    text[] default '{}',
  p_simulado        boolean default true   -- el escenario de personas es una simulación
) returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid;
begin
  perform idn.exigir('recomendacion.crear');
  if jsonb_typeof(p_candidatos) is distinct from 'array' then
    raise exception 'p_candidatos debe ser un arreglo.' using errcode = 'invalid_parameter_value';
  end if;
  if exists (
    select 1 from jsonb_array_elements(p_candidatos) c
    where jsonb_typeof(c) <> 'object'
       or not exists (select 1 from geo.espacios e where e.id = c ->> 'id')
       or not (select coalesce(array_agg(k), '{}') <@ array['id', 'distancia_m', 'razon'] from jsonb_object_keys(c) k)
  ) then
    raise exception 'Cada candidato debe ser un objeto con un espacio existente y solo las claves id, distancia_m y razon.'
      using errcode = 'invalid_parameter_value';
  end if;
  insert into ops.recomendaciones (creada_por, amenaza_codigo, personas_escenario, origen_espacio_id, ambito,
                                   version_reglas, candidatos, resumen_cribado, advertencias, es_simulado)
  values (auth.uid(), p_amenaza, p_personas, p_origen_espacio, p_ambito, p_version_reglas, p_candidatos,
          p_resumen_cribado, coalesce(p_advertencias, '{}'), p_simulado)
  returning id into v_id;
  return v_id;
end;
$$;

-- ───────────── Decidir (solo gestion_riesgo con aal2) ─────────────
-- Crea la decisión, las brechas (matriz de responsabilidades + requerimientos calculados por la app) y las
-- tareas del protocolo. `p_requerimientos`: [{"servicio":"toilets","requerido":8}, ...] calculado por planning.ts
-- (las reglas siguen en TypeScript, ADR-0007). El "existente" NUNCA lo da quien llama: sale de la última
-- medición verificada, o es NULL.
create function api.registrar_decision_activacion(
  p_recomendacion      uuid,
  p_espacio            text,
  p_amenaza            text,
  p_funcion            text,
  p_acto_tipo          text,
  p_acto_numero        text,
  p_acto_fecha         date,
  p_justificacion      text default null,
  p_personas_estimadas integer default null,
  p_requerimientos     jsonb default '[]'::jsonb,
  p_version_reglas     text default null
) returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_perfil idn.perfiles := idn.perfil_actual();
  v_rec_sim boolean := false;
  v_id uuid;
  v_serv record;
  v_req numeric;
begin
  perform idn.exigir('decision.activar');
  if jsonb_typeof(p_requerimientos) is distinct from 'array' then
    raise exception 'p_requerimientos debe ser un arreglo.' using errcode = 'invalid_parameter_value';
  end if;
  if exists (select 1 from jsonb_array_elements(p_requerimientos) q
             where jsonb_typeof(q) <> 'object' or not exists (select 1 from ref.servicios s where s.codigo = q ->> 'servicio')) then
    raise exception 'Cada requerimiento debe indicar un servicio existente de ref.servicios.' using errcode = 'invalid_parameter_value';
  end if;
  if p_recomendacion is not null then
    select r.es_simulado into v_rec_sim from ops.recomendaciones r where r.id = p_recomendacion;
    if not found then
      raise exception 'La recomendación % no existe.', p_recomendacion using errcode = 'foreign_key_violation';
    end if;
  end if;

  insert into ops.decisiones_activacion (recomendacion_id, espacio_id, amenaza_codigo, funcion, acto_tipo, acto_numero,
                                         acto_fecha, justificacion, decidida_por, cargo_id, personas_estimadas, es_simulado)
  values (p_recomendacion, p_espacio, p_amenaza, p_funcion, p_acto_tipo, p_acto_numero, p_acto_fecha,
          nullif(btrim(p_justificacion), ''), v_perfil.user_id, v_perfil.cargo_id, p_personas_estimadas,
          v_perfil.es_simulado or v_rec_sim)
  returning id into v_id;

  -- Brechas: servicios que lidera alguna entidad en esta función (matriz) + los que pida la app.
  for v_serv in
    select s.codigo, s.unidad, s.regla_texto, s.atributo_medicion, r.entidad_id
    from ref.servicios s
    left join ref.responsabilidades r
           on r.servicio_codigo = s.codigo and r.contexto = p_funcion and r.papel = 'lidera'
    where (s.amenaza_codigo is null or s.amenaza_codigo = p_amenaza)
      and (r.servicio_codigo is not null
           or exists (select 1 from jsonb_array_elements(p_requerimientos) q where q ->> 'servicio' = s.codigo))
  loop
    select (q ->> 'requerido')::numeric into v_req
      from jsonb_array_elements(p_requerimientos) q where q ->> 'servicio' = v_serv.codigo limit 1;
    insert into ops.brechas (decision_id, espacio_id, servicio_codigo, requerido, unidad, existente,
                             entidad_responsable_id, regla_texto, version_reglas, es_simulado)
    values (v_id, p_espacio, v_serv.codigo, v_req, v_serv.unidad,
            (select m.valor_num from geo.mediciones_vigentes m
              where m.espacio_id = p_espacio and m.atributo = v_serv.atributo_medicion),
            v_serv.entidad_id, v_serv.regla_texto, p_version_reglas, v_perfil.es_simulado or v_rec_sim);
  end loop;

  -- Tareas: pasos de las plantillas vigentes que aplican a la amenaza.
  insert into ops.tareas_protocolo (decision_id, paso_id, entidad_id, vence_en, es_simulado)
  select v_id, p.id, p.entidad_id,
         case when p.plazo_ref_horas is null then null else now() + make_interval(hours => p.plazo_ref_horas) end,
         v_perfil.es_simulado or v_rec_sim
  from ref.protocolo_plantillas t
  join ref.protocolo_pasos p on p.plantilla_id = t.id
  where t.vigente and (t.amenaza_codigo is null or t.amenaza_codigo = p_amenaza);

  return v_id;
end;
$$;

-- ───────────── Ejecutar: brechas y tareas ─────────────
create function api.actualizar_brecha(
  p_brecha    uuid,
  p_estado    text default null,
  p_existente numeric default null,
  p_nota      text default null
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_perfil idn.perfiles := idn.perfil_actual();
  v_b ops.brechas;
  v_dec_estado text;
  v_orden text[] := array['por_medir', 'en_revision', 'asignada', 'en_ejecucion', 'cerrada'];
  v_nuevo text;
begin
  perform idn.exigir('brecha.actualizar');
  select * into v_b from ops.brechas where id = p_brecha for update;
  if not found then raise exception 'La brecha no existe.' using errcode = 'no_data_found'; end if;
  if v_perfil.rol = 'entidad_responsable' and v_b.entidad_responsable_id is distinct from v_perfil.entidad_id then
    raise exception 'Esta brecha pertenece a otra entidad.' using errcode = 'insufficient_privilege';
  end if;
  select estado into v_dec_estado from ops.decisiones_activacion where id = v_b.decision_id;
  if v_dec_estado = 'cerrada' then
    raise exception 'La decisión ya está cerrada: sus brechas no se modifican.' using errcode = 'restrict_violation';
  end if;

  v_nuevo := coalesce(p_estado, v_b.estado);
  if array_position(v_orden, v_nuevo) is null then
    raise exception 'Estado de brecha no válido: %.', v_nuevo using errcode = 'invalid_parameter_value';
  end if;
  if array_position(v_orden, v_nuevo) < array_position(v_orden, v_b.estado) then
    raise exception 'Una brecha solo avanza de estado (% → % no permitido).', v_b.estado, v_nuevo
      using errcode = 'check_violation';
  end if;

  update ops.brechas
     set estado = v_nuevo, existente = coalesce(p_existente, existente)
   where id = p_brecha;
  insert into ops.seguimientos (brecha_id, estado_anterior, estado_nuevo, nota, registrado_por)
  values (p_brecha, v_b.estado, v_nuevo, p_nota, v_perfil.user_id);
end;
$$;

create function api.completar_tarea(
  p_tarea  bigint,
  p_estado text default 'completada',
  p_nota   text default null
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_perfil idn.perfiles := idn.perfil_actual();
  v_t ops.tareas_protocolo;
  v_dec_estado text;
begin
  perform idn.exigir('tarea.completar');
  if p_estado not in ('en_curso', 'completada', 'no_aplica') then
    raise exception 'Estado de tarea no válido: %.', p_estado using errcode = 'invalid_parameter_value';
  end if;
  select * into v_t from ops.tareas_protocolo where id = p_tarea for update;
  if not found then raise exception 'La tarea no existe.' using errcode = 'no_data_found'; end if;
  if v_perfil.rol = 'entidad_responsable' and v_t.entidad_id is distinct from v_perfil.entidad_id then
    raise exception 'Esta tarea pertenece a otra entidad.' using errcode = 'insufficient_privilege';
  end if;
  if v_t.estado in ('completada', 'no_aplica') then
    raise exception 'La tarea ya está en estado final (%).', v_t.estado using errcode = 'check_violation';
  end if;
  select estado into v_dec_estado from ops.decisiones_activacion where id = v_t.decision_id;
  if v_dec_estado = 'cerrada' then
    raise exception 'La decisión ya está cerrada.' using errcode = 'restrict_violation';
  end if;
  update ops.tareas_protocolo
     set estado = p_estado,
         nota = coalesce(p_nota, nota),
         completada_por = case when p_estado = 'completada' then v_perfil.user_id end,
         completada_en  = case when p_estado = 'completada' then now() end
   where id = p_tarea;
end;
$$;

-- ───────────── Red comunitaria: solo conteos agregados, solo su zona ─────────────
create function api.crear_reporte_comunitario(
  p_tipo                text,
  p_espacio_id          text default null,
  p_n_total             integer default null,
  p_n_0_5               integer default null,
  p_n_6_17              integer default null,
  p_n_18_59             integer default null,
  p_n_60_mas            integer default null,
  p_n_discapacidad      integer default null,
  p_n_animales_compania integer default null,
  p_estado_servicios    jsonb default null,
  p_observacion         text default null
) returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_perfil idn.perfiles := idn.perfil_actual();
  v_id uuid;
begin
  perform idn.exigir('reporte.crear');
  if v_perfil.organizacion_id is null then
    raise exception 'Tu perfil no pertenece a una organización comunitaria.' using errcode = 'insufficient_privilege';
  end if;
  if p_espacio_id is not null and not idn.espacio_en_mi_zona(p_espacio_id) then
    raise exception 'El espacio % está fuera de tu zona.', p_espacio_id using errcode = 'insufficient_privilege';
  end if;
  insert into ops.reportes_comunitarios (organizacion_id, espacio_id, tipo, n_total, n_0_5, n_6_17, n_18_59, n_60_mas,
                                         n_discapacidad, n_animales_compania, estado_servicios, observacion,
                                         creado_por, es_simulado)
  values (v_perfil.organizacion_id, p_espacio_id, p_tipo, p_n_total, p_n_0_5, p_n_6_17, p_n_18_59, p_n_60_mas,
          p_n_discapacidad, p_n_animales_compania, p_estado_servicios, nullif(btrim(p_observacion), ''),
          v_perfil.user_id, v_perfil.es_simulado)
  returning id into v_id;
  return v_id;
end;
$$;

-- ───────────── Mediciones: declarar y validar (cuatro ojos) ─────────────
create function api.registrar_medicion(
  p_espacio_id    text,
  p_atributo      text,
  p_fuente_texto  text,
  p_valor_num     numeric default null,
  p_valor_bool    boolean default null,
  p_valor_texto   text default null,
  p_valor_fecha   date default null,
  p_unidad        text default null,
  p_evidencia_ref text default null
) returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_perfil idn.perfiles := idn.perfil_actual();
  v_id bigint;
begin
  perform idn.exigir('medicion.declarar');
  if v_perfil.rol = 'comunitario' and not idn.espacio_en_mi_zona(p_espacio_id) then
    raise exception 'El espacio % está fuera de tu zona.', p_espacio_id using errcode = 'insufficient_privilege';
  end if;
  insert into geo.mediciones_espacio (espacio_id, atributo, valor_num, valor_bool, valor_texto, valor_fecha, unidad,
                                      estado, fuente_texto, evidencia_ref, reportado_por, es_simulado)
  values (p_espacio_id, p_atributo, p_valor_num, p_valor_bool, p_valor_texto, p_valor_fecha, p_unidad,
          'declarado', p_fuente_texto, p_evidencia_ref, v_perfil.user_id, v_perfil.es_simulado)
  returning id into v_id;
  return v_id;
end;
$$;

create function api.validar_medicion(
  p_id            bigint,
  p_aceptar       boolean,
  p_evidencia_ref text default null
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_perfil idn.perfiles := idn.perfil_actual();
  v_m geo.mediciones_espacio;
begin
  perform idn.exigir('medicion.validar');
  select * into v_m from geo.mediciones_espacio where id = p_id for update;
  if not found then raise exception 'La medición no existe.' using errcode = 'no_data_found'; end if;
  if v_m.estado <> 'declarado' then
    raise exception 'Solo se valida una medición declarada (está %).', v_m.estado using errcode = 'check_violation';
  end if;
  if v_m.reportado_por = v_perfil.user_id then
    raise exception 'Quien reporta una medición no puede validarla (cuatro ojos).' using errcode = 'insufficient_privilege';
  end if;
  -- entidad_responsable: solo los atributos de los servicios que lidera o valida
  if v_perfil.rol = 'entidad_responsable' and not exists (
       select 1
       from ref.servicios s join ref.responsabilidades r on r.servicio_codigo = s.codigo
       where s.atributo_medicion = v_m.atributo and r.entidad_id = v_perfil.entidad_id
         and r.papel in ('lidera', 'valida')) then
    raise exception 'Tu entidad no valida el atributo %.', v_m.atributo using errcode = 'insufficient_privilege';
  end if;
  if p_aceptar and coalesce(p_evidencia_ref, v_m.evidencia_ref) is null then
    raise exception 'Verificar una medición exige evidencia (acta o documento).' using errcode = 'check_violation';
  end if;
  update geo.mediciones_espacio
     set estado = case when p_aceptar then 'verificado' else 'rechazado' end,
         evidencia_ref = coalesce(p_evidencia_ref, evidencia_ref),
         validado_por = v_perfil.user_id,
         validado_en = now()
   where id = p_id;
end;
$$;

-- ───────────── Retorno ─────────────
create function api.cerrar_retorno(
  p_decision          uuid,
  p_checklist         jsonb,
  p_acta_ref          text,
  p_fecha_retorno     date,
  p_cargos_firmantes  bigint[] default '{}'
) returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_perfil idn.perfiles := idn.perfil_actual();
  v_dec ops.decisiones_activacion;
  v_id uuid;
begin
  perform idn.exigir('retorno.cerrar');
  select * into v_dec from ops.decisiones_activacion where id = p_decision for update;
  if not found then raise exception 'La decisión no existe.' using errcode = 'no_data_found'; end if;
  if v_dec.estado = 'cerrada' then
    raise exception 'La decisión ya está cerrada.' using errcode = 'check_violation';
  end if;
  if exists (select 1 from unnest(coalesce(p_cargos_firmantes, '{}')) f where not exists (select 1 from idn.cargos c where c.id = f)) then
    raise exception 'Hay cargos firmantes inexistentes.' using errcode = 'foreign_key_violation';
  end if;
  insert into ops.retornos (decision_id, checklist, acta_ref, fecha_retorno, cargos_firmantes, cerrado_por, es_simulado)
  values (p_decision, p_checklist, p_acta_ref, p_fecha_retorno, coalesce(p_cargos_firmantes, '{}'), v_perfil.user_id, v_dec.es_simulado)
  returning id into v_id;
  -- vigente → en_desactivacion → cerrada (el trigger no permite saltar etapas)
  if v_dec.estado = 'vigente' then
    update ops.decisiones_activacion set estado = 'en_desactivacion' where id = p_decision;
  end if;
  update ops.decisiones_activacion set estado = 'cerrada' where id = p_decision;
  return v_id;
end;
$$;

-- ───────────── Administración de cuentas (solo superusuario con aal2; todo queda auditado) ─────────────
create function idn.es_rol_con_mfa(p_rol idn.rol_app) returns boolean
language sql immutable set search_path = ''
as $$ select p_rol in ('superusuario', 'gestion_riesgo') $$;

create function api.cambiar_rol(
  p_user          uuid,
  p_rol           text,
  p_entidad       bigint default null,
  p_organizacion  bigint default null,
  p_zona_comunas  text[] default '{}',
  p_zona_barrios  text[] default '{}'
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_rol idn.rol_app := p_rol::idn.rol_app;
begin
  perform idn.exigir('usuarios.gestionar');
  if p_user = auth.uid() then
    raise exception 'No puedes cambiar tu propio rol.' using errcode = 'insufficient_privilege';
  end if;
  update idn.perfiles
     set rol = v_rol, entidad_id = p_entidad, organizacion_id = p_organizacion,
         zona_comunas = coalesce(p_zona_comunas, '{}'), zona_barrios = coalesce(p_zona_barrios, '{}'),
         mfa_requerido = idn.es_rol_con_mfa(v_rol)
   where user_id = p_user and activo;
  if not found then
    raise exception 'No existe un perfil activo para ese usuario.' using errcode = 'no_data_found';
  end if;
end;
$$;

create function api.suspender_usuario(p_user uuid, p_motivo text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform idn.exigir('usuarios.gestionar');
  if p_user = auth.uid() then
    raise exception 'No puedes suspenderte a ti mismo.' using errcode = 'insufficient_privilege';
  end if;
  update idn.perfiles set activo = false, desactivado_en = now() where user_id = p_user and activo;
  if not found then
    raise exception 'No existe un perfil activo para ese usuario.' using errcode = 'no_data_found';
  end if;
  update idn.asignaciones_cargo
     set hasta = current_date, motivo = coalesce(p_motivo, motivo)
   where user_id = p_user and hasta is null;
end;
$$;

create function api.traspasar_cargo(p_cargo bigint, p_nuevo_user uuid, p_motivo text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_cargo idn.cargos;
  v_vigente idn.asignaciones_cargo;
begin
  perform idn.exigir('usuarios.gestionar');
  select * into v_cargo from idn.cargos where id = p_cargo and activo for update;
  if not found then raise exception 'El cargo no existe o no está activo.' using errcode = 'no_data_found'; end if;
  if not exists (select 1 from idn.perfiles where user_id = p_nuevo_user and activo) then
    raise exception 'El nuevo titular no tiene un perfil activo.' using errcode = 'no_data_found';
  end if;
  select * into v_vigente from idn.asignaciones_cargo where cargo_id = p_cargo and hasta is null;
  if found then
    if v_vigente.user_id = p_nuevo_user then
      raise exception 'Esa persona ya ocupa el cargo.' using errcode = 'check_violation';
    end if;
    update idn.asignaciones_cargo set hasta = current_date, motivo = coalesce(p_motivo, motivo) where id = v_vigente.id;
    -- el titular saliente queda con mínimo privilegio (consulta) y sin cargo ni entidad
    update idn.perfiles
       set cargo_id = null, rol = 'consulta', entidad_id = null, organizacion_id = null,
           zona_comunas = '{}', zona_barrios = '{}', mfa_requerido = false
     where user_id = v_vigente.user_id and cargo_id = p_cargo;
  end if;
  insert into idn.asignaciones_cargo (cargo_id, user_id, desde, motivo, registrado_por)
  values (p_cargo, p_nuevo_user, current_date, p_motivo, auth.uid());
  -- el rol sigue al cargo (ADR-0004). Si el cargo es comunitario, el perfil ya debe tener zona (cambiar_rol).
  update idn.perfiles
     set cargo_id = p_cargo, rol = v_cargo.rol_por_defecto,
         entidad_id = coalesce(v_cargo.entidad_id, entidad_id),
         organizacion_id = coalesce(v_cargo.organizacion_id, organizacion_id),
         mfa_requerido = idn.es_rol_con_mfa(v_cargo.rol_por_defecto)
   where user_id = p_nuevo_user;
end;
$$;

-- ───────────── Auditoría ─────────────
create function api.verificar_auditoria()
returns table (ok boolean, filas bigint, primera_invalida bigint, hash_cabecera text)
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform idn.exigir('auditoria.leer');
  return query select v.ok, v.filas, v.primera_invalida, encode(v.hash_cabecera, 'hex') from aud.verificar_cadena() v;
end;
$$;

-- ───────────── Solo service_role: provisión y supresión (nunca desde el navegador) ─────────────
create function idn.provisionar_perfil(
  p_user          uuid,
  p_rol           text,
  p_alias         text,
  p_entidad       bigint default null,
  p_organizacion  bigint default null,
  p_zona_comunas  text[] default '{}',
  p_zona_barrios  text[] default '{}',
  p_cargo         bigint default null,
  p_simulado      boolean default false
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_rol idn.rol_app := p_rol::idn.rol_app;
begin
  insert into idn.perfiles (user_id, rol, cargo_id, entidad_id, organizacion_id, zona_comunas, zona_barrios,
                            alias_visible, mfa_requerido, es_simulado)
  values (p_user, v_rol, p_cargo, p_entidad, p_organizacion, coalesce(p_zona_comunas, '{}'),
          coalesce(p_zona_barrios, '{}'), p_alias, idn.es_rol_con_mfa(v_rol), p_simulado);
  if p_cargo is not null then
    insert into idn.asignaciones_cargo (cargo_id, user_id, motivo) values (p_cargo, p_user, 'Provisión inicial');
  end if;
end;
$$;

-- Supresión de un titular: anonimiza el perfil. Después se borra la cuenta en Auth; la auditoría solo guarda el UUID.
create function idn.anonimizar_perfil(p_user uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  update idn.perfiles
     set alias_visible = 'Cuenta anonimizada', activo = false,
         desactivado_en = coalesce(desactivado_en, now()), zona_comunas = '{}', zona_barrios = '{}',
         creado_por = null
   where user_id = p_user;
  if not found then raise exception 'No existe ese perfil.' using errcode = 'no_data_found'; end if;
  delete from idn.autorizaciones_tratamiento where user_id = p_user;
end;
$$;

-- Hook de Supabase Auth: añade al JWT el rol y el alcance. La autorización real NO depende de estos claims
-- (idn.authorize consulta la base), así una suspensión o un cambio de rol surten efecto de inmediato.
create function idn.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_p idn.perfiles;
  v_claims jsonb := event -> 'claims';
begin
  select * into v_p from idn.perfiles where user_id = (event ->> 'user_id')::uuid and activo;
  if found then
    v_claims := v_claims || jsonb_build_object(
      'user_role', v_p.rol, 'entidad_id', v_p.entidad_id, 'organizacion_id', v_p.organizacion_id,
      'zona_comunas', to_jsonb(v_p.zona_comunas), 'zona_barrios', to_jsonb(v_p.zona_barrios));
  else
    v_claims := v_claims || jsonb_build_object('user_role', null);
  end if;
  return jsonb_set(event, '{claims}', v_claims);
end;
$$;
