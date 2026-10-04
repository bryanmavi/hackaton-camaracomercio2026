-- Hito 1 · Migración 8: permisos como datos, funciones de autorización y políticas RLS.
-- Diseño (ADR-0002): las tablas no se exponen. Los roles `anon` y `authenticated` solo reciben SELECT (con RLS)
-- para que las vistas `api` con security_invoker funcionen; TODA escritura pasa por funciones de `api`
-- (SECURITY DEFINER) que verifican permiso, alcance y MFA por sí mismas.
-- La verdad sobre el rol y la vigencia es la BASE (idn.perfiles), no el JWT: suspender un usuario o cambiarle el
-- rol surte efecto de inmediato, sin esperar a que caduque el token. El JWT solo aporta `aal` (MFA).

-- ───────────── Permisos (db/docs/ROLES_Y_PERMISOS.md §2) ─────────────
-- Desviaciones respecto a la tabla del documento, para que cada permiso sea binario:
--   · `operativo.leer_agregado` (consulta) separa la lectura agregada de la lectura por filas.
--   · `parametros.editar` (gestion_riesgo) separa "editar parámetros" de `catalogos.editar` (datic_tecnico).
insert into idn.rol_permisos (rol, permiso, requiere_aal2) values
  ('superusuario',        'espacios.leer',          false),
  ('superusuario',        'entidades.editar',       false),
  ('superusuario',        'usuarios.gestionar',     true),
  ('superusuario',        'usuarios.leer_minimo',   false),

  ('gestion_riesgo',      'espacios.leer',          false),
  ('gestion_riesgo',      'operativo.leer',         false),
  ('gestion_riesgo',      'recomendacion.crear',    false),
  ('gestion_riesgo',      'decision.activar',       true),
  ('gestion_riesgo',      'retorno.cerrar',         false),
  ('gestion_riesgo',      'brecha.actualizar',      false),
  ('gestion_riesgo',      'tarea.completar',        false),
  ('gestion_riesgo',      'medicion.declarar',      false),
  ('gestion_riesgo',      'medicion.validar',       false),
  ('gestion_riesgo',      'parametros.editar',      false),
  ('gestion_riesgo',      'protocolo.editar',       false),

  ('entidad_responsable', 'espacios.leer',          false),
  ('entidad_responsable', 'operativo.leer',         false),
  ('entidad_responsable', 'recomendacion.crear',    false),
  ('entidad_responsable', 'brecha.actualizar',      false),
  ('entidad_responsable', 'tarea.completar',        false),
  ('entidad_responsable', 'medicion.declarar',      false),
  ('entidad_responsable', 'medicion.validar',       false),

  ('datic_tecnico',       'espacios.leer',          false),
  ('datic_tecnico',       'catalogos.editar',       false),
  ('datic_tecnico',       'parametros.editar',      false),

  ('comunitario',         'espacios.leer',          false),
  ('comunitario',         'operativo.leer',         false),
  ('comunitario',         'medicion.declarar',      false),
  ('comunitario',         'reporte.crear',          false),

  ('auditor',             'espacios.leer',          false),
  ('auditor',             'operativo.leer',         false),
  ('auditor',             'usuarios.leer_minimo',   false),
  ('auditor',             'auditoria.leer',         false),

  ('consulta',            'espacios.leer',          false),
  ('consulta',            'operativo.leer_agregado', false);

-- ───────────── Funciones de identidad (SECURITY DEFINER, solo lectura) ─────────────
create function idn.perfil_actual()
returns idn.perfiles
language sql
stable
security definer
set search_path = ''
as $$
  select p.* from idn.perfiles p where p.user_id = auth.uid() and p.activo;
$$;

create function idn.rol_actual()             returns idn.rol_app language sql stable security definer set search_path = '' as $$ select (idn.perfil_actual()).rol $$;
create function idn.entidad_actual()         returns bigint      language sql stable security definer set search_path = '' as $$ select (idn.perfil_actual()).entidad_id $$;
create function idn.organizacion_actual()    returns bigint      language sql stable security definer set search_path = '' as $$ select (idn.perfil_actual()).organizacion_id $$;

create function idn.es_aal2()
returns boolean
language sql
stable
set search_path = ''
as $$ select coalesce(auth.jwt() ->> 'aal', '') = 'aal2' $$;

create function idn.authorize(p_permiso text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from idn.perfiles p
    join idn.rol_permisos rp on rp.rol = p.rol
    where p.user_id = auth.uid() and p.activo and rp.permiso = p_permiso
  );
$$;

-- Para las funciones de escritura: exige permiso y, si el permiso lo pide, MFA (aal2).
create function idn.exigir(p_permiso text)
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_aal2 boolean;
begin
  select rp.requiere_aal2 into v_aal2
  from idn.perfiles p
  join idn.rol_permisos rp on rp.rol = p.rol
  where p.user_id = auth.uid() and p.activo and rp.permiso = p_permiso;
  if not found then
    raise exception 'No tienes el permiso "%".', p_permiso using errcode = 'insufficient_privilege';
  end if;
  if v_aal2 and not idn.es_aal2() then
    raise exception 'El permiso "%" exige verificación en dos pasos (aal2).', p_permiso
      using errcode = 'insufficient_privilege';
  end if;
end;
$$;

create function idn.mis_permisos()
returns text[]
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(array_agg(rp.permiso order by rp.permiso), '{}')
  from idn.perfiles p join idn.rol_permisos rp on rp.rol = p.rol
  where p.user_id = auth.uid() and p.activo;
$$;

-- Alcance territorial del perfil (solo `comunitario` está limitado por zona).
create function idn.comuna_en_mi_zona(p_comuna text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from idn.perfil_actual() p where p_comuna = any (p.zona_comunas));
$$;

create function idn.espacio_en_mi_zona(p_espacio text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from geo.espacios e, idn.perfil_actual() p
    where e.id = p_espacio
      and (e.comuna_codigo = any (p.zona_comunas)
           or exists (select 1 from geo.barrios b
                      where b.codigo = any (p.zona_barrios) and extensions.st_intersects(b.geom, e.punto)))
  );
$$;

-- ───────────── RLS ─────────────
do $$
declare
  t record;
begin
  for t in
    select n.nspname, c.relname
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where c.relkind in ('r', 'p') and n.nspname in ('ref', 'geo', 'ops', 'idn', 'aud')
  loop
    execute format('alter table %I.%I enable row level security', t.nspname, t.relname);
  end loop;
end $$;

-- Públicos (datos abiertos y catálogos). La matriz de responsabilidades es pública y va marcada "propuesta".
do $$
declare
  t text;
begin
  foreach t in array array[
    'ref.fuentes', 'ref.entidades', 'ref.amenazas', 'ref.servicios', 'ref.funciones_espacio',
    'ref.parametros_reglas', 'ref.responsabilidades',
    'geo.comunas', 'geo.barrios', 'geo.espacios', 'geo.zonas_amenaza', 'geo.organizaciones_comunitarias']
  loop
    execute format('create policy publico_lee on %s for select to anon, authenticated using (true)', t);
  end loop;
end $$;

-- Protocolo: interno
create policy operativo_lee on ref.protocolo_plantillas for select to authenticated
  using ((select idn.authorize('operativo.leer')));
create policy operativo_lee on ref.protocolo_pasos for select to authenticated
  using ((select idn.authorize('operativo.leer')));

-- Mediciones: lo verificado es público; lo demás, interno y acotado.
create policy verificadas_publicas on geo.mediciones_espacio for select to anon, authenticated
  using (estado = 'verificado');
create policy internas_por_alcance on geo.mediciones_espacio for select to authenticated
  using (
    (select idn.authorize('operativo.leer'))
    and (
      (select idn.rol_actual()) in ('gestion_riesgo', 'entidad_responsable', 'auditor')
      or ((select idn.rol_actual()) = 'comunitario' and idn.espacio_en_mi_zona(espacio_id))
    )
  );

-- Operación
create policy lee on ops.recomendaciones for select to authenticated
  using ((select idn.rol_actual()) in ('gestion_riesgo', 'entidad_responsable', 'auditor'));

create policy lee on ops.decisiones_activacion for select to authenticated
  using (
    (select idn.rol_actual()) in ('gestion_riesgo', 'auditor')
    or ((select idn.rol_actual()) = 'entidad_responsable'
        and (exists (select 1 from ops.brechas b
                     where b.decision_id = ops.decisiones_activacion.id
                       and b.entidad_responsable_id = (select idn.entidad_actual()))
             or exists (select 1 from ops.tareas_protocolo t
                        where t.decision_id = ops.decisiones_activacion.id
                          and t.entidad_id = (select idn.entidad_actual()))))
    or ((select idn.rol_actual()) = 'comunitario'
        and estado = 'vigente' and idn.espacio_en_mi_zona(espacio_id))
  );

create policy lee on ops.brechas for select to authenticated
  using (
    (select idn.rol_actual()) in ('gestion_riesgo', 'auditor')
    or ((select idn.rol_actual()) = 'entidad_responsable'
        and entidad_responsable_id = (select idn.entidad_actual()))
  );

create policy lee on ops.seguimientos for select to authenticated
  using (exists (select 1 from ops.brechas b where b.id = ops.seguimientos.brecha_id));

create policy lee on ops.tareas_protocolo for select to authenticated
  using (
    (select idn.rol_actual()) in ('gestion_riesgo', 'auditor')
    or ((select idn.rol_actual()) = 'entidad_responsable' and entidad_id = (select idn.entidad_actual()))
  );

create policy lee on ops.reportes_comunitarios for select to authenticated
  using (
    (select idn.rol_actual()) in ('gestion_riesgo', 'auditor')
    or ((select idn.rol_actual()) = 'comunitario'
        and (organizacion_id = (select idn.organizacion_actual())
             or exists (select 1 from geo.organizaciones_comunitarias o
                        where o.id = ops.reportes_comunitarios.organizacion_id
                          and idn.comuna_en_mi_zona(o.comuna_codigo))))
  );

create policy lee on ops.retornos for select to authenticated
  using (exists (select 1 from ops.decisiones_activacion d where d.id = ops.retornos.decision_id));

create policy lee on ops.lecturas_iot for select to authenticated
  using ((select idn.rol_actual()) in ('gestion_riesgo', 'entidad_responsable', 'auditor'));
create policy lee on ops.notificaciones for select to authenticated
  using ((select idn.rol_actual()) in ('gestion_riesgo', 'entidad_responsable', 'auditor'));

-- Identidad
create policy propio_o_minimo on idn.perfiles for select to authenticated
  using (user_id = (select auth.uid()) or (select idn.authorize('usuarios.leer_minimo')));
create policy minimo on idn.cargos for select to authenticated
  using ((select idn.authorize('usuarios.leer_minimo')));
create policy minimo on idn.asignaciones_cargo for select to authenticated
  using ((select idn.authorize('usuarios.leer_minimo')));
create policy auditable on idn.rol_permisos for select to authenticated
  using ((select idn.authorize('usuarios.leer_minimo')));
create policy propia_o_auditor on idn.autorizaciones_tratamiento for select to authenticated
  using (user_id = (select auth.uid()) or (select idn.authorize('auditoria.leer')));

-- Auditoría
create policy auditor_lee on aud.eventos for select to authenticated
  using ((select idn.authorize('auditoria.leer')));
create policy auditor_lee on aud.verificaciones for select to authenticated
  using ((select idn.authorize('auditoria.leer')));
