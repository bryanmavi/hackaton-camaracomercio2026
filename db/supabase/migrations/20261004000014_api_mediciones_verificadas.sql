-- Conexión de la app · Migración 14: mediciones verificadas vigentes por la API (ligera, pública).
-- La app las necesita para llenar capacidad, baños, agua y disponibilidad de los 2.991 espacios sin pedir
-- api.espacio_ficha completa (que calcula los cruces de amenaza de cada espacio). Solo lo VERIFICADO es público.

create view api.mediciones_verificadas with (security_invoker = true) as
  select espacio_id, atributo, valor_num, valor_bool, valor_texto, valor_fecha, unidad, validado_en, es_simulado
  from geo.mediciones_vigentes;
comment on view api.mediciones_verificadas is
  'Última medición verificada por espacio y atributo. Sin fila = desconocido, nunca cero.';

grant select on api.mediciones_verificadas to anon, authenticated;

-- Orden de la fuente: la app muestra listas y dibuja el mapa en el orden de los archivos de la IDESC.
-- Lo llena scripts/cargar_datos_reales.mjs (posición en el archivo). NULL en registros que no vienen de una carga.
alter table geo.espacios add column orden_fuente integer;
alter table geo.comunas  add column orden_fuente integer;
alter table geo.barrios  add column orden_fuente integer;

-- Columnas nuevas AL FINAL de las vistas (create or replace solo permite añadir al final).
create or replace view api.espacios with (security_invoker = true) as
  select id, nombre, tipo, condicion, comuna_codigo, barrio_nombre, limite_ambiguo,
         extensions.st_x(punto) as lon, extensions.st_y(punto) as lat, area_m2,
         estado_proteccion_uso, fuente_clave, metodo_evaluacion, es_simulado,
         comuna_fuente, barrio_fuente, orden_fuente
  from geo.espacios;

create or replace view api.comunas with (security_invoker = true) as
  select codigo, nombre, extensions.st_asgeojson(geom)::jsonb as geometria, fuente_clave, orden_fuente from geo.comunas;

create or replace view api.barrios with (security_invoker = true) as
  select codigo, nombre, comuna_codigo, extensions.st_asgeojson(geom)::jsonb as geometria, fuente_clave, orden_fuente
  from geo.barrios;
