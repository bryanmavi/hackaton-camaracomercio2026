-- Hito 5 · Migración 13: provisión de cuentas desde el servidor (clave service_role) por la API.
-- idn.provisionar_perfil vive en un esquema que la API no expone; estas funciones de `api` la envuelven y SOLO
-- las puede ejecutar service_role (backend, scripts). anon y authenticated no tienen EXECUTE.
-- Son idempotentes: repetirlas no duplica organizaciones, cargos ni perfiles.

-- Organización comunitaria (por ejemplo, las ficticias de la demostración). Devuelve su id.
create function api.asegurar_organizacion(
  p_tipo          text,
  p_nombre        text,
  p_comuna        text default null,
  p_barrio        text default null,
  p_simulado      boolean default true
) returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id bigint;
begin
  select id into v_id from geo.organizaciones_comunitarias
   where tipo = p_tipo and nombre = p_nombre and fuente_clave is null;
  if not found then
    insert into geo.organizaciones_comunitarias (tipo, nombre, comuna_codigo, barrio_codigo, es_simulado)
    values (p_tipo, p_nombre, p_comuna, p_barrio, p_simulado)
    returning id into v_id;
  end if;
  return v_id;
end;
$$;

-- Perfil de una cuenta ya creada en Supabase Auth. Si se da p_cargo_nombre, crea (o reutiliza) el cargo en la
-- entidad u organización y asigna a la persona. Devuelve 'creado' o 'existente'.
create function api.provisionar_perfil(
  p_user            uuid,
  p_rol             text,
  p_alias           text,
  p_entidad_codigo  text default null,
  p_organizacion_id bigint default null,
  p_zona_comunas    text[] default '{}',
  p_zona_barrios    text[] default '{}',
  p_cargo_nombre    text default null,
  p_simulado        boolean default false
) returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_entidad bigint;
  v_cargo bigint;
begin
  if exists (select 1 from idn.perfiles where user_id = p_user) then
    return 'existente';
  end if;
  if p_entidad_codigo is not null then
    select id into v_entidad from ref.entidades where codigo = p_entidad_codigo;
    if not found then
      raise exception 'La entidad % no existe.', p_entidad_codigo using errcode = 'foreign_key_violation';
    end if;
  end if;
  if p_cargo_nombre is not null then
    select id into v_cargo from idn.cargos
     where nombre = p_cargo_nombre
       and entidad_id is not distinct from v_entidad
       and organizacion_id is not distinct from p_organizacion_id;
    if not found then
      insert into idn.cargos (entidad_id, organizacion_id, nombre, rol_por_defecto)
      values (v_entidad, p_organizacion_id, p_cargo_nombre, p_rol::idn.rol_app)
      returning id into v_cargo;
    end if;
  end if;
  perform idn.provisionar_perfil(p_user, p_rol, p_alias, v_entidad, p_organizacion_id,
                                 p_zona_comunas, p_zona_barrios, v_cargo, p_simulado);
  return 'creado';
end;
$$;

revoke all on function api.asegurar_organizacion(text, text, text, text, boolean) from public, anon, authenticated;
revoke all on function api.provisionar_perfil(uuid, text, text, text, bigint, text[], text[], text, boolean)
  from public, anon, authenticated;
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'service_role') then
    grant usage on schema api to service_role;
    grant execute on function api.asegurar_organizacion(text, text, text, text, boolean) to service_role;
    grant execute on function api.provisionar_perfil(uuid, text, text, text, bigint, text[], text[], text, boolean)
      to service_role;
  end if;
end $$;
