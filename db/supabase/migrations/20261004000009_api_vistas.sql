-- Hito 1 · Migración 9: vistas del esquema `api` (única superficie expuesta, ADR-0002).
-- Todas con security_invoker = true: respetan la RLS de quien consulta. La única excepción deliberada es
-- api.resumen_territorial (agregados con supresión de celdas pequeñas).
-- Los códigos (flood, toilets...) coinciden con los de la app para que el frontend no traduzca.

-- ───────────── Catálogos y territorio (públicos) ─────────────
create view api.amenazas with (security_invoker = true) as
  select codigo, nombre_es, activa_en_motor, nota from ref.amenazas;

create view api.servicios with (security_invoker = true) as
  select codigo, nombre_es, tipo, unidad, amenaza_codigo, parametro_clave, atributo_medicion, regla_texto
  from ref.servicios;

create view api.funciones_espacio with (security_invoker = true) as
  select codigo, fase, nombre_es, amenazas_aplicables, descripcion, estado_validacion from ref.funciones_espacio;

create view api.fuentes with (security_invoker = true) as
  select clave, nombre, entidad, pagina_fuente, url_descarga, licencia, compartir_igual, atribucion,
         fecha_corte, sha256, n_registros
  from ref.fuentes;

create view api.entidades with (security_invoker = true) as
  select e.codigo, e.nombre, e.nivel, p.codigo as padre_codigo, e.vigente_desde, e.vigente_hasta,
         s.codigo as sucesora_codigo, e.competencia_resumen, e.norma_competencia, e.estado_validacion,
         (e.vigente_hasta is null or e.vigente_hasta >= current_date) as vigente
  from ref.entidades e
  left join ref.entidades p on p.id = e.padre_id
  left join ref.entidades s on s.id = e.sucesora_id;

create view api.responsabilidades with (security_invoker = true) as
  select r.servicio_codigo, e.codigo as entidad_codigo, e.nombre as entidad_nombre, r.contexto, r.papel,
         r.bloquea_activacion, r.estado_validacion, r.fuente
  from ref.responsabilidades r join ref.entidades e on e.id = r.entidad_id;

create view api.parametros_reglas with (security_invoker = true) as
  select clave, version, valor, unidad, fuente_url, nota, vigente_desde
  from ref.parametros_reglas where vigente;

create view api.comunas with (security_invoker = true) as
  select codigo, nombre, extensions.st_asgeojson(geom)::jsonb as geometria, fuente_clave from geo.comunas;

create view api.barrios with (security_invoker = true) as
  select codigo, nombre, comuna_codigo, extensions.st_asgeojson(geom)::jsonb as geometria, fuente_clave from geo.barrios;

create view api.espacios with (security_invoker = true) as
  select id, nombre, tipo, condicion, comuna_codigo, barrio_nombre, limite_ambiguo,
         extensions.st_x(punto) as lon, extensions.st_y(punto) as lat, area_m2,
         estado_proteccion_uso, fuente_clave, metodo_evaluacion, es_simulado
  from geo.espacios;

create view api.espacio_huellas with (security_invoker = true) as
  select id, extensions.st_asgeojson(huella)::jsonb as geometria from geo.espacios where huella is not null;

create view api.zonas_amenaza with (security_invoker = true) as
  select id, amenaza_tipo, etiqueta, fuente_clave, atributos, extensions.st_asgeojson(geom)::jsonb as geometria
  from geo.zonas_amenaza;

create view api.espacio_exposicion with (security_invoker = true) as
  select espacio_id, zona_id, amenaza_tipo, etiqueta, fuente_clave from geo.espacio_exposicion;

-- Ficha pública: datos de la fuente + la última medición VERIFICADA (sin fila = desconocido, nunca cero).
create view api.espacio_ficha with (security_invoker = true) as
select e.id, e.nombre, e.tipo, e.condicion, e.comuna_codigo, e.barrio_nombre, e.limite_ambiguo,
       extensions.st_x(e.punto) as lon, extensions.st_y(e.punto) as lat, e.area_m2,
       e.estado_proteccion_uso, e.fuente_clave, e.metodo_evaluacion, e.es_simulado,
       m.capacidad_personas, m.banos, m.agua_l_dia, m.capacidad_animales,
       m.evaluacion_estructural_vigente, m.evaluacion_estructural_fecha,
       m.accesibilidad, m.energia_respaldo, m.acepta_animales_compania, m.zona_animales,
       coalesce(m.disponibilidad, 'Por confirmar con la entidad responsable') as disponibilidad,
       m.administracion_acceso, m.horario,
       exists (select 1 from geo.espacio_exposicion x where x.espacio_id = e.id and x.amenaza_tipo = 'inundacion_fluvial') as cruce_inundacion_fluvial,
       exists (select 1 from geo.espacio_exposicion x where x.espacio_id = e.id and x.amenaza_tipo = 'inundacion_pluvial') as cruce_inundacion_pluvial,
       exists (select 1 from geo.espacio_exposicion x where x.espacio_id = e.id and x.amenaza_tipo = 'no_mitigable')       as cruce_no_mitigable,
       exists (select 1 from geo.espacio_exposicion x where x.espacio_id = e.id and x.amenaza_tipo = 'licuacion')          as cruce_licuacion,
       exists (select 1 from geo.espacio_exposicion x where x.espacio_id = e.id and x.amenaza_tipo = 'efectos_sismicos')   as cruce_efectos_sismicos
from geo.espacios e
left join lateral (
  select
    max(v.valor_num)   filter (where v.atributo = 'capacidad_personas')            as capacidad_personas,
    max(v.valor_num)   filter (where v.atributo = 'banos')                         as banos,
    max(v.valor_num)   filter (where v.atributo = 'agua_l_dia')                    as agua_l_dia,
    max(v.valor_num)   filter (where v.atributo = 'capacidad_animales')            as capacidad_animales,
    bool_or(v.valor_bool) filter (where v.atributo = 'evaluacion_estructural_vigente') as evaluacion_estructural_vigente,
    max(v.valor_fecha) filter (where v.atributo = 'evaluacion_estructural_vigente') as evaluacion_estructural_fecha,
    bool_or(v.valor_bool) filter (where v.atributo = 'accesibilidad')              as accesibilidad,
    bool_or(v.valor_bool) filter (where v.atributo = 'energia_respaldo')           as energia_respaldo,
    bool_or(v.valor_bool) filter (where v.atributo = 'acepta_animales_compania')   as acepta_animales_compania,
    bool_or(v.valor_bool) filter (where v.atributo = 'zona_animales')              as zona_animales,
    max(v.valor_texto) filter (where v.atributo = 'disponibilidad')                as disponibilidad,
    max(v.valor_texto) filter (where v.atributo = 'administracion_acceso')         as administracion_acceso,
    max(v.valor_texto) filter (where v.atributo = 'horario')                       as horario
  from geo.mediciones_vigentes v
  where v.espacio_id = e.id
) m on true;
comment on view api.espacio_ficha is
  'Ficha pública. "Sin cruce" no significa "sin amenaza"; null significa desconocido, no cero.';

-- ───────────── Operación (según RLS del invocador) ─────────────
create view api.mi_perfil with (security_invoker = true) as
  select p.user_id, p.rol, c.nombre as cargo, e.codigo as entidad_codigo, e.nombre as entidad_nombre,
         p.organizacion_id, p.zona_comunas, p.zona_barrios, p.alias_visible, p.mfa_requerido,
         idn.es_aal2() as aal2, idn.mis_permisos() as permisos
  from idn.perfiles p
  left join idn.cargos c on c.id = p.cargo_id
  left join ref.entidades e on e.id = p.entidad_id
  where p.user_id = auth.uid() and p.activo;

create view api.usuarios_minimo with (security_invoker = true) as
  select user_id, rol, alias_visible, entidad_id, organizacion_id, activo, es_simulado
  from idn.perfiles;

create view api.decisiones with (security_invoker = true) as
  select d.id, d.recomendacion_id, d.espacio_id, es.nombre as espacio_nombre, d.amenaza_codigo, d.funcion,
         d.acto_tipo, d.acto_numero, d.acto_fecha, d.justificacion, c.nombre as cargo_nombre,
         d.decidida_en, d.estado, d.personas_estimadas, d.es_simulado
  from ops.decisiones_activacion d
  join geo.espacios es on es.id = d.espacio_id
  left join idn.cargos c on c.id = d.cargo_id;

create view api.brechas with (security_invoker = true) as
  select b.id, b.decision_id, b.espacio_id, b.servicio_codigo, s.nombre_es as servicio_nombre,
         b.requerido, b.unidad, b.existente, b.faltante, e.codigo as entidad_codigo, e.nombre as entidad_nombre,
         b.estado, b.regla_texto, b.version_reglas,
         coalesce(r.bloquea_activacion, false) as bloquea_activacion, b.es_simulado
  from ops.brechas b
  join ref.servicios s on s.codigo = b.servicio_codigo
  join ops.decisiones_activacion d on d.id = b.decision_id
  left join ref.entidades e on e.id = b.entidad_responsable_id
  left join ref.responsabilidades r
         on r.servicio_codigo = b.servicio_codigo and r.contexto = d.funcion and r.papel = 'lidera';

create view api.mis_tareas with (security_invoker = true) as
  select t.id, t.decision_id, d.espacio_id, p.orden, p.titulo, p.descripcion, p.bloquea_activacion,
         e.codigo as entidad_codigo, t.estado, t.vence_en, t.completada_en, t.nota, t.es_simulado
  from ops.tareas_protocolo t
  join ref.protocolo_pasos p on p.id = t.paso_id
  join ops.decisiones_activacion d on d.id = t.decision_id
  left join ref.entidades e on e.id = t.entidad_id;

create view api.reportes_comunitarios with (security_invoker = true) as
  select r.id, r.organizacion_id, o.nombre as organizacion_nombre, o.comuna_codigo, r.espacio_id, r.tipo,
         r.n_total, r.n_0_5, r.n_6_17, r.n_18_59, r.n_60_mas, r.n_discapacidad, r.n_animales_compania,
         r.estado_servicios, r.observacion, r.creado_en, r.es_simulado
  from ops.reportes_comunitarios r
  join geo.organizaciones_comunitarias o on o.id = r.organizacion_id;

create view api.auditoria with (security_invoker = true) as
  select id, ocurrido_en, actor_uuid, actor_rol, tabla, operacion, fila_id, cambios from aud.eventos;

-- Agregados por comuna con supresión de celdas pequeñas (ADR-0008). NO es security_invoker a propósito:
-- los conteos operativos se ocultan (NULL) cuando son menores al umbral `umbral_supresion`.
create view api.resumen_territorial with (security_invoker = false) as
with umbral as (
  select coalesce((select valor from ref.parametros_reglas where clave = 'umbral_supresion' and vigente), 5) as n
)
select c.codigo as comuna_codigo, c.nombre as comuna_nombre,
       (select count(*) from geo.espacios e where e.comuna_codigo = c.codigo) as n_espacios,
       (select count(distinct x.espacio_id) from geo.espacio_exposicion x join geo.espacios e on e.id = x.espacio_id
         where e.comuna_codigo = c.codigo and x.amenaza_tipo in ('inundacion_fluvial', 'inundacion_pluvial')) as n_espacios_cruce_inundacion,
       (select count(distinct x.espacio_id) from geo.espacio_exposicion x join geo.espacios e on e.id = x.espacio_id
         where e.comuna_codigo = c.codigo and x.amenaza_tipo in ('licuacion', 'efectos_sismicos')) as n_espacios_cruce_sismico,
       (select case when q.n >= (select n from umbral) then q.n end
          from (select count(*) as n from ops.decisiones_activacion d join geo.espacios e on e.id = d.espacio_id
                where e.comuna_codigo = c.codigo and d.estado = 'vigente') q) as decisiones_vigentes,
       (select case when q.n >= (select n from umbral) then q.n end
          from (select count(*) as n from ops.reportes_comunitarios r
                join geo.organizaciones_comunitarias o on o.id = r.organizacion_id
                where o.comuna_codigo = c.codigo and r.creado_en >= now() - interval '30 days') q) as reportes_ultimos_30_dias
from geo.comunas c;
comment on view api.resumen_territorial is
  'Agregados por comuna. Los conteos operativos menores al umbral salen NULL (supresión de celdas pequeñas).';
