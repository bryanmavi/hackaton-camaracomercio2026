-- Hito 1 · Migración 1: extensiones, esquemas, tipos y funciones de ayuda.
-- Estado: BORRADOR para revisión del responsable de la BD (ver db/docs/MODELO_DATOS.md §9).
-- Decisiones abiertas que esta migración asume con el valor propuesto (cada una es fácil de cambiar):
--   · identificadores en español, códigos de amenaza y servicio en inglés (los de la app)  [§9.6]
--   · textos libres solo con filtro de datos personales                                    [§9.5]
-- Nada aquí contiene secretos ni datos personales.

create schema if not exists extensions;
create extension if not exists postgis with schema extensions;

create schema if not exists ref;   -- catálogos
create schema if not exists geo;   -- territorio
create schema if not exists ops;   -- operación
create schema if not exists idn;   -- identidad (único dato personal del sistema)
create schema if not exists aud;   -- auditoría encadenada por hash
create schema if not exists api;   -- única superficie expuesta

comment on schema ref is 'Catálogos: fuentes, entidades, amenazas, servicios, responsabilidades, parámetros y protocolo. No expuesto.';
comment on schema geo is 'Territorio: comunas, barrios, espacios, zonas de amenaza, mediciones y organizaciones comunitarias. No expuesto.';
comment on schema ops is 'Operación: recomendaciones, decisiones, brechas, tareas, reportes y retornos. No expuesto.';
comment on schema idn is 'Identidad: perfiles, cargos, asignaciones y permisos. No expuesto.';
comment on schema aud is 'Auditoría append-only encadenada por hash. No expuesto.';
comment on schema api is 'Vistas y funciones que consume el frontend. ÚNICO esquema expuesto por PostgREST.';

-- Los 8 roles de aplicación menos `anon` (que es el rol de base de datos del público).
create type idn.rol_app as enum (
  'superusuario', 'gestion_riesgo', 'entidad_responsable', 'datic_tecnico',
  'comunitario', 'auditor', 'consulta'
);

-- Filtro de datos personales para textos libres (ADR-0008): rechaza correos, teléfonos y
-- secuencias numéricas largas (documentos, celulares). Es deliberadamente estricto.
create function idn.texto_limpio(p_texto text)
returns boolean
language sql
immutable
parallel safe
set search_path = ''
as $$
  select p_texto is null or (
    p_texto !~ '[^[:space:]@]+@[^[:space:]@]+'                      -- correo
    and regexp_replace(p_texto, '[ .\-_()]', '', 'g') !~ '[0-9]{7,}'   -- 7 o más dígitos seguidos
    and p_texto !~ '\+[0-9]{1,3}[ -]?[0-9]'                          -- prefijo internacional
  );
$$;
comment on function idn.texto_limpio(text) is
  'TRUE si el texto no parece contener correo, teléfono ni números largos. Se usa en CHECK de campos de texto libre.';

-- Referencias documentales (número de acto, acta, evidencia): admiten números largos como
-- "4112.010.20.0391", pero no correos ni prefijos telefónicos: solo letras, dígitos y . - / espacio º °.
create function idn.referencia_valida(p_ref text, p_max integer default 120)
returns boolean
language sql
immutable
parallel safe
set search_path = ''
as $$
  select p_ref is null or (p_ref ~ '^[[:alnum:] .\-/º°]+$' and char_length(p_ref) <= p_max);
$$;

-- Mantiene un solo sentido de cambio para tablas inmutables (recomendaciones, seguimientos...).
create function aud.bloquear_modificacion()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'La tabla %.% es de solo inserción: no admite % (ADR-0003/0006).',
    tg_table_schema, tg_table_name, tg_op
    using errcode = 'restrict_violation';
end;
$$;
