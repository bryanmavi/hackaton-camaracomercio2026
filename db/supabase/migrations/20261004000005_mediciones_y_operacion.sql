-- Hito 1 · Migración 5: mediciones verificables (geo) y operación (ops).
-- Principios que se materializan aquí: desconocido ≠ cero (NULL + estado), recomienda ≠ decide,
-- lo simulado se marca y se fuerza, y no existe ninguna tabla de personas damnificadas (ADR-0008).

-- ───────────────────────── geo.mediciones_espacio ─────────────────────────
create table geo.mediciones_espacio (
  id            bigint generated always as identity primary key,
  espacio_id    text not null references geo.espacios (id),
  atributo      text not null check (atributo in (
                  'capacidad_personas', 'banos', 'agua_l_dia', 'evaluacion_estructural_vigente',
                  'accesibilidad', 'energia_respaldo', 'disponibilidad', 'administracion_acceso', 'horario',
                  'acepta_animales_compania', 'zona_animales', 'capacidad_animales')),
  valor_num     numeric,
  valor_bool    boolean,   -- sí/no (desviación respecto al diccionario: se separa de valor_texto)
  valor_texto   text check (idn.texto_limpio(valor_texto) and char_length(valor_texto) <= 280),
  valor_fecha   date,
  unidad        text,
  estado        text not null default 'declarado' check (estado in ('declarado', 'verificado', 'rechazado')),
  fuente_texto  text not null check (idn.texto_limpio(fuente_texto) and char_length(fuente_texto) <= 280),
  evidencia_ref text check (idn.referencia_valida(evidencia_ref)),
  reportado_por uuid not null references idn.perfiles (user_id),
  reportado_en  timestamptz not null default now(),
  validado_por  uuid references idn.perfiles (user_id),
  validado_en   timestamptz,
  es_simulado   boolean not null default false,
  -- Un solo tipo de valor según el atributo. De la evaluación estructural solo se guarda
  -- sí/no y la fecha: NO hay columna para un concepto técnico (NSR-10, Ley 400/1997).
  constraint medicion_tipo_de_valor check (case atributo
    when 'capacidad_personas' then valor_num is not null and valor_num >= 0 and num_nonnulls(valor_bool, valor_texto, valor_fecha) = 0
    when 'banos'              then valor_num is not null and valor_num >= 0 and num_nonnulls(valor_bool, valor_texto, valor_fecha) = 0
    when 'agua_l_dia'         then valor_num is not null and valor_num >= 0 and num_nonnulls(valor_bool, valor_texto, valor_fecha) = 0
    when 'capacidad_animales' then valor_num is not null and valor_num >= 0 and num_nonnulls(valor_bool, valor_texto, valor_fecha) = 0
    when 'accesibilidad'      then valor_bool is not null and num_nonnulls(valor_num, valor_texto, valor_fecha) = 0
    when 'energia_respaldo'   then valor_bool is not null and num_nonnulls(valor_num, valor_texto, valor_fecha) = 0
    when 'acepta_animales_compania' then valor_bool is not null and num_nonnulls(valor_num, valor_texto, valor_fecha) = 0
    when 'zona_animales'      then valor_bool is not null and num_nonnulls(valor_num, valor_texto, valor_fecha) = 0
    when 'evaluacion_estructural_vigente'
                              then valor_bool is not null and (not valor_bool or valor_fecha is not null)
                                   and num_nonnulls(valor_num, valor_texto) = 0
    else                           valor_texto is not null and num_nonnulls(valor_num, valor_bool, valor_fecha) = 0
  end),
  -- Verificado exige quién, cuándo y evidencia; declarado no puede traer datos de validación.
  constraint medicion_verificado_con_evidencia check (case estado
    when 'verificado' then validado_por is not null and validado_en is not null and evidencia_ref is not null
    when 'rechazado'  then validado_por is not null and validado_en is not null
    else                   validado_por is null and validado_en is null
  end),
  -- Cuatro ojos: quien reporta no valida.
  constraint medicion_validador_distinto check (validado_por is distinct from reportado_por)
);
create index mediciones_espacio_attr_ix on geo.mediciones_espacio (espacio_id, atributo, estado, validado_en desc);
comment on table geo.mediciones_espacio is
  'Historia verificable de lo que en la app es null. Sin fila = desconocido, nunca cero (ADR-0005).';

-- Última medición VERIFICADA por espacio y atributo (alimenta la ficha pública).
create view geo.mediciones_vigentes
with (security_invoker = true) as
select distinct on (espacio_id, atributo)
       id, espacio_id, atributo, valor_num, valor_bool, valor_texto, valor_fecha, unidad,
       fuente_texto, evidencia_ref, validado_en, es_simulado
from geo.mediciones_espacio
where estado = 'verificado'
order by espacio_id, atributo, validado_en desc, id desc;

-- ───────────────────────── ops.recomendaciones (inmutable) ─────────────────────────
create table ops.recomendaciones (
  id                uuid primary key default gen_random_uuid(),
  creada_en         timestamptz not null default now(),
  creada_por        uuid not null references idn.perfiles (user_id),
  amenaza_codigo    text not null references ref.amenazas (codigo),
  personas_escenario integer not null check (personas_escenario between 1 and 100000),
  origen_espacio_id text not null references geo.espacios (id),
  ambito            text check (idn.texto_limpio(ambito) and char_length(ambito) <= 120),
  version_reglas    text not null,
  candidatos        jsonb not null check (jsonb_typeof(candidatos) = 'array' and jsonb_array_length(candidatos) <= 3),
  resumen_cribado   jsonb not null check (jsonb_typeof(resumen_cribado) = 'object'),
  advertencias      text[] not null default '{}',
  es_simulado       boolean not null default true,
  unique (id, origen_espacio_id)
);
create trigger recomendaciones_inmutable
  before update or delete on ops.recomendaciones
  for each row execute function aud.bloquear_modificacion();
comment on table ops.recomendaciones is 'Salida del sistema, inmutable. NO es una decisión (ADR-0003).';

-- ───────────────────────── ops.decisiones_activacion ─────────────────────────
create table ops.decisiones_activacion (
  id                uuid primary key default gen_random_uuid(),
  recomendacion_id  uuid references ops.recomendaciones (id),
  espacio_id        text not null references geo.espacios (id),
  amenaza_codigo    text not null references ref.amenazas (codigo),
  funcion           text not null references ref.funciones_espacio (codigo),
  acto_tipo         text not null check (acto_tipo in ('decreto', 'resolucion', 'acta_cmgrd', 'instruccion_secretaria')),
  acto_numero       text not null check (idn.referencia_valida(acto_numero, 60)),
  acto_fecha        date not null,
  justificacion     text check (idn.texto_limpio(justificacion) and char_length(justificacion) <= 500),
  decidida_por      uuid not null references idn.perfiles (user_id),
  cargo_id          bigint references idn.cargos (id),
  decidida_en       timestamptz not null default now(),
  estado            text not null default 'vigente' check (estado in ('vigente', 'en_desactivacion', 'cerrada')),
  personas_estimadas integer check (personas_estimadas between 1 and 100000),
  es_simulado       boolean not null default true,
  unique (id, espacio_id)
);
create index decisiones_espacio_ix on ops.decisiones_activacion (espacio_id, estado);
comment on table ops.decisiones_activacion is
  'Acto humano. Solo api.registrar_decision_activacion inserta (gestion_riesgo con aal2). No hay GRANT de escritura a ningún rol de API.';

-- Reglas que valen sin importar por qué camino se inserte (defensa en profundidad).
create function ops.validar_decision()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_rec record;
  v_aplicables text[];
begin
  select amenazas_aplicables into v_aplicables from ref.funciones_espacio where codigo = new.funcion;
  if tg_op = 'INSERT' then
    if not (new.amenaza_codigo = any (v_aplicables)) then
      raise exception 'La función % no aplica a la amenaza %.', new.funcion, new.amenaza_codigo
        using errcode = 'check_violation';
    end if;
    if new.recomendacion_id is not null then
      select amenaza_codigo, origen_espacio_id, candidatos into v_rec
        from ops.recomendaciones where id = new.recomendacion_id;
      if v_rec.amenaza_codigo is distinct from new.amenaza_codigo then
        raise exception 'La decisión no coincide con la amenaza de la recomendación.'
          using errcode = 'check_violation';
      end if;
    end if;
    -- Si no sale de una recomendación, o activa un espacio distinto a los recomendados, hay que justificar.
    if (new.recomendacion_id is null
        or not exists (
             select 1 from ops.recomendaciones r,
                  jsonb_array_elements(r.candidatos) c
             where r.id = new.recomendacion_id and c ->> 'id' = new.espacio_id))
       and coalesce(btrim(new.justificacion), '') = '' then
      raise exception 'Se exige justificación cuando la decisión no sale de una recomendación o activa un espacio no recomendado.'
        using errcode = 'check_violation';
    end if;
  else
    -- UPDATE: solo cambia el estado, y sin saltar etapas (vigente → en_desactivacion → cerrada).
    if (to_jsonb(new) - 'estado') is distinct from (to_jsonb(old) - 'estado') then
      raise exception 'Una decisión de activación solo admite cambio de estado.' using errcode = 'restrict_violation';
    end if;
    if not ((old.estado, new.estado) in (('vigente', 'en_desactivacion'), ('en_desactivacion', 'cerrada'), ('vigente', 'vigente'),
                                         ('en_desactivacion', 'en_desactivacion'), ('cerrada', 'cerrada'))) then
      raise exception 'Transición de estado no permitida: % → %.', old.estado, new.estado
        using errcode = 'check_violation';
    end if;
  end if;
  return new;
end;
$$;
create trigger decisiones_validar
  before insert or update on ops.decisiones_activacion
  for each row execute function ops.validar_decision();
create trigger decisiones_sin_borrado
  before delete on ops.decisiones_activacion
  for each row execute function aud.bloquear_modificacion();

-- ───────────────────────── ops.brechas y seguimiento ─────────────────────────
create table ops.brechas (
  id                     uuid primary key default gen_random_uuid(),
  decision_id            uuid not null,
  espacio_id             text not null,
  servicio_codigo        text not null references ref.servicios (codigo),
  requerido              numeric check (requerido >= 0),   -- NULL en servicios de tipo tarea
  unidad                 text,
  existente              numeric check (existente >= 0),   -- NULL = sin dato
  -- Faltante calculado, no escrito. Si no se sabe lo existente, el faltante se desconoce (no es cero).
  faltante               numeric generated always as (
                           case when requerido is null or existente is null then null
                                else greatest(0, requerido - existente) end) stored,
  entidad_responsable_id bigint references ref.entidades (id),   -- NULL = sin responsable asignado
  estado                 text not null default 'por_medir'
                           check (estado in ('por_medir', 'en_revision', 'asignada', 'en_ejecucion', 'cerrada')),
  regla_texto            text,
  version_reglas         text,
  es_simulado            boolean not null default true,
  foreign key (decision_id, espacio_id) references ops.decisiones_activacion (id, espacio_id),
  unique (decision_id, servicio_codigo)
);
create index brechas_entidad_ix on ops.brechas (entidad_responsable_id, estado);
create index brechas_espacio_ix on ops.brechas (espacio_id);

create table ops.seguimientos (
  id              bigint generated always as identity primary key,
  brecha_id       uuid not null references ops.brechas (id),
  estado_anterior text not null,
  estado_nuevo    text not null,
  nota            text check (idn.texto_limpio(nota) and char_length(nota) <= 280),
  registrado_por  uuid not null references idn.perfiles (user_id),
  registrado_en   timestamptz not null default now()
);
create index seguimientos_brecha_ix on ops.seguimientos (brecha_id, registrado_en);
create trigger seguimientos_inmutable
  before update or delete on ops.seguimientos
  for each row execute function aud.bloquear_modificacion();

-- ───────────────────────── ops.tareas_protocolo ─────────────────────────
create table ops.tareas_protocolo (
  id             bigint generated always as identity primary key,
  decision_id    uuid not null references ops.decisiones_activacion (id),
  paso_id        bigint not null references ref.protocolo_pasos (id),
  entidad_id     bigint references ref.entidades (id),
  estado         text not null default 'pendiente' check (estado in ('pendiente', 'en_curso', 'completada', 'no_aplica')),
  vence_en       timestamptz,
  completada_por uuid references idn.perfiles (user_id),
  completada_en  timestamptz,
  nota           text check (idn.texto_limpio(nota) and char_length(nota) <= 280),
  es_simulado    boolean not null default true,
  unique (decision_id, paso_id),
  check ((estado = 'completada' and completada_por is not null and completada_en is not null)
         or (estado <> 'completada' and completada_por is null and completada_en is null))
);
create index tareas_entidad_ix on ops.tareas_protocolo (entidad_id, estado);

-- ───────────────────────── ops.reportes_comunitarios ─────────────────────────
-- Solo conteos agregados. Ningún campo identifica a una persona (ADR-0008).
create table ops.reportes_comunitarios (
  id                  uuid primary key default gen_random_uuid(),
  organizacion_id     bigint not null references geo.organizaciones_comunitarias (id),
  espacio_id          text references geo.espacios (id),
  tipo                text not null check (tipo in ('estado_espacio', 'necesidad', 'alerta_barrial')),
  n_total             integer check (n_total >= 0),
  n_0_5               integer check (n_0_5 >= 0),
  n_6_17              integer check (n_6_17 >= 0),
  n_18_59             integer check (n_18_59 >= 0),
  n_60_mas            integer check (n_60_mas >= 0),
  n_discapacidad      integer check (n_discapacidad >= 0),   -- opcional, sensible, solo agregado (decisión §9.3)
  n_animales_compania integer check (n_animales_compania >= 0),
  estado_servicios    jsonb check (estado_servicios is null or jsonb_typeof(estado_servicios) = 'object'),
  observacion         text check (idn.texto_limpio(observacion) and char_length(observacion) <= 280),  -- decisión §9.5
  creado_por          uuid not null references idn.perfiles (user_id),
  creado_en           timestamptz not null default now(),
  es_simulado         boolean not null default true,
  -- La suma de los grupos de edad debe igualar el total; o no hay desglose
  constraint reporte_grupos_suman check (
    (n_0_5 is null and n_6_17 is null and n_18_59 is null and n_60_mas is null)
    or (num_nonnulls(n_0_5, n_6_17, n_18_59, n_60_mas) = 4 and n_total = n_0_5 + n_6_17 + n_18_59 + n_60_mas)),
  constraint reporte_discapacidad_acotada check (n_discapacidad is null or (n_total is not null and n_discapacidad <= n_total)),
  constraint reporte_estado_espacio_con_espacio check (tipo <> 'estado_espacio' or espacio_id is not null)
);
create index reportes_org_ix on ops.reportes_comunitarios (organizacion_id, creado_en desc);

create function ops.validar_reporte()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.estado_servicios is not null then
    if exists (
      select 1 from jsonb_each(new.estado_servicios) e
      where e.key not in (select codigo from ref.servicios)
         or e.value not in ('"ok"'::jsonb, '"falla"'::jsonb, '"sin_dato"'::jsonb)
    ) then
      raise exception 'estado_servicios solo admite claves de ref.servicios con valor ok, falla o sin_dato.'
        using errcode = 'check_violation';
    end if;
  end if;
  return new;
end;
$$;
create trigger reportes_validar
  before insert or update on ops.reportes_comunitarios
  for each row execute function ops.validar_reporte();

-- ───────────────────────── ops.retornos ─────────────────────────
create table ops.retornos (
  id               uuid primary key default gen_random_uuid(),
  decision_id      uuid not null unique references ops.decisiones_activacion (id),
  checklist        jsonb not null check (jsonb_typeof(checklist) = 'object'),
  acta_ref         text not null check (idn.referencia_valida(acta_ref)),
  fecha_retorno    date not null,
  estado           text not null default 'cerrado' check (estado in ('en_curso', 'cerrado')),
  cargos_firmantes bigint[] not null default '{}',
  cerrado_por      uuid not null references idn.perfiles (user_id),
  es_simulado      boolean not null default true
);

-- ───────────────────────── Datos solo simulados (IoT y notificaciones) ─────────────────────────
create table ops.lecturas_iot (
  id          bigint generated always as identity primary key,
  espacio_id  text not null references geo.espacios (id),
  sensor      text not null check (sensor in ('nivel_tanque', 'temperatura', 'humedad', 'conteo_agregado')),
  valor       numeric not null,
  unidad      text not null,
  medido_en   timestamptz not null default now(),
  es_simulado boolean not null default true check (es_simulado)
);
create index lecturas_iot_ix on ops.lecturas_iot (espacio_id, sensor, medido_en desc);
comment on table ops.lecturas_iot is 'Solo simuladas (CHECK). Sin cámaras ni identificadores de dispositivos de personas. Retención propuesta: 30 días.';

create table ops.notificaciones (
  id                bigint generated always as identity primary key,
  decision_id       uuid references ops.decisiones_activacion (id),
  destinatario_tipo text not null check (destinatario_tipo in ('entidad', 'organizacion', 'publico')),
  mensaje           text not null check (idn.texto_limpio(mensaje) and char_length(mensaje) <= 480),
  estado            text not null default 'borrador' check (estado = 'borrador'),
  es_simulado       boolean not null default true check (es_simulado),
  creado_en         timestamptz not null default now()
);
comment on table ops.notificaciones is 'Solo borradores simulados: en el MVP no hay envío real. Sin teléfonos ni correos de destinatarios.';
