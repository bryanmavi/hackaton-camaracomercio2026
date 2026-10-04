# Red comunitaria: a quién capacitar para aportar información

> Marcas: 📜 texto oficial leído; 📁 archivo del repo; 🧠 sin verificar (ver [`FUENTES.md`](FUENTES.md)). Todo lo demás es **propuesta del equipo**.

## 1. Por qué la comunidad y no solo el gobierno

- La gestión del riesgo es responsabilidad de **todas las autoridades y de los habitantes**; las entidades públicas, privadas y **comunitarias** ejecutan los procesos, y los habitantes son corresponsables (Ley 1523 de 2012, art. 2 📜).
- El consejo municipal **incorpora representantes del sector privado y comunitario** (art. 28 📜).
- Los gobiernos cambian cada cuatro años; las juntas y los conjuntos residenciales **permanecen** en el territorio. Por eso son la primera fuente de información de lo que pasa en su barrio y la capa estable del sistema.
- Hallazgo del equipo: hubo albergues **autogestionados** (Chiminangos I y II, Calimio Norte) que nadie registraba; la comunidad los conocía antes que cualquier base de datos 📁.

## 2. A quiénes capacitar

| Actor | Qué es | Fundamento | En el sistema |
|---|---|---|---|
| **Juntas de acción comunal (JAC)** | Organismos de acción comunal de **primer grado**: organización cívica, social y comunitaria sin ánimo de lucro, con personería jurídica, integrada voluntariamente por residentes. Tienen una "Comisión accidental para la atención de emergencia" entre sus comisiones | Ley 2166 de 2021, arts. 6 y 7 📜 (derogó la Ley 743 de 2002) | `geo.organizaciones_comunitarias` tipo `jac` (182 en el dataset de IDESC 📁); rol `comunitario` |
| **Organismos de segundo a cuarto grado** (asociaciones, federaciones) | Coordinan juntas por comuna o ciudad | Ley 2166 de 2021, art. 6 📜 | Para escalar la capacitación: un enlace por comuna |
| **Administradores de conjuntos residenciales** | Representan a la copropiedad; la propiedad horizontal busca "garantizar la seguridad y la convivencia pacífica" | Ley 675 de 2001, art. 1 📜 (funciones del administrador: 🧠 por leer) | `tipo = propiedad_horizontal`; rol `comunitario` |
| **Juntas por conjunto residencial** | La ley permite una junta por barrio, **conjunto residencial**, sector o etapa | Ley 2166 de 2021 📜 | Se registran como JAC |
| **Líderes de albergues autogestionados** | Quienes organizan la ayuda donde no hay albergue oficial | Hallazgo del equipo 📁 | `tipo = albergue_autogestionado` |
| **Comités barriales y comisión de emergencia de la JAC** | Voluntarios organizados | Ley 2166 de 2021 📜 | `tipo = comite_barrial` |
| Rectores de sedes educativas (opcional) | Las sedes pueden ser espacios o puntos de información | Datos MEN 📁 | Fuera del MVP |

## 3. Qué pueden reportar y qué nunca

| Sí (agregado y verificable después) | Nunca |
|---|---|
| Número de personas presentes por grupo de edad (0 a 5, 6 a 17, 18 a 59, 60 o más) | Nombres, apellidos, documentos, teléfonos, direcciones de personas |
| Estado de servicios del espacio: agua, baños, energía, techo (`ok`, `falla`, `sin dato`) | Fotos de personas, listas de familias, datos de salud individuales |
| Necesidades del espacio (por servicio) | Datos de niños, niñas y adolescentes que permitan identificarlos (Ley 1581, art. 7 📜 los proscribe salvo los de naturaleza pública) |
| Alertas barriales estructuradas (inundación, deslizamiento, falla de servicio) | Opiniones sobre personas o acusaciones |
| Conteo opcional de personas con discapacidad, **solo agregado** | Cualquier dato sensible individual (Ley 1581, art. 5 📜) |

Lo que reporte la comunidad queda como **`declarado`**: una entidad lo valida antes de que cuente como `verificado`. Así el sistema no confunde lo que dice una persona con una medición.

## 4. Límites técnicos (los hace cumplir la base de datos)

- **Solo su zona:** el perfil lleva sus comunas y barrios; las políticas de seguridad filtran por ellos.
- **Estructurado:** sin texto libre, o con un tope de 280 caracteres y un filtro que rechaza correos, teléfonos y secuencias numéricas largas (decisión pendiente, `MODELO_DATOS.md` §9.5).
- **Supresión de celdas pequeñas:** las vistas públicas ocultan conteos menores al umbral N, para que un número pequeño no identifique a nadie.
- **Sin escritura anónima:** reportar exige cuenta, creada por el superusuario, con aviso de privacidad aceptado.
- **Revocable:** al cambiar los dignatarios de la junta o el administrador del conjunto, el cargo se traspasa (`idn.asignaciones_cargo`) y la cuenta anterior se suspende.

## 5. Plan de capacitación (propuesta)

Tres módulos de unos 90 minutos, con ejercicios sobre **datos simulados** (nunca con personas reales):

| Módulo | Contenido | Evidencia de aprendizaje |
|---|---|---|
| 1. Para qué sirve | El sistema recomienda y la autoridad decide; responsabilidad compartida (Ley 1523, art. 2 📜); qué pasa con lo que reportan | Explicar con sus palabras quién decide qué |
| 2. Qué y cómo reportar | Los campos del reporte; la lista de lo que **nunca** se reporta; práctica con un albergue simulado | Completar 3 reportes simulados sin errores |
| 3. Datos personales y seguridad | Qué es un dato personal y sensible (Ley 1581, arts. 3 y 5 📜); autorización y aviso de privacidad; derechos de consulta y reclamo; contraseñas, phishing, qué hacer si se pierde el celular | Pasar un cuestionario corto; firmar el compromiso de uso |

- **Quién capacita (propuesta):** la Secretaría de Gestión del Riesgo y DATIC, con apoyo de la dependencia municipal que se relaciona con las juntas (el catálogo de datos del repo, `prototipo/datos/fuentes.csv` 📁, registra a la Secretaría de Desarrollo Territorial y Participación Ciudadana como publicadora del dataset de JAC; su rol exacto de inspección, vigilancia y control no se confirmó).
- **Cuándo:** antes de crear la cuenta; de nuevo cada año y **cada vez que cambien los dignatarios o el administrador**.
- **Constancia:** el módulo 3 queda registrado como aceptación del aviso en `idn.autorizaciones_tratamiento` (sin más metadatos).
- **Material:** guía de una página, video corto y simulador con los 13 usuarios de demostración.
- **Referencia internacional (🧠 por verificar):** ISO 22319 sobre cómo planear la participación de voluntarios espontáneos.

## 6. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Reportes falsos o interesados | Todo reporte entra como `declarado`; la entidad valida; `aud.eventos` deja rastro |
| Un actor local captura el canal | Un cargo por organización; traspaso solo por el superusuario; el auditor ve las operaciones |
| Se cuelan datos personales en un texto | Filtro en la base y capacitación; sin texto libre si el responsable lo decide |
| La junta deja de participar al cambiar la directiva | Asignación por cargo y recapacitación obligatoria |
| Un conteo pequeño identifica a una persona | Supresión de celdas menores a N en lo público |

## 7. Pendientes

1. Leer en el texto de la Ley 675 las funciones del administrador y confirmar qué le corresponde en emergencias.
2. Confirmar qué dependencia municipal ejerce la inspección, vigilancia y control de las JAC en Cali.
3. Documentar **al menos una validación real** con una junta o con la Secretaría (pendiente del IRL 3 en `docs/PROYECTO.md` §7). **No se inventan conversaciones**: hoy el equipo no ha hecho ninguna.
4. Acordar con la Secretaría quién ejecuta la capacitación y con qué recursos.
