-- Hito 1 · Migración 11: privilegios. Mínimo necesario, todo explícito.
-- Regla: ningún rol de API escribe en tablas; las funciones de `api` (SECURITY DEFINER) escriben por ellos.

-- 0) Quitar lo que Postgres da por defecto: EXECUTE a PUBLIC en funciones nuevas y acceso a los esquemas.
alter default privileges in schema ref, geo, ops, idn, aud, api revoke execute on functions from public;
revoke all on all functions in schema ref, geo, ops, idn, aud, api from public, anon, authenticated;
revoke all on all tables in schema ref, geo, ops, idn, aud, api from public, anon, authenticated;
revoke all on schema ref, geo, ops, idn, aud, api from public, anon, authenticated;

-- 1) Uso de esquemas. `extensions` aloja PostGIS (las vistas usan st_asgeojson, st_x, st_intersects).
grant usage on schema extensions to anon, authenticated;
grant usage on schema api, ref, geo to anon, authenticated;
grant usage on schema ops, idn, aud to authenticated;

-- 2) Lectura. `anon`: solo datos abiertos y catálogos públicos.
grant select on
  ref.fuentes, ref.entidades, ref.amenazas, ref.servicios, ref.funciones_espacio, ref.parametros_reglas,
  ref.responsabilidades,
  geo.comunas, geo.barrios, geo.espacios, geo.zonas_amenaza, geo.organizaciones_comunitarias,
  geo.espacio_exposicion, geo.mediciones_vigentes
to anon;
-- mediciones: columnas públicas (sin los UUID de quien reportó o validó); la política deja solo lo verificado
grant select (id, espacio_id, atributo, valor_num, valor_bool, valor_texto, valor_fecha, unidad, estado,
              fuente_texto, evidencia_ref, validado_en, es_simulado)
  on geo.mediciones_espacio to anon;

-- `authenticated`: lee tablas, la RLS decide qué filas. Sin INSERT, UPDATE ni DELETE.
grant select on all tables in schema ref, geo, ops, idn, aud to authenticated;

-- 3) Vistas de la API
grant select on
  api.amenazas, api.servicios, api.funciones_espacio, api.fuentes, api.entidades, api.responsabilidades,
  api.parametros_reglas, api.comunas, api.barrios, api.espacios, api.espacio_huellas, api.zonas_amenaza,
  api.espacio_exposicion, api.espacio_ficha
to anon, authenticated;
grant select on
  api.mi_perfil, api.usuarios_minimo, api.decisiones, api.brechas, api.mis_tareas, api.reportes_comunitarios,
  api.auditoria, api.resumen_territorial
to authenticated;

-- 4) Funciones de la API (cada una verifica permiso por dentro)
grant execute on function
  api.registrar_recomendacion(text, integer, text, text, text, jsonb, jsonb, text[], boolean),
  api.registrar_decision_activacion(uuid, text, text, text, text, text, date, text, integer, jsonb, text),
  api.actualizar_brecha(uuid, text, numeric, text),
  api.completar_tarea(bigint, text, text),
  api.crear_reporte_comunitario(text, text, integer, integer, integer, integer, integer, integer, integer, jsonb, text),
  api.registrar_medicion(text, text, text, numeric, boolean, text, date, text, text),
  api.validar_medicion(bigint, boolean, text),
  api.cerrar_retorno(uuid, jsonb, text, date, bigint[]),
  api.cambiar_rol(uuid, text, bigint, bigint, text[], text[]),
  api.suspender_usuario(uuid, text),
  api.traspasar_cargo(bigint, uuid, text),
  api.verificar_auditoria()
to authenticated;

-- 5) Ayudas de identidad que usan las políticas y las vistas (el esquema idn no está expuesto por la API)
grant execute on function
  idn.perfil_actual(), idn.rol_actual(), idn.entidad_actual(), idn.organizacion_actual(), idn.es_aal2(),
  idn.authorize(text), idn.mis_permisos(), idn.comuna_en_mi_zona(text), idn.espacio_en_mi_zona(text)
to authenticated;

-- 6) Solo servidor
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'service_role') then
    grant usage on schema idn to service_role;
    grant execute on function idn.provisionar_perfil(uuid, text, text, bigint, bigint, text[], text[], bigint, boolean),
                              idn.anonimizar_perfil(uuid) to service_role;
  end if;
  if exists (select 1 from pg_roles where rolname = 'supabase_auth_admin') then
    grant usage on schema idn to supabase_auth_admin;
    grant execute on function idn.custom_access_token_hook(jsonb) to supabase_auth_admin;
  end if;
end $$;
