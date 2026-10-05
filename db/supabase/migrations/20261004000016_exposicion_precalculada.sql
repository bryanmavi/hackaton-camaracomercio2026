-- Rendimiento · Migración 16: cruces espacio × zona de amenaza precalculados.
-- geo.espacio_exposicion (vista) recalcula ST_Intersects de toda la ciudad en cada consulta: ~0,9 s por página.
-- Los cruces solo cambian cuando se recargan espacios o zonas, así que se guardan en una vista materializada que
-- scripts/cargar_datos_reales.mjs refresca DENTRO de la misma transacción de la carga. La vista original queda como
-- fuente de verdad (las pruebas comparan ambas) y la usa la ficha de un solo espacio.

create materialized view geo.exposicion_cache as
  select espacio_id, zona_id, amenaza_tipo, etiqueta, fuente_clave from geo.espacio_exposicion
with data;
create unique index exposicion_cache_pk on geo.exposicion_cache (zona_id, espacio_id);
create index exposicion_cache_espacio_ix on geo.exposicion_cache (espacio_id, amenaza_tipo);
comment on materialized view geo.exposicion_cache is
  'Copia precalculada de geo.espacio_exposicion. Se refresca al cargar datos (geo.refrescar_exposicion). Datos abiertos.';

-- Solo el dueño (la carga) refresca; nadie de la API puede hacerlo.
create function geo.refrescar_exposicion()
returns void
language sql
security definer
set search_path = ''
as $$ refresh materialized view geo.exposicion_cache $$;
revoke all on function geo.refrescar_exposicion() from public, anon, authenticated;

create or replace view api.espacio_exposicion with (security_invoker = true) as
  select espacio_id, zona_id, amenaza_tipo, etiqueta, fuente_clave from geo.exposicion_cache;

-- El resumen por comuna también lee los cruces precalculados (mismas columnas, misma supresión).
create or replace view api.resumen_territorial with (security_invoker = false) as
with umbral as (
  select coalesce((select valor from ref.parametros_reglas where clave = 'umbral_supresion' and vigente), 5) as n
)
select c.codigo as comuna_codigo, c.nombre as comuna_nombre,
       (select count(*) from geo.espacios e where e.comuna_codigo = c.codigo) as n_espacios,
       (select count(distinct x.espacio_id) from geo.exposicion_cache x join geo.espacios e on e.id = x.espacio_id
         where e.comuna_codigo = c.codigo and x.amenaza_tipo in ('inundacion_fluvial', 'inundacion_pluvial')) as n_espacios_cruce_inundacion,
       (select count(distinct x.espacio_id) from geo.exposicion_cache x join geo.espacios e on e.id = x.espacio_id
         where e.comuna_codigo = c.codigo and x.amenaza_tipo in ('licuacion', 'efectos_sismicos')) as n_espacios_cruce_sismico,
       (select case when q.n >= (select n from umbral) then q.n end
          from (select count(*) as n from ops.decisiones_activacion d join geo.espacios e on e.id = d.espacio_id
                where e.comuna_codigo = c.codigo and d.estado = 'vigente') q) as decisiones_vigentes,
       (select case when q.n >= (select n from umbral) then q.n end
          from (select count(*) as n from ops.reportes_comunitarios r
                join geo.organizaciones_comunitarias o on o.id = r.organizacion_id
                where o.comuna_codigo = c.codigo and r.creado_en >= now() - interval '30 days') q) as reportes_ultimos_30_dias
from geo.comunas c;

grant select on geo.exposicion_cache to anon, authenticated;
