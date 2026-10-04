-- Hito 1 · Migración 7: semilla de catálogos. Va en migración (no en seed.sql) porque el proyecto `demo`
-- se construye solo con migraciones (ADR-0009). Todo lo institucional queda como 'propuesta':
-- NINGUNA fila está validada por la Secretaría de Gestión del Riesgo (docs/cumplimiento/ENTES_DECISORES.md).
-- No se inventan cifras ni plazos: lo desconocido es NULL.

-- ───────────── Amenazas (mismos códigos que la app) ─────────────
insert into ref.amenazas (codigo, nombre_es, activa_en_motor, nota) values
  ('flood',         'Inundación',               true,  'Cruce con capas fluvial y pluvial de IDESC.'),
  ('earthquake',    'Sismo',                    true,  'Cruce con licuación y efectos sísmicos; requiere inspección estructural antes de considerar activación.'),
  ('drought',       'Sequía / El Niño',         false, 'Sin datos de sequía y abastecimiento: el motor no recomienda.'),
  ('wildfire',      'Incendio forestal',        false, 'Sin capa de amenaza ni información vigente del incidente: solo requisitos de información.'),
  ('building-fire', 'Incendio en edificación',  false, 'Sin evidencia de evaluación estructural ni autorización de uso: solo requisitos de información. No sustituye a Bomberos.');

-- ───────────── Parámetros de planeación (fuente única; las reglas siguen en TypeScript) ─────────────
insert into ref.parametros_reglas (clave, version, valor, unidad, fuente_url, nota) values
  ('personas_por_bano',            1, 20,     'personas/baño',          'https://spherestandards.org/wp-content/uploads/Sphere-Handbook-2018-EN.pdf', 'Esfera 2018, saneamiento a medio plazo; referencia a contextualizar.'),
  ('litros_persona_dia',           1, 15,     'L/persona/día',          'https://spherestandards.org/wp-content/uploads/Sphere-Handbook-2018-EN.pdf', 'Esfera 2018, WASH 2.1. No son exclusivamente agua de uso no potable.'),
  ('m2_cubiertos_persona',         1, 3.5,    'm²/persona',             'https://spherestandards.org/wp-content/uploads/Sphere-Handbook-2018-EN.pdf', 'Esfera 2018, espacio habitable; mínimo a contextualizar.'),
  ('personas_maximas_escenario',   1, 100000, 'personas',               null, 'Tope del simulador (maqueta3d: planningView.maximumPeople). Coincide con el CHECK de ops.recomendaciones.'),
  ('umbral_supresion',             1, 5,      'conteo',                 null, 'PROPUESTA (§9.4): las vistas públicas ocultan conteos menores a este valor. Lo decide el responsable de la BD.');

-- ───────────── Entidades (propuesta; ENTES_DECISORES.md §3) ─────────────
insert into ref.entidades (codigo, nombre, nivel, competencia_resumen, norma_competencia) values
  ('ALCALDIA',           'Alcaldía de Santiago de Cali',                              'municipal',     'Responsable directo del manejo de desastres en el municipio; declara la calamidad pública con concepto del consejo.', 'Ley 1523 de 2012, arts. 12, 14 y 57'),
  ('CMGRD',              'Consejo Municipal de Gestión del Riesgo de Desastres',      'municipal',     'Coordina, asesora, planea y hace seguimiento; concepto previo a la calamidad pública.', 'Ley 1523 de 2012, arts. 27, 28 y 57'),
  ('SGRED',              'Secretaría de Gestión del Riesgo de Emergencias y Desastres', 'municipal',   'Owner del reto. Propuesta: decide la activación de espacios, dispara el protocolo, valida mediciones y cierra retornos.', 'Ley 1523 de 2012, art. 29 par. 1 (la función de decidir activaciones por la Secretaría es PROPUESTA: por verificar en su decreto de estructura)'),
  ('DATIC',              'Departamento Administrativo de las TIC (DATIC)',            'municipal',     'Líder técnico del reto; soporte de la plataforma y calidad de datos.', null),
  ('SALUD_PUBLICA',      'Secretaría de Salud Pública',                               'municipal',     'Define y opera el punto de salud; vigilancia en salud.', null),
  ('BIENESTAR_SOCIAL',   'Secretaría de Bienestar Social',                            'municipal',     'Atención social, ruta de niños, niñas y adolescentes, adultos mayores.', null),
  ('EDUCACION',          'Secretaría de Educación',                                   'municipal',     'Sedes educativas como espacios o apoyo; retorno a clases.', null),
  ('DEPORTE',            'Secretaría del Deporte y la Recreación',                    'municipal',     'Escenarios deportivos: disponibilidad y retorno.', null),
  ('INFRAESTRUCTURA',    'Secretaría de Infraestructura',                             'municipal',     'Adecuaciones permanentes y obras (con licencia).', null),
  ('SEGURIDAD_JUSTICIA', 'Secretaría de Seguridad y Justicia',                        'municipal',     'Seguridad del espacio y su entorno.', null),
  ('DAPM',               'Departamento Administrativo de Planeación Municipal',       'municipal',     'Datos del territorio (IDESC) y uso del espacio público.', null),
  ('UAE_BIENES',         'UAE de Gestión de Bienes y Servicios',                      'municipal',     'Administración de bienes públicos; inventario y logística de kits.', null),
  ('EMCALI',             'EMCALI',                                                    'operativo',     'Agua y energía.', null),
  ('UAESP',              'Unidad Administrativa Especial de Servicios Públicos (UAESP)', 'operativo',  'Saneamiento (baños) y servicios públicos. Competencia en Cali por confirmar.', null),
  ('BOMBEROS',           'Cuerpo de Bomberos',                                        'operativo',     'Concepto de seguridad humana y contra incendios. El sistema NO lo emite.', 'Ley 1523 de 2012, art. 28'),
  ('DEFENSA_CIVIL',      'Defensa Civil Colombiana',                                  'operativo',     'Apoyo operativo; integra el consejo.', 'Ley 1523 de 2012, art. 28'),
  ('CRUZ_ROJA',          'Cruz Roja Colombiana',                                      'operativo',     'Apoyo humanitario; integra el consejo.', 'Ley 1523 de 2012, art. 28'),
  ('POLICIA',            'Policía Nacional (comandante)',                             'operativo',     'Seguridad y orden público; integra el consejo.', 'Ley 1523 de 2012, art. 28'),
  ('CVC',                'Corporación Autónoma Regional del Valle del Cauca (CVC)',   'departamental', 'Datos del río Cauca, caudales y alertas hidrológicas; integra el consejo. Jurisdicción por verificar.', 'Ley 1523 de 2012, art. 28'),
  ('GOBERNACION_VALLE',  'Gobernación del Valle del Cauca',                           'departamental', 'Apoyo departamental; consejo departamental de gestión del riesgo.', 'Ley 1523 de 2012, art. 27'),
  ('UNGRD',              'Unidad Nacional para la Gestión del Riesgo de Desastres',   'nacional',      'Protocolo de alojamientos temporales y Registro Único de Damnificados (documento exacto por confirmar).', null),
  ('ICBF',               'Instituto Colombiano de Bienestar Familiar',                'nacional',      'Atención de niños, niñas y adolescentes. Competencia por verificar.', null),
  ('DEFENSORIA',         'Defensoría del Pueblo',                                     'nacional',      'Vigilancia de derechos. Competencia por verificar.', null),
  ('PERSONERIA',         'Personería de Cali',                                        'municipal',     'Vigilancia de derechos. Competencia por verificar.', null);

-- ───────────── Funciones del espacio (propuesta: amenazas aplicables por validar) ─────────────
insert into ref.funciones_espacio (codigo, fase, nombre_es, amenazas_aplicables, descripcion) values
  ('punto_reunion_inmediata', 'inmediata', 'Punto de reunión inmediata', array['earthquake','flood','wildfire','building-fire'], 'Primeras horas. Referente: Japón (2013), Turquía, Italia.'),
  ('albergue',                'temporal',  'Alojamiento temporal (albergue)', array['earthquake','flood'], 'Días o semanas.'),
  ('acopio',                  'temporal',  'Centro de acopio',            array['earthquake','flood'], 'Recepción y despacho de insumos. Por decidir si va dentro del albergue (como en la maqueta) o aparte (§9.9).'),
  ('punto_agua',              'apoyo',     'Punto de agua',               array['earthquake','flood','drought'], 'Distribución de agua para necesidades básicas.'),
  ('punto_salud',             'apoyo',     'Punto de salud',              array['earthquake','flood'], 'Lo define y opera la Secretaría de Salud Pública.'),
  ('punto_informacion',       'apoyo',     'Punto de información',        array['earthquake','flood','drought','wildfire','building-fire'], 'Información oficial a la comunidad. No emite alertas.'),
  ('amortiguacion',           'apoyo',     'Amortiguación',               array['earthquake','flood'], 'Espacio que absorbe agua o descongestiona. Referentes: Róterdam, Copenhague.');

-- ───────────── Servicios y tareas ─────────────
insert into ref.servicios (codigo, nombre_es, tipo, unidad, amenaza_codigo, parametro_clave, atributo_medicion, regla_texto) values
  ('toilets', 'Baños',                              'cuantitativo', 'baños', null, 'personas_por_bano',     'banos',
     'Redondeo superior de personas / 20; referencia de planificación a medio plazo.'),
  ('water',   'Agua para necesidades básicas',      'cuantitativo', 'L/día', null, 'litros_persona_dia',    'agua_l_dia',
     'Personas × 15 L/día; adaptar a contexto y usos. No representa exclusivamente agua de uso no potable.'),
  ('shelter', 'Superficie cubierta habitable',      'cuantitativo', 'm²',    null, 'm2_cubiertos_persona',  null,
     'Personas × 3,5 m²; referencia mínima a contextualizar. La huella del predio no demuestra área cubierta útil.');

insert into ref.servicios (codigo, nombre_es, tipo, amenaza_codigo, regla_texto) values
  ('animals', 'Atención de animales de compañía', 'tarea_evidencia', null,
     'Tarea sin cifra: no hay estándar verificado para animales de compañía. Respaldo: Ley 2474 de 2025, arts. 3, 11 y 12. Los animales de servicio siempre se admiten.'),
  ('wildfire-perimeter',   'Área afectada y restricciones',                  'tarea_evidencia', 'wildfire',      'Falta geometría del incidente con fuente, fecha y restricciones de la autoridad.'),
  ('wildfire-access',      'Acceso y evacuación',                            'tarea_evidencia', 'wildfire',      'Faltan accesos utilizables y restricciones de circulación verificadas.'),
  ('wildfire-vegetation',  'Amenaza e interfaz con vegetación',              'tarea_evidencia', 'wildfire',      'Falta cartografía verificada de amenaza forestal, cobertura y fecha.'),
  ('wildfire-smoke',       'Humo y condiciones del entorno',                 'tarea_evidencia', 'wildfire',      'Falta información vigente de humo, viento y restricciones aplicables.'),
  ('building-fire-perimeter',   'Área afectada y restricciones',             'tarea_evidencia', 'building-fire', 'Falta geometría del incidente con fuente, fecha y restricciones de la autoridad.'),
  ('building-fire-access',      'Acceso y evacuación',                       'tarea_evidencia', 'building-fire', 'Faltan accesos utilizables y restricciones de circulación verificadas.'),
  ('building-fire-building',    'Edificación afectada y entorno',            'tarea_evidencia', 'building-fire', 'Falta identificar el edificio afectado y su perímetro de restricción.'),
  ('building-fire-inspection',  'Inspecciones y condiciones para el uso',    'tarea_evidencia', 'building-fire', 'Sin evidencia de evaluación estructural ni autorización de uso. La plataforma no emite conceptos.');

-- ───────────── Matriz de responsabilidades (propuesta sin validar; docs/propuesta_cali_activa.md) ─────────────
insert into ref.responsabilidades (servicio_codigo, entidad_id, contexto, papel, bloquea_activacion, fuente)
select v.servicio, e.id, v.contexto, 'lidera', v.bloquea,
       'docs/propuesta_cali_activa.md — Matriz de entidades responsables (propuesta sin validar)'
from (values
  ('toilets', 'UAESP',  'albergue',    true),
  ('water',   'EMCALI', 'albergue',    true),
  ('water',   'EMCALI', 'punto_salud', true),
  ('shelter', 'SGRED',  'albergue',    false)
) as v (servicio, entidad, contexto, bloquea)
join ref.entidades e on e.codigo = v.entidad;

-- ───────────── Protocolo de activación (plantilla propuesta; sin plazos verificados) ─────────────
insert into ref.protocolo_plantillas (nombre, amenaza_codigo) values
  ('Activación de un espacio (propuesta del equipo)', null);

insert into ref.protocolo_pasos (plantilla_id, orden, titulo, descripcion, entidad_id, servicio_codigo, bloquea_activacion)
select p.id, v.orden, v.titulo, v.descripcion, e.id, v.servicio, v.bloquea
from ref.protocolo_plantillas p
cross join (values
  (1, 'Confirmar alerta oficial y acto administrativo',
      'El sistema no emite alertas: confirmar la alerta de IDEAM, CVC, SGC u otra autoridad y el acto que respalda la activación.', 'SGRED', null, false),
  (2, 'Verificar bloqueantes del espacio',
      'Cruce de amenaza y evaluación estructural vigente. La plataforma no emite conceptos estructurales.', 'SGRED', null, true),
  (3, 'Saneamiento: baños',
      'Cubrir la brecha de baños frente a la regla vigente.', 'UAESP', 'toilets', true),
  (4, 'Agua para necesidades básicas',
      'Cubrir la brecha de agua frente a la regla vigente.', 'EMCALI', 'water', true),
  (5, 'Superficie cubierta habitable',
      'Cubrir o reubicar la brecha de área cubierta.', 'SGRED', 'shelter', false),
  (6, 'Ruta de protección de niños, niñas y adolescentes',
      'Activar con menores presentes. Participación de ICBF por verificar.', 'BIENESTAR_SOCIAL', null, false),
  (7, 'Atención en salud',
      'Activar el punto de salud y la ruta de adultos mayores.', 'SALUD_PUBLICA', null, false),
  (8, 'Seguridad del albergue',
      'Seguridad del espacio y su entorno.', 'SEGURIDAD_JUSTICIA', null, false),
  (9, 'Atención de animales de compañía',
      'Entidad por definir (Ley 2474 de 2025). Los animales de servicio siempre se admiten.', null, 'animals', false),
  (10, 'Inventario y logística de kits',
      'Inventario, despacho y recepción de kits.', 'UAE_BIENES', null, false),
  (11, 'Registro nominal de personas',
      'Lo custodia la entidad responsable y se conecta al RUD de la UNGRD; esta plataforma NO guarda datos de personas damnificadas.', null, null, false)
) as v (orden, titulo, descripcion, entidad, servicio, bloquea)
left join ref.entidades e on e.codigo = v.entidad
where p.nombre = 'Activación de un espacio (propuesta del equipo)';
