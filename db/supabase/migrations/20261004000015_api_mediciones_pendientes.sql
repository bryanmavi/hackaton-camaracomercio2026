-- Conexión de la app · Migración 15: mediciones declaradas pendientes de validar, para la pestaña Operación.
-- La vista respeta la RLS de quien consulta (gestion_riesgo, entidades y auditor: todas; comunitario: su zona).
-- No expone quién reportó ni quién validó: solo si la medición es propia (cuatro ojos) y si el rol puede validarla.
-- La autorización real sigue en api.validar_medicion: estos indicadores son solo para mostrar u ocultar botones.

create function idn.puede_validar_atributo(p_atributo text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select case p.rol
    when 'gestion_riesgo' then true
    when 'entidad_responsable' then exists (
      select 1 from ref.servicios s join ref.responsabilidades r on r.servicio_codigo = s.codigo
      where s.atributo_medicion = p_atributo and r.entidad_id = p.entidad_id and r.papel in ('lidera', 'valida'))
    else false
  end
  from idn.perfil_actual() p
  where idn.authorize('medicion.validar');
$$;
revoke all on function idn.puede_validar_atributo(text) from public, anon;
grant execute on function idn.puede_validar_atributo(text) to authenticated;

create view api.mediciones_pendientes with (security_invoker = true) as
  select m.id, m.espacio_id, e.nombre as espacio_nombre, e.comuna_codigo, m.atributo,
         m.valor_num, m.valor_bool, m.valor_texto, m.valor_fecha, m.unidad, m.fuente_texto, m.evidencia_ref,
         m.reportado_en, m.es_simulado,
         m.reportado_por = auth.uid() as propia,
         coalesce(idn.puede_validar_atributo(m.atributo), false) and m.reportado_por is distinct from auth.uid() as puedo_validar
  from geo.mediciones_espacio m
  join geo.espacios e on e.id = m.espacio_id
  where m.estado = 'declarado';
comment on view api.mediciones_pendientes is
  'Mediciones declaradas sin validar, según el alcance de quien consulta. Validar: api.validar_medicion.';

grant select on api.mediciones_pendientes to authenticated;

-- La ficha pública NO muestra mediciones simuladas (las de las cuentas de demostración): un parque real no puede
-- aparecer con "4 baños" porque una cuenta demo lo declaró. Lo simulado sigue visible, marcado, en
-- api.mediciones_verificadas (columna es_simulado) y en la pestaña Operación.
create or replace view api.espacio_ficha with (security_invoker = true) as
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
  where v.espacio_id = e.id and not v.es_simulado   -- lo simulado nunca aparece como dato real en la ficha pública
) m on true;
comment on view api.espacio_ficha is
  'Ficha pública con mediciones verificadas REALES (sin simuladas). Sin cruce no significa sin amenaza; null es desconocido, no cero.';
