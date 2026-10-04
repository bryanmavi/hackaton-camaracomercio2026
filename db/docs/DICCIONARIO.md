# Diccionario de datos (Hito 1, para revisión)

> Convenciones: `PK` llave primaria, `FK` llave foránea, `NULL` = desconocido (nunca cero). Clases de dato: **Público** (datos abiertos o catálogos), **Interno** (operativo no personal), **Restringido** (cuentas, auditoría, reportes comunitarios) y **Crítico** (claves y secretos: nunca en el repo ni en la BD de aplicación).
> Los tipos son orientativos; el Hito 2 los fija en SQL. El fundamento legal de cada tabla se cierra en el Hito 4 contra el texto primario (ver `docs/cumplimiento/FUENTES.md`).

## 0. Cambios al pasar a SQL (4 de octubre de 2026)

El borrador de `db/supabase/migrations/` sigue este diccionario con estos ajustes, todos pendientes de tu revisión:

| Dónde | Cambio | Por qué |
|---|---|---|
| `geo.mediciones_espacio` | Nueva columna `valor_bool` para los atributos sí/no (accesibilidad, energía, animales, evaluación estructural) | No guardar "sí" o "no" como texto libre. La evaluación estructural es `valor_bool` más `valor_fecha` y no admite texto, porque no hay concepto técnico |
| `geo.mediciones_espacio` | CHECK `validado_por <> reportado_por` | Cuatro ojos: quien reporta no valida |
| `ref.servicios` | Nueva columna `atributo_medicion` (`toilets` → `banos`, `water` → `agua_l_dia`) | El "existente" de una brecha sale de la última medición **verificada**, y define qué entidad valida cada atributo |
| `ref.servicios` | Servicio `building-fire-perimeter` agregado | La app (`fire.ts`) también lo pide en incendio de edificación |
| `ref.funciones_espacio` | Columna `estado_validacion` (`propuesta`) | Las amenazas en que aplica cada función no están validadas |
| `ref.parametros_reglas` | `fuente_url` admite nulo y se agrega `nota` | El tope de 100.000 y el umbral N no tienen URL externa |
| `ref.responsabilidades` | Índice único: una sola entidad `lidera` cada servicio en cada contexto; `contexto` es una FK a `ref.funciones_espacio` | De ahí se asigna la brecha sin ambigüedad |
| `ref.protocolo_plantillas` | Columna `vigente` | Para versionar el protocolo sin borrar |
| `ref.protocolo_pasos` | `entidad_id` y `plazo_ref_horas` pueden ser `NULL` | Animales y registro nominal no tienen entidad verificada, y ningún plazo tiene fuente |
| `ops.decisiones_activacion` | Columna `decidida_en` | Fecha del registro, distinta de `acto_fecha` |
| `ops.retornos` | Columna `cerrado_por` | Trazabilidad de quién cerró |
| `ops.brechas` | `entidad_responsable_id` admite `NULL` | Un servicio sin responsable verificado queda "sin asignar", no se inventa |
| `ops.notificaciones` | Columna `creado_en` | Orden de los borradores |
| `idn.perfiles` | `user_id` **sin** FK a `auth.users` | Para borrar la cuenta en Auth al suprimir un titular sin perder el registro institucional que apunta a ella |
| `idn.rol_permisos` | Columna `requiere_aal2` | MFA por permiso (`decision.activar`, `usuarios.gestionar`) |
| `acto_numero`, `acta_ref`, `evidencia_ref` | Filtro propio (`idn.referencia_valida`): letras, dígitos y `. - / º °`, sin `@` ni `+` | El filtro general rechazaría números de decreto como `4112.010.20.0391` |
| Escrituras | Ningún rol de API tiene INSERT, UPDATE ni DELETE: todo pasa por funciones `api.*` | Una sola puerta, que verifica permiso, alcance y MFA |
| Autorización | El rol y la vigencia se leen de `idn.perfiles` en cada consulta, no del JWT | Suspender o cambiar el rol surte efecto de inmediato |
| `geo.organizaciones_comunitarias` | Nueva columna `id_fuente` (`oacid` de la JAC), única por fuente (migración 12) | Recargar el dataset sin duplicar |
| `geo.zonas_amenaza` | `atributos` guarda de qué script se derivó la capa y, en licuación, el filtro (`sucep_licu > 0 o corrim_lat > 0`) | Se cargan las capas de la app (5 de 16 polígonos de licuación), para que los cruces sean idénticos |
| `geo.espacios`, `geo.comunas`, `geo.barrios` | Columna `orden_fuente` (migración 14) | La app muestra listas y mapa en el orden de los archivos de la IDESC |
| `api.mediciones_verificadas` | Vista nueva (migración 14) | Lectura ligera de lo verificado para los 2.991 espacios |
| `api.mediciones_pendientes` | Vista nueva (migración 15), con `propia` y `puedo_validar` | Validación desde la app sin exponer quién reportó |
| `api.espacio_ficha` | Excluye las mediciones simuladas (migración 15) | Un parque real no puede mostrar datos inventados por una cuenta demo |
| `geo.exposicion_cache` | Vista materializada de los cruces (migración 16); `geo.refrescar_exposicion()` solo la ejecuta el dueño | La API dejó de recalcular los cruces de toda la ciudad en cada página |
| Auditoría | `ops.lecturas_iot` no se audita | Simulada, de alto volumen y con 30 días de retención |

## `ref`: catálogos

### `ref.fuentes` · Público
Una fila por conjunto de datos abiertos. Reproduce `maqueta3d/public/data/manifest.json`.
| Columna | Tipo | Nulo | Descripción |
|---|---|---|---|
| clave | text PK | no | `publicSpaces`, `sports`, `communes`, `neighborhoods`, `fluvial`, `pluvial`, `nonMitigable`, `liquefaction`, `seismicEffects`, `jac`... |
| nombre | text | no | Nombre del conjunto de datos |
| entidad | text | no | Entidad publicadora (DAPM/IDESC, Secretaría del Deporte...) |
| pagina_fuente | text | no | URL de la página de origen |
| url_descarga | text | sí | URL de descarga (WFS u otra) |
| licencia | text | no | `CC BY` o `CC BY-SA` |
| compartir_igual | boolean | no | `true` si la licencia exige compartir igual |
| atribucion | text | no | Texto de atribución obligatorio |
| fecha_corte | date | no | Fecha del snapshot (hoy 2026-09-25) |
| sha256 | char(64) | sí | Huella del archivo archivado |
| n_registros | integer | sí | Conteo esperado (para validar la carga) |
| es_simulado | boolean | no | Siempre `false` en fuentes reales |

### `ref.entidades` · Público
| Columna | Tipo | Nulo | Descripción |
|---|---|---|---|
| id | bigint PK | no | Identidad |
| codigo | text único | no | `SGRED`, `DATIC`, `EMCALI`, `UAESP`... |
| nombre | text | no | Nombre oficial |
| nivel | text | no | `municipal`, `departamental`, `nacional`, `operativo`, `comunitario`, `privado` |
| padre_id | bigint FK | sí | Dependencia superior |
| vigente_desde / vigente_hasta | date | sí / sí | Las secretarías se reorganizan: se cierra la vigencia, no se borra |
| sucesora_id | bigint FK | sí | Entidad que la reemplaza |
| competencia_resumen | text | no | Qué le toca en una emergencia |
| norma_competencia | text | sí | Norma que lo respalda (se completa en H4) |
| estado_validacion | text | no | `propuesta` o `validada` |

### `ref.amenazas` · Público
`codigo` PK (`flood`, `earthquake`, `drought`, `wildfire`, `building-fire`), `nombre_es`, `activa_en_motor` (false para `drought`: sin datos suficientes), `nota`.

### `ref.servicios` · Público
`codigo` PK (`toilets`, `water`, `shelter`, `wildfire-perimeter`, `wildfire-access`, `wildfire-vegetation`, `wildfire-smoke`, `building-fire-access`, `building-fire-building`, `building-fire-inspection`, `animals`...), `nombre_es`, `tipo` (`cuantitativo` o `tarea_evidencia`), `unidad` (`baños`, `L/día`, `m²`, nulo en tareas), `amenaza_codigo` FK (nulo en servicios generales), `parametro_clave` (a `ref.parametros_reglas`), `regla_texto`. **`animals`** (atención de animales de compañía) es una tarea **sin cifra**: no se verificó un estándar tipo Esfera para mascotas y no se inventa uno. Respaldo: Ley 2474 de 2025, arts. 3, 11 (protocolos sectoriales, incluido el alojamiento temporal de animales) y 12 (planes territoriales).

### `ref.responsabilidades` · Público
PK compuesta (`servicio_codigo`, `entidad_id`, `contexto`). `papel` (`lidera`, `apoya`, `valida`), `bloquea_activacion` (boolean), `contexto` (`albergue`, `punto_salud`...), `estado_validacion` (`propuesta` hasta que la Secretaría la valide), `fuente`. Semilla inicial: la matriz "propuesta sin validar" de `docs/propuesta_cali_activa.md` (baños: UAESP; agua y energía: EMCALI; superficie cubierta: Gestión del Riesgo).

### `ref.funciones_espacio` · Público
Distingue **fases** (hallazgo de Japón, Turquía e Italia; `docs/referentes/REFERENTES_INTERNACIONALES.md`). PK `codigo`: `punto_reunion_inmediata` (fase `inmediata`, horas), `albergue` (fase `temporal`, días o semanas), `acopio`, `punto_agua`, `punto_salud`, `punto_informacion`, `amortiguacion` (fase `apoyo`). Columnas: `fase` (`inmediata`, `temporal`, `apoyo`), `nombre_es`, `amenazas_aplicables` (text[] de `ref.amenazas`), `descripcion`. Un espacio puede ser apto para una función y una amenaza, y no para otra. `ops.decisiones_activacion.funcion` referencia esta tabla.

### `ref.parametros_reglas` · Público
PK (`clave`, `version`). `valor` numeric, `unidad`, `fuente_url`, `vigente` boolean, `vigente_desde`. Semilla: `personas_por_bano = 20`, `litros_persona_dia = 15`, `m2_cubiertos_persona = 3.5` (Esfera 2018), `personas_maximas_escenario = 100000`, `umbral_supresion = 5` (propuesta).

### `ref.protocolo_plantillas` y `ref.protocolo_pasos` · Interno
Plantilla: `id`, `nombre`, `amenaza_codigo` (nulo = todas), `version`, `estado_validacion`. Paso: `plantilla_id`, `orden`, `titulo`, `descripcion`, `entidad_id` (responsable), `servicio_codigo` (nulo si no es de un servicio), `plazo_ref_horas`, `bloquea_activacion`. Al registrar una decisión se instancian en `ops.tareas_protocolo`. Marcado `propuesta` hasta validación institucional.

## `geo`: territorio

### `geo.comunas` (22) y `geo.barrios` (342) · Público
`codigo` PK (`'01'`; barrios `'0101'`), `nombre`, `comuna_codigo` FK (en barrios), `geom` MultiPolygon 4326, `fuente_clave` FK.

### `geo.espacios` (2.991) · Público
| Columna | Tipo | Nulo | Descripción |
|---|---|---|---|
| id | text PK | no | `epou-8413` o `deporte-984` (idéntico al de la app) |
| fuente_clave | text FK | no | `publicSpaces` (1.970) o `sports` (1.021) |
| nombre | text | no | `Parque · Vipasa · EPE_02` |
| tipo | text | no | `Parque`, `Escenario deportivo`, `Zona verde`, `Plazoleta`, `Plaza` |
| condicion | text | sí | `Adecuado`... (campo `condition` de la fuente) |
| comuna_codigo | text FK | sí | Hay 52 registros sin comuna asignada (no se inventan) |
| barrio_nombre | text | sí | Como viene en la fuente |
| comuna_fuente / barrio_fuente | text | sí | Valores originales |
| limite_ambiguo | boolean | no | `boundaryAmbiguous` |
| punto | geometry(Point,4326) | no | `coordinates` |
| huella | geometry(MultiPolygon,4326) | sí | Solo en EPOU (en deportivos es nulo) |
| area_m2 | numeric | sí | Huella cartográfica, **no** superficie útil ni aforo |
| metodo_evaluacion | text | no | `Intersección con toda la huella...` o `Cruce en el punto...` |
| estado_proteccion_uso | text | no | `sin_dato` (por defecto), `protegido` o `en_riesgo_de_cambio_de_uso`. Lección de Estambul: las áreas de reunión designadas se pierden por construcción (`docs/referentes/`) |
| es_simulado | boolean | no | `false` |
Los dos tipos de fuente pueden describir el mismo predio: no sumar aforos ni superficies entre fuentes.

### `geo.zonas_amenaza` · Público
`id` bigint PK, `fuente_clave` FK, `amenaza_tipo` (`inundacion_fluvial`, `inundacion_pluvial`, `no_mitigable`, `licuacion`, `efectos_sismicos`), `etiqueta` (campo `label`), `atributos` jsonb, `geom` MultiPolygon 4326. Línea base de H2: las capas derivadas que usa la app (`flood.json` con 653 y `seismic.json` con 7); las capas crudas de `prototipo/datos/raw/idesc/` son opcionales.

### `geo.espacio_exposicion` · vista, Público
Cruces `ST_Intersects` entre `geo.espacios` y `geo.zonas_amenaza`, con el mismo método que `assessmentMethod`. Reemplaza los pre-cálculos del CSV. "Sin cruce" no significa "sin amenaza".

### `geo.mediciones_espacio` · Interno
Historia verificable de lo que hoy es `null` en la app.
| Columna | Tipo | Nulo | Descripción |
|---|---|---|---|
| id | bigint PK | no | |
| espacio_id | text FK | no | |
| atributo | text | no | `capacidad_personas`, `banos`, `agua_l_dia`, `evaluacion_estructural_vigente`, `accesibilidad`, `energia_respaldo`, `disponibilidad`, `administracion_acceso`, `horario`, `acepta_animales_compania` (sí/no), `zona_animales` (¿hay zona separada?, sí/no), `capacidad_animales` (número, sin cifra de referencia) |
| valor_num / valor_texto / valor_fecha | numeric / text / date | sí | Solo uno según el atributo. `valor_texto` pasa por el filtro de datos personales |
| unidad | text | sí | |
| estado | text | no | `declarado`, `verificado`, `rechazado` |
| fuente_texto | text | no | Quién o qué lo respalda (cargo o documento, nunca un nombre de persona) |
| evidencia_ref | text | sí | Referencia a un acta o documento. Obligatoria si `verificado` |
| reportado_por / reportado_en | uuid FK / timestamptz | no | Perfil y fecha |
| validado_por / validado_en | uuid FK / timestamptz | sí | Obligatorios si `verificado` |
Para `evaluacion_estructural_vigente` solo se guarda sí/no y la fecha; **no hay columna para un concepto**.

### `geo.organizaciones_comunitarias` · Público
`id` PK, `tipo` (`jac`, `propiedad_horizontal`, `comite_barrial`, `albergue_autogestionado`, `otra`), `nombre`, `comuna_codigo`, `barrio_codigo` (nulo), `direccion_publica` (nulo; la de la JAC viene del dataset abierto), `fuente_clave` (nulo en las creadas por registro), `activa`, `es_simulado`. Semilla: 182 JAC de `prototipo/datos/raw/idesc/pfp_ivc_organismos_accion_comunal.geojson`. Son organizaciones, **no** personas.

## `idn`: identidad (único dato personal del sistema)

### `idn.perfiles` · Restringido
| Columna | Tipo | Nulo | Descripción |
|---|---|---|---|
| user_id | uuid PK | no | FK a `auth.users` (el correo vive en Auth) |
| rol | rol_app | no | `superusuario`, `gestion_riesgo`, `entidad_responsable`, `datic_tecnico`, `comunitario`, `auditor`, `consulta` |
| cargo_id | bigint FK | sí | Cargo que ocupa hoy |
| entidad_id / organizacion_id | bigint FK | sí | A cuál pertenece |
| zona_comunas / zona_barrios | text[] | no | Alcance territorial (vacío = sin restricción por zona) |
| alias_visible | text | no | Cargo o alias institucional. **No** el nombre de la persona |
| activo | boolean | no | |
| mfa_requerido | boolean | no | `true` para `superusuario` y `gestion_riesgo` |
| es_simulado | boolean | no | `true` en los usuarios de demostración |
| creado_por / creado_en / desactivado_en | uuid / timestamptz | | |
Sin teléfono, documento ni dirección.

### `idn.cargos` · Interno
`id`, `entidad_id` o `organizacion_id`, `nombre` (`Secretario(a) de Gestión del Riesgo`), `rol_por_defecto`, `activo`.

### `idn.asignaciones_cargo` · Restringido
`cargo_id`, `user_id`, `desde`, `hasta` (nulo = vigente), `motivo`, `registrado_por`. Una asignación vigente por cargo.

### `idn.rol_permisos` · Interno
PK (`rol`, `permiso`). La matriz de `ROLES_Y_PERMISOS.md` como datos, para que sea auditable y testeable.

### `idn.autorizaciones_tratamiento` · Restringido
`user_id`, `version_politica`, `aceptada_en`. Sin IP ni otros metadatos.

## `ops`: operación

### `ops.recomendaciones` · Interno · inmutable
`id` uuid, `creada_en`, `creada_por` (perfil), `amenaza_codigo` FK, `personas_escenario` (1 a 100.000), `origen_espacio_id` FK, `ambito` (texto del sector comparado), `version_reglas`, `candidatos` jsonb (id, distancia en m, razón), `resumen_cribado` jsonb (considerados, excluidos por cruce, pendientes de evidencia), `advertencias` text[], `es_simulado` (por defecto `true`). Se rellena con la salida de `compareCandidates()`. No admite UPDATE.

### `ops.decisiones_activacion` · Interno
`id` uuid, `recomendacion_id` FK (nulo), `espacio_id` FK, `amenaza_codigo` FK, `funcion` FK a `ref.funciones_espacio` (`punto_reunion_inmediata`, `albergue`, `acopio`, `punto_agua`, `punto_salud`, `punto_informacion`, `amortiguacion`), `acto_tipo` (`decreto`, `resolucion`, `acta_cmgrd`, `instruccion_secretaria`), `acto_numero`, `acto_fecha`, `justificacion` (obligatoria si no hay recomendación o el espacio difiere), `decidida_por` (perfil), `cargo_id`, `estado` (`vigente`, `en_desactivacion`, `cerrada`), `personas_estimadas` (nulo), `es_simulado`. Solo `api.registrar_decision_activacion` inserta.

### `ops.brechas` · Interno
`id` uuid, `decision_id` FK, `espacio_id` FK, `servicio_codigo` FK, `requerido` numeric (nulo en servicios de tipo tarea, como `animals`), `unidad`, `existente` numeric (nulo = sin dato), `faltante` numeric **generada** (nulo si `existente` es nulo), `entidad_responsable_id` FK, `estado` (`por_medir`, `en_revision`, `asignada`, `en_ejecucion`, `cerrada`), `regla_texto`, `version_reglas`, `es_simulado`. Único (`decision_id`, `servicio_codigo`).

### `ops.seguimientos` · Interno
`id`, `brecha_id` FK, `estado_anterior`, `estado_nuevo`, `nota` (≤ 280, filtro de datos personales), `registrado_por`, `registrado_en`.

### `ops.tareas_protocolo` · Interno
`id`, `decision_id` FK, `paso_id` FK, `entidad_id` FK, `estado` (`pendiente`, `en_curso`, `completada`, `no_aplica`), `vence_en`, `completada_por`, `completada_en`, `nota` (filtrada).

### `ops.reportes_comunitarios` · Restringido
| Columna | Tipo | Nulo | Descripción |
|---|---|---|---|
| id | uuid PK | no | |
| organizacion_id | bigint FK | no | JAC o conjunto que reporta |
| espacio_id | text FK | sí | Espacio al que se refiere |
| tipo | text | no | `estado_espacio`, `necesidad`, `alerta_barrial` |
| n_total, n_0_5, n_6_17, n_18_59, n_60_mas | integer ≥ 0 | sí | Conteos agregados; la suma de los grupos debe igualar el total |
| n_discapacidad | integer ≥ 0 | sí | Opcional, sensible, solo agregado |
| n_animales_compania | integer ≥ 0 | sí | Animales de compañía presentes, agregado; **sin datos de sus dueños**. Los animales de servicio no se cuentan aparte: se admiten siempre |
| estado_servicios | jsonb | sí | Por servicio: `ok`, `falla`, `sin_dato` (claves de `ref.servicios`) |
| observacion | text ≤ 280 | sí | Con filtro de datos personales. Pendiente de tu decisión (§9.5) |
| creado_por / creado_en | uuid / timestamptz | no | |
| es_simulado | boolean | no | |
Las vistas públicas suprimen celdas menores al umbral N.

### `ops.retornos` · Interno
`id`, `decision_id` FK único, `checklist` jsonb, `acta_ref`, `fecha_retorno`, `estado`, `cargos_firmantes` bigint[], `es_simulado`.

### `ops.lecturas_iot` · Interno · solo simuladas
`id`, `espacio_id`, `sensor` (`nivel_tanque`, `temperatura`, `humedad`, `conteo_agregado`), `valor`, `unidad`, `medido_en`, `es_simulado` con `CHECK (es_simulado)`. Sin cámaras ni identificadores de dispositivos de personas.

### `ops.notificaciones` · Interno · solo simuladas
`id`, `decision_id` (nulo), `destinatario_tipo` (`entidad`, `organizacion`, `publico`), `mensaje`, `estado` con `CHECK (estado = 'borrador')`, `es_simulado` con `CHECK (es_simulado)`. Sin teléfonos ni correos de destinatarios.

## `aud`: auditoría

### `aud.eventos` · Restringido
`id` bigint, `ocurrido_en`, `actor_uuid` (nulo si es el sistema), `actor_rol`, `tabla`, `operacion`, `fila_id`, `cambios` jsonb (solo columnas no sensibles), `hash_previo` bytea, `hash` bytea = sha256(`hash_previo` + contenido). Sin nombres ni correos. `aud.verificaciones` guarda cada corrida de `verificar_cadena()`.

## Fase 2 (diseño, sin SQL todavía): índice de aptitud y mapa de calor

Detalle del método y de los límites legales en `docs/referentes/INDICE_APTITUD_Y_MAPA_DE_CALOR.md`. Tablas previstas, todas **públicas** (dato abierto derivado) y calculadas por un script reproducible:
- `ref.criterios_aptitud`: `criterio`, `amenaza_codigo`, `funcion`, `peso`, `direccion` (más es mejor o peor), `fuente`, `version`, `estado_validacion` (`propuesta` hasta que expertos lo validen).
- `geo.indice_aptitud`: `espacio_id`, `amenaza_codigo`, `funcion`, `version_modelo`, `puntaje` (0 a 100), `componentes` jsonb (cada criterio con su valor, peso y aporte), `calculado_en`. Siempre se presenta como **aptitud preliminar para revisión**, nunca como "espacio seguro".
- `geo.mapa_calor_celdas`: `celda` (hexágono), `amenaza_codigo`, `funcion`, `puntaje_promedio`, `n_espacios`, `version_modelo`.

## `api`: única superficie expuesta

Vistas (todas con `security_invoker`): `espacios`, `espacio_ficha`, `espacio_exposicion`, `comunas`, `barrios`, `zonas_amenaza`, `fuentes`, `entidades`, `responsabilidades`, `servicios`, `amenazas`, `funciones_espacio`, `parametros_reglas`, `resumen_territorial` (con supresión), `mi_perfil`, `mis_tareas`, `brechas`, `decisiones`, `reportes_comunitarios` (según zona), `auditoria` (solo auditor).
Funciones RPC: `registrar_recomendacion`, `registrar_decision_activacion`, `actualizar_brecha`, `completar_tarea`, `crear_reporte_comunitario`, `registrar_medicion`, `validar_medicion`, `cerrar_retorno`, `cambiar_rol`, `suspender_usuario`, `traspasar_cargo`.
Los **códigos** (`flood`, `toilets`...) coinciden con los de la app para que el frontend no traduzca.

## Retención (propuesta, la decides tú)

| Dato | Propuesta | Razón |
|---|---|---|
| `ops.lecturas_iot` (simuladas) | 30 días | Sin valor tras la demo |
| `ops.reportes_comunitarios` | 12 meses tras cerrar el evento, luego se anonimizan (se borra `creado_por`) | Necesidad operativa y minimización |
| `idn.perfiles` | 1 año tras desactivar, luego se anonimizan | Trazabilidad de la entidad sin conservar la cuenta |
| `aud.eventos` | Según tabla de retención documental de la entidad (Ley 594/2000, verificar) | Es un registro oficial |
| `ops.decisiones_activacion`, `brechas`, `retornos` | Permanentes: son memoria institucional y sobreviven al cambio de gobierno | Continuidad |
| Datos abiertos (`geo`, `ref`) | Permanentes, con snapshots versionados | Reproducibilidad |

## Supresión de un titular

La supresión anonimiza `idn.perfiles` (borra `alias_visible` y desvincula `auth.users`). La auditoría solo guarda el UUID, que deja de ser reidentificable al romper ese vínculo; la cadena de hash no se toca.
