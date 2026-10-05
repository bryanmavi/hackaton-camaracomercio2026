-- Hito 1 · Migración 2: catálogos (esquema ref). Clase de dato: Público, salvo el protocolo (Interno).

create table ref.fuentes (
  clave           text primary key,
  nombre          text not null,
  entidad         text not null,
  pagina_fuente   text not null,
  url_descarga    text,
  licencia        text not null check (licencia in ('CC BY', 'CC BY-SA')),
  compartir_igual boolean not null,
  atribucion      text not null,
  fecha_corte     date not null,
  sha256          char(64) check (sha256 ~ '^[0-9a-f]{64}$'),
  n_registros     integer check (n_registros >= 0),
  es_simulado     boolean not null default false,
  check (compartir_igual = (licencia = 'CC BY-SA'))
);
comment on table ref.fuentes is 'Una fila por conjunto de datos abiertos; reproduce maqueta3d/public/data/manifest.json.';

create table ref.entidades (
  id                  bigint generated always as identity primary key,
  codigo              text not null unique check (codigo ~ '^[A-Z0-9_]+$'),
  nombre              text not null,
  nivel               text not null check (nivel in
                        ('municipal', 'departamental', 'nacional', 'operativo', 'comunitario', 'privado')),
  padre_id            bigint references ref.entidades (id),
  vigente_desde       date,
  vigente_hasta       date,
  sucesora_id         bigint references ref.entidades (id),
  competencia_resumen text not null,
  norma_competencia   text,
  estado_validacion   text not null default 'propuesta' check (estado_validacion in ('propuesta', 'validada')),
  check (vigente_hasta is null or vigente_desde is null or vigente_hasta >= vigente_desde),
  check (sucesora_id is null or sucesora_id <> id),
  check (padre_id is null or padre_id <> id)
);
comment on table ref.entidades is
  'Las secretarías se reorganizan: se cierra la vigencia y se apunta a la sucesora; no se borra (ADR-0004).';

create table ref.amenazas (
  codigo          text primary key,
  nombre_es       text not null,
  activa_en_motor boolean not null,
  nota            text
);

create table ref.parametros_reglas (
  clave         text not null,
  version       integer not null check (version >= 1),
  valor         numeric not null,
  unidad        text,
  fuente_url    text,
  nota          text,
  vigente       boolean not null default true,
  vigente_desde date not null default current_date,
  primary key (clave, version)
);
create unique index parametros_reglas_una_vigente on ref.parametros_reglas (clave) where vigente;
comment on table ref.parametros_reglas is
  'Fuente única de los parámetros de planeación. Las reglas de cálculo siguen en TypeScript (ADR-0007).';

create table ref.servicios (
  codigo            text primary key,
  nombre_es         text not null,
  tipo              text not null check (tipo in ('cuantitativo', 'tarea_evidencia')),
  unidad            text,
  amenaza_codigo    text references ref.amenazas (codigo),
  parametro_clave   text,
  atributo_medicion text check (atributo_medicion in
                      ('capacidad_personas', 'banos', 'agua_l_dia', 'capacidad_animales')),
  regla_texto       text,
  check (tipo = 'tarea_evidencia' or unidad is not null),
  check (tipo = 'cuantitativo' or (unidad is null and parametro_clave is null))
);
comment on column ref.servicios.atributo_medicion is
  'Atributo de geo.mediciones_espacio que alimenta el "existente" de la brecha y define qué entidad puede validarlo.';

create table ref.funciones_espacio (
  codigo              text primary key,
  fase                text not null check (fase in ('inmediata', 'temporal', 'apoyo')),
  nombre_es           text not null,
  amenazas_aplicables text[] not null,
  descripcion         text,
  estado_validacion   text not null default 'propuesta' check (estado_validacion in ('propuesta', 'validada'))
);
comment on table ref.funciones_espacio is
  'Separa punto de reunión inmediata (horas), albergue (días o semanas) y acopio. Ver docs/referentes/REFERENTES_INTERNACIONALES.md.';

create table ref.responsabilidades (
  servicio_codigo    text not null references ref.servicios (codigo),
  entidad_id         bigint not null references ref.entidades (id),
  contexto           text not null references ref.funciones_espacio (codigo),
  papel              text not null check (papel in ('lidera', 'apoya', 'valida')),
  bloquea_activacion boolean not null default false,
  estado_validacion  text not null default 'propuesta' check (estado_validacion in ('propuesta', 'validada')),
  fuente             text not null,
  primary key (servicio_codigo, entidad_id, contexto)
);
-- Una sola entidad lidera cada servicio en cada contexto: de ahí se asigna la brecha.
create unique index responsabilidades_un_lider on ref.responsabilidades (servicio_codigo, contexto)
  where papel = 'lidera';
comment on table ref.responsabilidades is
  'Matriz de responsabilidades. Es PROPUESTA hasta que la Secretaría de Gestión del Riesgo la valide.';

create table ref.protocolo_plantillas (
  id                bigint generated always as identity primary key,
  nombre            text not null,
  amenaza_codigo    text references ref.amenazas (codigo),
  version           integer not null default 1 check (version >= 1),
  vigente           boolean not null default true,
  estado_validacion text not null default 'propuesta' check (estado_validacion in ('propuesta', 'validada')),
  unique (nombre, version)
);

create table ref.protocolo_pasos (
  id                 bigint generated always as identity primary key,
  plantilla_id       bigint not null references ref.protocolo_plantillas (id) on delete cascade,
  orden              integer not null check (orden >= 1),
  titulo             text not null,
  descripcion        text,
  entidad_id         bigint references ref.entidades (id),
  servicio_codigo    text references ref.servicios (codigo),
  plazo_ref_horas    integer check (plazo_ref_horas > 0),
  bloquea_activacion boolean not null default false,
  unique (plantilla_id, orden)
);
comment on column ref.protocolo_pasos.entidad_id is 'NULL = entidad por definir (no se asigna sin verificar).';
comment on column ref.protocolo_pasos.plazo_ref_horas is 'NULL = sin plazo de referencia verificado (no se inventan plazos).';
