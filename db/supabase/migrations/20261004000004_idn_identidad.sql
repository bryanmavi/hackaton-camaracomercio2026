-- Hito 1 · Migración 4: identidad (esquema idn). Único dato personal del sistema, y solo institucional.
-- Sin teléfono, documento ni dirección. El correo vive en auth.users (Supabase Auth).

create table idn.cargos (
  id               bigint generated always as identity primary key,
  entidad_id       bigint references ref.entidades (id),
  organizacion_id  bigint references geo.organizaciones_comunitarias (id),
  nombre           text not null,
  rol_por_defecto  idn.rol_app not null,
  activo           boolean not null default true,
  check (num_nonnulls(entidad_id, organizacion_id) <= 1)
);
comment on table idn.cargos is 'El rol se ata al cargo, no a la persona (ADR-0004).';

-- user_id NO tiene FK a auth.users a propósito: la supresión de un titular borra la cuenta de Auth y
-- anonimiza el perfil, y todo el registro institucional que apunta a él debe sobrevivir.
create table idn.perfiles (
  user_id         uuid primary key,
  rol             idn.rol_app not null,
  cargo_id        bigint references idn.cargos (id),
  entidad_id      bigint references ref.entidades (id),
  organizacion_id bigint references geo.organizaciones_comunitarias (id),
  zona_comunas    text[] not null default '{}',
  zona_barrios    text[] not null default '{}',
  alias_visible   text not null check (idn.texto_limpio(alias_visible) and char_length(alias_visible) <= 80),
  activo          boolean not null default true,
  mfa_requerido   boolean not null default false,
  es_simulado     boolean not null default false,
  creado_por      uuid,
  creado_en       timestamptz not null default now(),
  desactivado_en  timestamptz,
  -- MFA obligatorio para quien decide o administra
  check (rol not in ('superusuario', 'gestion_riesgo') or mfa_requerido),
  -- Una entidad responsable debe tener entidad; un comunitario, organización y zona
  check (rol <> 'entidad_responsable' or entidad_id is not null),
  check (rol <> 'comunitario' or (organizacion_id is not null
                                  and cardinality(zona_comunas) + cardinality(zona_barrios) > 0)),
  check (activo or desactivado_en is not null)
);
create index perfiles_entidad_ix on idn.perfiles (entidad_id);
comment on table idn.perfiles is 'Restringido. alias_visible es un cargo o alias institucional, nunca el nombre de la persona.';

create table idn.asignaciones_cargo (
  id             bigint generated always as identity primary key,
  cargo_id       bigint not null references idn.cargos (id),
  user_id        uuid not null references idn.perfiles (user_id),
  desde          date not null default current_date,
  hasta          date,
  motivo         text check (idn.texto_limpio(motivo)),
  registrado_por uuid references idn.perfiles (user_id),
  check (hasta is null or hasta >= desde)
);
-- Una asignación vigente por cargo
create unique index asignaciones_cargo_una_vigente on idn.asignaciones_cargo (cargo_id) where hasta is null;
create index asignaciones_cargo_user_ix on idn.asignaciones_cargo (user_id);

create table idn.rol_permisos (
  rol          idn.rol_app not null,
  permiso      text not null,
  requiere_aal2 boolean not null default false,
  primary key (rol, permiso)
);
comment on table idn.rol_permisos is 'La matriz de db/docs/ROLES_Y_PERMISOS.md como datos: auditable y testeable.';

create table idn.autorizaciones_tratamiento (
  user_id         uuid not null references idn.perfiles (user_id),
  version_politica text not null,
  aceptada_en     timestamptz not null default now(),
  primary key (user_id, version_politica)
);
comment on table idn.autorizaciones_tratamiento is 'Sin IP ni otros metadatos (minimización).';
