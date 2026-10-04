# Matriz normativa: norma, control y evidencia

> Marcas: 📜 texto oficial leído; 🔎 solo resumen de búsqueda; 🧠 sin verificar (ver [`FUENTES.md`](FUENTES.md)). **Evidencia** apunta al documento que ya existe o al hito que la producirá (H2 migraciones, H3 pruebas). Una norma sin 📜 se cita como "(verificar)".

## 1. Normas con texto oficial leído (📜)

| Norma | Qué nos exige | Control en el diseño | Evidencia |
|---|---|---|---|
| **Ley 1581/2012 art. 3** | Distinguir **responsable** (decide sobre la base) y **encargado** (trata por cuenta del responsable) | La Alcaldía es responsable; quien opera la plataforma, encargado; contrato de transmisión con los proveedores en la nube | `DPIA` y `POLITICA_TRATAMIENTO` (H4) |
| **Ley 1581 art. 5** | Los datos de salud y biométricos son sensibles | Nada de datos de salud individuales; solo un conteo de discapacidad **opcional y agregado**; sin biometría ni reconocimiento facial | `db/docs/DICCIONARIO.md` (`ops.reportes_comunitarios`), ADR-0008 |
| **Ley 1581 art. 7** | Está **proscrito** tratar datos de niños, niñas y adolescentes, salvo los de naturaleza pública | No existe ninguna tabla ni columna de menores; solo bandas de edad agregadas con supresión de celdas pequeñas | ADR-0008; CHECK y vistas (H2/H3) |
| **Ley 1581 art. 14** | Consultas: **10 días hábiles**, prórroga de máximo 5 | Procedimiento de consultas y función de exportación de los datos del titular | `docs/cumplimiento/PROCEDIMIENTO_TITULARES` (H4) |
| **Ley 1581 art. 15** | Reclamos: **15 días hábiles**, prórroga de máximo 8; leyenda "reclamo en trámite" en 2 días hábiles | Procedimiento de reclamos; la supresión anonimiza el perfil sin romper la auditoría | `DICCIONARIO.md` (supresión de un titular); H4 |
| **Ley 1581 art. 17 lit. n** | Informar a la autoridad de las violaciones a los códigos de seguridad y los riesgos en la administración de la información | Runbook de incidentes con notificación a la SIC | `INCIDENTES.md` (H7) |
| **Ley 1581 art. 26** | Prohibida la transferencia a países sin nivel adecuado, salvo excepciones | Ver la discusión de región en el apartado 3 | Este documento; ADR de región (H4) |
| **Decreto 1377/2013 art. 3** | Aviso de privacidad; los datos públicos incluyen la calidad de servidor público | El cargo institucional de un funcionario es dato público; el aviso se acepta al crear la cuenta | `idn.autorizaciones_tratamiento` (H2) |
| **Decreto 1377 arts. 24 y 25** | Las **transmisiones** internacionales a un encargado no requieren consentimiento del titular si hay un contrato con el contenido del art. 25 (alcance, actividades, seguridad, confidencialidad, aplicar la política del responsable) | Contrato o DPA con Supabase y Vercel que cubra esos puntos | `PROVEEDORES_NUBE.md` (H7) |
| **Decreto 1377 art. 26** | **Responsabilidad demostrada**: poder probar medidas apropiadas, proporcionales a la naturaleza de los datos y los riesgos | Este conjunto de documentos y las pruebas automáticas son la evidencia | `docs/cumplimiento/`, pgTAP (H3) |
| **Circular Externa 005/2017 SIC, num. 3.2** | Lista de países con nivel adecuado | Se elige la región con esta lista en la mano (apartado 3) | `FUENTES.md` |
| **Ley 1523/2012 arts. 2, 12, 14** | Responsabilidad compartida; el alcalde es responsable directo del manejo de desastres | El sistema **recomienda** y el acto humano decide; roles por cargo | ADR-0003 y ADR-0004; `ENTES_DECISORES.md` |
| **Ley 1523 arts. 27, 28 y 29** | El consejo municipal coordina, asesora y hace seguimiento; incorpora al sector comunitario; la dependencia de gestión del riesgo es obligatoria en municipios de más de 250.000 habitantes | Entidades y roles modelados según la composición del consejo; rol `comunitario` | `ENTES_DECISORES.md`, `RED_COMUNITARIA.md` |
| **Ley 1523 arts. 55 a 58** | Desastre y calamidad pública; la calamidad la declara el alcalde con **concepto favorable del consejo** | La decisión registra el acto administrativo; el sistema nunca declara nada | `ops.decisiones_activacion` (H2) |
| **Ley 2474/2025** (modifica la Ley 1523) | Incluye a los **animales** en las medidas de gestión del riesgo | Decisión pendiente: añadir el servicio `animales` al catálogo y a las brechas | `MODELO_DATOS.md` §9 (decisión nueva) |
| **Ley 2166/2021** | Régimen vigente de los organismos de acción comunal (derogó la Ley 743/2002) | Las JAC son organizaciones del sistema, con rol `comunitario` | `RED_COMUNITARIA.md` |
| **Ley 675/2001 art. 1** | Propiedad horizontal orientada a la seguridad y la convivencia | Los administradores de conjuntos son actores comunitarios | `RED_COMUNITARIA.md` |

## 2. Normas con resumen de búsqueda (🔎) o sin verificar (🧠)

| Norma | Qué exige (según lo que sé) | Control | Qué falta |
|---|---|---|---|
| Decreto 1074/2015, cap. 25 🔎 | Compila el Decreto 1377/2013 | Se cita el Decreto 1377 con su artículo original | Confirmar la numeración compilada |
| Decreto 090/2018 (RNBD) 🔎 | Inscribir bases de datos con datos personales si el responsable es persona jurídica pública o supera 100.000 UVT | La inscripción la haría la Alcaldía; el equipo no está obligado | Leer el decreto y la guía vigente |
| Circular Externa 002/2024 SIC 🔎 | Datos personales en sistemas de IA: idoneidad, necesidad, razonabilidad, proporcionalidad, responsabilidad demostrada | Reglas explicables y versionadas (`ref.parametros_reglas`, ADR-0007); cada recomendación guarda la versión que la produjo | Abrir el PDF de la SIC |
| Res. MinTIC 500/2021, Decretos 767 y 338 de 2022 🔎 | Seguridad y privacidad en gobierno digital | Alineación con ISO 27001 y 27002 (apartado de ISO) | Leer cada norma |
| Ley 1098/2006, Ley 1712/2014, Ley 1273/2009, Ley 527/1999, Ley 1575/2012, Ley 400/1997 y NSR-10, Decreto 2157/2017, Res. MinTIC 1519/2020, Ley 594/2000, CONPES 4144/2025 🧠 | Ver la bitácora (`docs/PROYECTO.md` §4) | Los controles de `AGENTS.md` §3 | Verificar cada una |

## 3. La región del proyecto de Supabase

La Ley 1581 (art. 26) prohíbe **transferir** datos personales a países sin nivel adecuado, con excepciones. La lista de la SIC de 2017 (num. 3.2) incluye **Estados Unidos y Perú**; **Brasil no figura por su nombre**, aunque la lista añade "los países declarados con nivel adecuado por la Comisión Europea". No verifiqué si esa decisión existe hoy para Brasil.

Pero lo que ocurre con un proveedor en la nube suele ser una **transmisión** (el proveedor trata los datos por cuenta del responsable): el Decreto 1377, art. 24 num. 2, la exime de informar al titular y pedir su consentimiento **si hay un contrato** como el del art. 25. Esa es la vía.

| Opción | A favor | En contra |
|---|---|---|
| **São Paulo (`sa-east-1`)** | La más cercana a Colombia (latencia); no depende de la lista | Brasil no figura nominalmente en la lista de 2017; exige el contrato de transmisión |
| **EE. UU. (este)** | Figura en la lista de la SIC | Más lejos; el contrato de transmisión sigue siendo recomendable |

**Qué datos personales viajan:** solo las cuentas institucionales (correo, cargo, rol) y su auditoría. Todo lo demás es dato abierto o agregado. En la demo son cuentas ficticias.
**Recomendación:** São Paulo con el contrato de transmisión, y dejar anotado EE. UU. como alternativa si la Alcaldía lo prefiere. Decisión tuya, y del responsable cuando haya piloto.
**Pendiente:** leer el DPA de Supabase y de Vercel y comprobar que contiene lo que exige el art. 25 (alcance, actividades, seguridad, confidencialidad, aplicar la política del responsable).

## 4. Lo que el sistema **no** hace (límites de competencia)

| Límite | Norma | Cómo se garantiza |
|---|---|---|
| No decide activaciones ni declara calamidad | Ley 1523 arts. 14, 56 y 57 📜 | ADR-0003; solo `gestion_riesgo` con MFA registra la decisión y cita el acto |
| No emite concepto estructural | Ley 400/1997 y NSR-10 🧠 | Solo se guarda si hay evaluación vigente y su fecha (ADR-0005) |
| No emite concepto de bomberos ni de seguridad humana | Ley 1575/2012 🧠 | Sin campo ni vista para ese concepto |
| No emite alertas oficiales | Ley 1523 🧠 | Las emiten IDEAM, CVC, SGC o la autoridad; el sistema solo las consulta |
| No registra personas damnificadas | Ley 1581 arts. 5 y 7 📜 | Exclusión por diseño (ADR-0008); el registro nominal es del RUD de la UNGRD |
| No envía SMS reales | Ley 1581 | `ops.notificaciones` solo guarda borradores simulados |
