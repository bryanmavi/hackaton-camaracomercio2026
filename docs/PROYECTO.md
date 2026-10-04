# Hackathon Smart City Expo Cali 2026 — Bitácora del proyecto

**Equipo:** William Ortiz, Herlin Echeverry, Pablo Arango, Bryan Martínez Villamarín
**Reto:** RETO-01 Cali Activa: espacios públicos que se transforman para cuidar
**Enfoque:** plan de contingencia multiamenaza (sismo, inundación y sequía/El Niño) para espacios públicos, con organismos y mecanismos para el antes, el durante y el después.
**Última actualización:** 4 de octubre de 2026: base de datos montada en Supabase `dev` (12 migraciones, API restringida al esquema `api`), repo privado y equipo invitado.

---

## 1. Cómo funciona el hackathon

**Material fuente:** `~/Descargas/SESIÓN 1 - 23 SEPT…zip`, `SESIÓN 2 - 25 SEPT…zip` y `SESIÓN 3 - 26 SEPT…zip` (la Sesión 3 venía vacía).

| Sesión | Fecha | Qué se hace | Artefacto |
|---|---|---|---|
| 1 | Mié 23 sep | Tablero del equipo: roles, frase, lo que sabemos y suponemos, actores, entrevistas | Artefacto 1: https://claude.ai/artifact/LAmBJHeusdaZ48dwDgkpLx |
| 2, bloque 1 | Vie 25 sep, mañana | Acotar el reto en 6 campos + "¿Cómo podríamos…?" | Artefacto 2: https://claude.ai/artifact/W2gqfgJFZjHU33PMR6Lqmt |
| 2, bloque 2 | Vie 25 sep, después del almuerzo | Ideación (6 a 8 ideas) y filtro por impacto y factibilidad | Artefacto 3: https://claude.ai/artifact/5Bwp37CYVRW8DypdZdASi8 |
| 2, bloque 3 | Vie 25 sep, tarde | Propuesta de valor, validación, TRL/IRL, plan del prototipo, guion | Artefacto 4: https://claude.ai/artifact/EggcCaEL6xavWRHpkY9KAU |
| 3 | Sáb 26 sep | Prototipo, pruebas, bitácora y guion de grabación | Artefacto 5: https://claude.ai/artifact/8yLQNLcNt8FF3aMcmewD81 |

**Reglas clave**
- Cada artefacto recibe el Word del anterior. No editen el Word después de descargarlo.
- Usen siempre el mismo computador y el mismo navegador (el avance se guarda en localStorage). No usen modo incógnito.
- Validador adicional (Gema de Gemini): https://gemini.google.com/gem/1Isx0OX0Ap5lmPl5SlM8d4y9KWl9E4dvC?usp=sharing
- Meta: **TRL 3** (prototipo que demuestra la lógica) + **IRL 3** (proceso de coordinación validado con actores reales).
- La solución no tiene que ser una app: puede ser un flujo en Glide o Softr, un tablero en Looker Studio, un Figma o un diagrama de proceso.
- **Guion del video (4 min, productora CCC):** [00:00–01:00] dolor territorial y cifras · [01:00–02:15] demo en vivo · [02:15–03:15] valor público e IRL 3 · [03:15–04:00] equipo y cierre.
- El entregable final se sube a la carpeta de Drive del hackathon.

## 2. Ficha oficial del RETO-01 (Portafolio de Retos, Alcaldía de Cali, v2.0)

- **Owner:** Secretaría de Gestión del Riesgo de Emergencias y Desastres (líder funcional) y DATIC (líder técnico).
- **Entidades a articular:** UAE Gestión de Bienes y Servicios, Secretaría de Infraestructura, Secretaría del Deporte, Secretaría de Seguridad y Justicia, Secretaría de Salud Pública, Secretaría de Bienestar Social, Secretaría de Educación, Planeación, EMCALI, UAESP.
- **Pregunta retadora:** ¿Cómo podríamos transformar los espacios públicos de Cali en una red adaptable que, según el tipo de emergencia y las necesidades de la población, permita activar y operar de manera segura y coordinada funciones temporales de atención y recuperación, y facilite posteriormente el retorno del espacio a su uso cotidiano?
- **Objetivo:** un prototipo de baja fidelidad que caracterice espacios, analice su aptitud según el escenario, identifique adecuaciones, active entidades según la población, haga seguimiento y apoye el retorno.
- **Indicadores de validación:**
  - diferenciar la respuesta según el tipo de emergencia;
  - número de variables de preparación;
  - capacidad de identificar brechas;
  - trazabilidad necesidad → servicio → entidad;
  - tiempo para generar una propuesta de activación en un escenario simulado;
  - representar el ciclo completo, de la preparación a la recuperación.
- **Líneas rojas:** no reemplazar evaluaciones estructurales, conceptos técnicos de seguridad ni decisiones de autoridades; no invadir competencias de bomberos; privacidad y datos mínimos; sin reconocimiento facial ni identificación individual innecesaria; recomendaciones automáticas que se puedan entender, con criterios visibles.
- **Tecnologías sugeridas:** SIG, No-Code/Low-Code, IA y analítica, IoT, tableros, apps web o móviles, gestión de incidencias, conectividad resiliente.

## 3. Competencia (tableros del artefacto 1)

| Reto | Equipos |
|---|---|
| RETO-01 (~7) | CityVe (condiciones sanitarias), Certeza (agenda social y percepción de inseguridad), Ecosistema Creativo (zonas afectadas y zonas seguras en tiempo real), Revo HUD (motociclistas), CityBeam (mobiliario urbano y paredes interactivas), Nature Intelligence (alertas de incendios satelitales), Aerostatic (comunicación entre comunidad e instituciones) |
| RETO-02 (~8) | VUM, Páramo Digital, DoTech, La Maleta, Alfaworks, Factura Clara, toderosfynd, (Certeza Fintech) |
| RETO-03 (3) | Dedsec, Mentes en Movimiento, TriAI |

**Qué nos diferencia:** ningún equipo trabaja el enfoque **multiamenaza** (que la aptitud de un espacio dependa del tipo de amenaza), ni la **matriz de quién responde por cada servicio**, ni la inclusión de los **albergues autogestionados**.

## 4. Marco legal y normativo colombiano (filtro obligatorio)

> Las normas marcadas con (verificar) hay que confirmarlas en la Función Pública o la SIC antes de citarlas en el video o la bitácora.

### Transversal
| Tema | Norma | Qué nos exige |
|---|---|---|
| Datos personales | Ley 1581 de 2012; Decreto 1377 de 2013 (compilado en el Decreto 1074 de 2015) | Autorización previa, expresa e informada; aviso de privacidad; pedir solo lo necesario y usarlo solo para el fin declarado |
| Datos sensibles | Ley 1581, arts. 5 y 6 | Salud, discapacidad y etnia: respuesta siempre opcional |
| Menores | Ley 1581, art. 7; Ley 1098 de 2006 | Solo datos agregados; nunca identificar a menores |
| IA | Circular SIC 002 de 2024 (verificar); CONPES 4144 de 2025 (verificar) | IA explicable; la decisión final la toma una persona; no enviar datos personales reales a modelos externos |
| Transparencia | Ley 1712 de 2014 | Criterios que se puedan publicar; usar datos abiertos |
| Gobierno digital | Decreto 767 de 2022; MSPI de MinTIC | Solución web, interoperable, con seguridad y privacidad desde el diseño |
| Accesibilidad | Resolución MinTIC 1519 de 2020 (WCAG 2.1 AA); Ley 1618 de 2013 | Contraste, lectura en pantalla, lenguaje claro |
| Mensajes de datos | Ley 527 de 1999 | Validez de los registros digitales |
| Delitos informáticos | Ley 1273 de 2009 | No hacer scraping ni acceder a datos sin autorización |
| Propiedad intelectual | Ley 23 de 1982 y bases del hackathon | Revisar a quién pertenece lo que se desarrolle |

### Específico del RETO-01
- **Ley 1523 de 2012** (Sistema Nacional de Gestión del Riesgo) y **Decreto 2157 de 2017**: la activación la decide el Consejo Municipal de Gestión del Riesgo y la Secretaría de Gestión del Riesgo. Nuestro sistema **recomienda; no decide**.
- **Protocolo de Alojamientos Temporales de la UNGRD** y **Manual de Estandarización de la Ayuda Humanitaria**: de ahí sale la tabla de quién responde por cada servicio.
- **Ley 400 de 1997 y NSR-10**: no reemplazamos la evaluación estructural; solo registramos si existe y su fecha.
- **Ley 1575 de 2012** (Bomberos): no emitimos conceptos de seguridad humana ni contra incendios.
- **Ley 1098, Ley 1618 y Ley 1257 de 2008**: zonas diferenciadas para niños, personas con discapacidad y mujeres; conteos por ciclo vital, sin censar a personas.
- **Decreto 1504 de 1998** (espacio público) y **POT de Cali (Acuerdo 0373 de 2014)**: el uso temporal debe tener una ruta de retorno.
- **Estándares Esfera** (referencia humanitaria internacional): 1 baño por cada 20 personas, 15 L de agua por persona al día, 3,5 m² cubiertos por persona.

### Checklist antes de construir
1. ¿Recomienda sin quitarle la decisión a la autoridad competente?
2. ¿Pide solo los datos necesarios, con aviso y autorización, y hace opcionales los sensibles?
3. ¿Usa datos simulados o abiertos en el prototipo, sin datos reales de personas?
4. ¿Tiene una tabla de explicabilidad (variables, reglas, límites) visible en la demo?
5. ¿Cruza alguna línea roja o se mete en competencias de otra entidad (bomberos, salud, estructural)?
6. ¿Cumple lo básico de accesibilidad?

## 5. Investigación: noticias y evidencia

### Terremoto del 10 de agosto de 2026
- Magnitud 7,4, a las 7:34 a. m.; epicentro en San José del Palmar (Chocó), a 103 km de profundidad.
- **Cali:** 105 muertos, 1.401 heridos; 879 viviendas destruidas y 16.357 averiadas; **45.138 familias (97.337 personas) inscritas en el Registro Único de Damnificados (RUD)**; cerca de 20 edificios colapsados. (Otra nota del 13 de septiembre habla de 154 fallecidos y 1.517 heridos. El repositorio oficial de la Alcaldía, que citó el equipo Revo HUD, reporta **154 fallecidos, 1.657 lesionados y 24 edificaciones con colapso total**: falta confirmar la fecha de corte.)
- **Valle del Cauca (corte al 24 de agosto):** 220 muertos, 3.043 heridos; el 80 % de las casas de El Cairo quedó destruido.
- **País (OCHA, 25 de septiembre):** 486.917 afectados (303.934 familias), 335 muertos, 4.516 heridos, 105 desaparecidos, 36.478 viviendas destruidas; **6.903 personas en 105 alojamientos temporales**; 4.431 sedes educativas, 402 centros de salud y 182 acueductos afectados.
- **Vacíos que señala OCHA:** cifras que no coinciden entre las evaluaciones de daños y los reportes municipales; migrantes que quedaron fuera de los registros; familias sin información sobre las inspecciones estructurales; fallas de agua y saneamiento en los albergues.

### Albergues en Cali
- **Oficiales:** Cancha de Hockey Miguel Calero (albergue y punto de atención humanitaria, con equipos psicosociales, de salud y de Bienestar Social; atiende a migrantes), Diamante de Béisbol y Unidad Deportiva Jaime Aparicio (albergue, centro de acopio y lugar de descanso para rescatistas). Se entregaron colchonetas, agua, alimentos, cobijas y kits de higiene, y se instalaron baños portátiles.
- **Autogestionados (hallazgo clave):** la Defensoría encontró **336 familias (1.046 personas)** en 3 albergues montados por la comunidad en canchas de **Chiminangos I, Chiminangos II y Calimio Norte**. Funcionaban con carpas y baños donados por un empresario, ollas comunitarias y voluntarios jóvenes.
- **Recomendaciones de la Defensoría:** organizar mejor los albergues; acompañamiento permanente de la Alcaldía (Santa Elena, Alto Meléndez); articulación con el ICBF; baños adecuados y **censo por ciclo vital en la Cancha de Hockey**. Observó "traslados de ayudas cuyo destino se desconocía" por falta de caracterización de las familias.
- **ICBF:** acompaña 49 albergues; verifica derechos, ubica a niños y activa rutas de protección.
- **Vida en los albergues:** trauma (despertarse con cualquier ruido), carpas sin protección adecuada, falta de espacios para niños y apoyo psicosocial limitado.

### Retorno de escenarios deportivos
- Al 31 de agosto, de **43 escenarios** de alto rendimiento revisados: **12 habilitados (27,9 %)**, **22 esperando inspección técnica (51,2 %)**, 4 inhabilitados, 2 con observaciones y 2 sin revisar.
- En el Valle del Cauca, 36 escenarios quedaron afectados, 24 con daños importantes. Seguían cerrados el Coliseo El Pueblo, el Velódromo Alcides Nieto y el Complejo Acuático Hernando Botero. Indervalle lidera la evaluación.

### Inundaciones: río Cauca y Jarillón
- **24 de febrero de 2026:** el río Cauca llegó a 9,25 m y se declaró alerta naranja en el oriente (Puerto Nuevo, Playa Renaciente, Brisas del Cauca). Actuaron Bomberos, Cruz Roja y Defensa Civil. No hubo viviendas inundadas.
- **Mayo de 2026:** emergencia en 23 km de terrenos junto al Jarillón.
- El Plan Jarillón (Fondo Adaptación) protege a **900.000 habitantes** del oriente. En marzo hubo intervenciones en Calimio Norte y Petecuy.
- ⚠️ **Calimio Norte (albergue autogestionado tras el sismo) está en el sector del Jarillón**, es decir, en zona de amenaza por inundación. Chiminangos: hay que verificarlo en el mapa de amenaza del POT.

### Sequía y El Niño
- IDEAM: 90 % de probabilidad de un El Niño muy fuerte en el último trimestre de 2026 (75 % de que sea el más intenso en 76 años). **El pico será en noviembre.**
- En julio de 2026 hubo más de 30 incendios en Cali (+20 % frente a 2025); 50 incendios forestales en el Valle del Cauca. Vigilancia reforzada en las comunas 1, 18 y 20, Pance, La Buitrera y El Saladito.
- El río Meléndez está en alerta naranja (~600 L/s). EMCALI tiene planes de contingencia para las laderas. Salvajina está al 80 % y Sara Brut al 96 %; la CVC descarta cortes de agua en Cali por ahora.
- Los 6 riesgos que identificó Cali: incendios forestales, desabastecimiento de agua, salud pública, interrupción de servicios, sector agrícola y ecosistemas.

### Referentes internacionales: planes de contingencia en espacios públicos
Idea que los une: **el espacio público se diseña desde el inicio con dos vidas**, la cotidiana y la de emergencia, y además se **protege legalmente** para que no desaparezca.

**Sismo**
| País | Qué hacen | Qué adaptamos a Cali |
|---|---|---|
| Japón (Tokio) | **Parques de prevención de desastres (bōsai kōen):** bancas que se convierten en fogones (*kamado*), tapas de alcantarilla que se convierten en baños sin agua ni electricidad (el parque Hikarigaoka tiene 52), postes solares con tomas para cargar celulares y bodegas con comida. Bajo parques y colegios hay **tanques de agua potable antisísmicos** enterrados; en Yokohama, el de Minato Mirai 21 guarda agua para unas 170.000 personas durante 3 días. | Campo de la ficha de aptitud: "¿tiene agua almacenada, baños sin red y energía propia?". Es la brecha que más se vio en los albergues de Cali (baños portátiles, agua donada). |
| Nepal (Katmandú) | En 2013, el Gobierno aprobó por decreto **83 espacios abiertos humanitarios** (unos 4 km²), con mapas SIG, un portal web y una app. Tras el sismo de 2015, 33 de esos espacios recibieron a casi 31.000 personas. En 2020, OIM encontró que **solo la mitad seguía siendo utilizable** por construcciones nuevas. | Un inventario oficial y previo, con revisión periódica: la ficha debe tener **fecha de última verificación**. |
| Turquía (Estambul) | Tras el sismo de 1999 se definieron 470 áreas de reunión; más de 300 terminaron convertidas en centros comerciales, viviendas u oficinas porque **no tenían protección legal**. | Lección negativa: proponer que los espacios aptos queden protegidos en el POT o en el Plan Municipal de Gestión del Riesgo. |
| México (CDMX) | El SASMEX da la alerta sísmica y el C5 la difunde por **28.287 altavoces**. En el Simulacro Nacional del 19 de septiembre de 2026 funcionó el 98,93 % (303 fallaron) y la ciudadanía reporta las fallas. | Simulacros periódicos de activación de espacios, con un indicador de qué funcionó y qué no. |

**Inundación**
| País | Qué hacen | Qué adaptamos a Cali |
|---|---|---|
| Japón (Yokohama) | El **estadio Nissan** está construido sobre pilotes dentro de la cuenca de retención del río Tsurumi (parque Shin-Yokohama): cuando el río se desborda, el agua pasa por debajo y el parque se inunda a propósito. Con el tifón Hagibis (12 de octubre de 2019) la cuenca se llenó, y al día siguiente el partido Japón-Escocia del Mundial de Rugby se jugó sin problemas. | La aptitud cambia con la amenaza: un espacio puede ser **zona de amortiguación** en una inundación y **albergue** en un sismo. El sistema debe saber cuál de los dos papeles le toca. |
| Países Bajos (Róterdam) | **Plaza de agua Benthemplein:** canchas de baloncesto y skate hundidas que, en un aguacero, almacenan unos 1.700 m³ (una piscina olímpica) y alivian el alcantarillado. | Un parque o una cancha puede ser amortiguador, no albergue. |
| Dinamarca (Copenhague) | El **Plan de Aguaceros** tiene unos 300 proyectos. El parque Enghaveparken tiene muros con compuertas que suben solas y lo convierten en un depósito de 22.600 m³. | Umbrales automáticos, como el "río Cauca ≥ 9 m" del plan. |
| China | **Ciudades esponja** (desde 2015): la meta es que en 2030 el 80 % del área urbana absorba y reutilice al menos el 70 % de la lluvia. Hoy hay más de 640 proyectos en 250 municipios. | Contexto para el "después": reconstruir el espacio pensando en la próxima amenaza. |

**Sequía o El Niño**
| País | Qué hacen | Qué adaptamos a Cali |
|---|---|---|
| Alemania | La Ley de Aseguramiento del Agua (*Wassersicherstellungsgesetz*, 1965) mantiene unos **5.200 pozos de emergencia** independientes de la red, sobre todo en zonas residenciales de las ciudades grandes. Berlín tiene unos 900 pozos de calle. | Mapear las fuentes de agua alternas (pozos, tanques, carrotanques) asociadas a cada espacio. |
| Sudáfrica (Ciudad del Cabo, 2018) | El plan del "Día Cero" definía unos 200 **puntos de recolección de agua** en espacios públicos, a 25 L por persona al día, con horario ampliable y seguridad de Policía y Ejército. Los carrotanques atendían primero a hogares de adultos mayores y de personas sin hogar. El Día Cero no llegó porque la ciudad redujo el consumo. | Un tercer papel para el espacio público: **punto de distribución de agua**, además de albergue y amortiguador. Poblaciones priorizadas. |
| España (Barcelona, 2024) | Emergencia por sequía (embalses por debajo del 16 %): bajó la dotación de 210 a 200 L por persona al día, se cerraron fuentes ornamentales y parques acuáticos, y se dejó de regar los parques; los árboles se regaban lo mínimo con agua subterránea. | Qué se apaga en un espacio (riego, fuentes, piscinas) y qué se prende (punto de agua, refugio climático) cuando El Niño llegue a su pico en noviembre. |

**Conclusión para la propuesta:** ningún referente usa el mismo espacio igual para las tres amenazas. Eso respalda la idea central de "Cali Activa": **la aptitud es por amenaza** y cada espacio tiene uno de tres papeles posibles, **albergue, amortiguador o punto de agua**. En Colombia la decisión de activarlo sigue siendo de la autoridad (Ley 1523). Obras como el estadio sobre pilotes o los tanques enterrados son de largo plazo y salen del alcance del prototipo; en la ficha solo se registran como atributos del espacio.

## 6. La propuesta: "Cali Activa: espacios listos para cualquier amenaza"

**Idea central:** la aptitud de un espacio depende de la amenaza. Una cancha del oriente sirve para un sismo pero no para una inundación. Un coliseo de ladera sirve para una inundación pero queda sin agua en El Niño. El plan incluye los albergues autogestionados que la ciudad no tenía mapeados. La estructura sigue los tres procesos de la Ley 1523: conocimiento del riesgo, reducción y manejo.

### ANTES (preparación)
| Mecanismo | Organismo responsable |
|---|---|
| Ficha de aptitud por espacio y por amenaza: capacidad, baños, agua, energía, accesibilidad, zona de amenaza, evaluación estructural vigente | Secretaría de Gestión del Riesgo (líder), Planeación, Secretaría del Deporte, Bienes y Servicios, DATIC |
| Umbrales de alerta que preactivan espacios (río Cauca ≥ 9 m, sismo, alerta roja por incendio) | IDEAM, CVC, Servicio Geológico Colombiano |
| Matriz de quién responde por cada servicio (Protocolo UNGRD) | Consejo Municipal de Gestión del Riesgo |
| Registro de líderes comunitarios y albergues autogestionados | Juntas de acción comunal, Bienestar Social |

### DURANTE (activación y operación)
| Mecanismo | Organismo responsable |
|---|---|
| El sistema recomienda los 3 mejores espacios según la amenaza y el número de personas; la decisión la toma la autoridad | Secretaría de Gestión del Riesgo, Consejo Municipal |
| Lista de brechas según Esfera, asignadas automáticamente a su entidad | EMCALI, UAESP, Salud Pública, ICBF, Bienestar Social, Policía, Cruz Roja, Defensa Civil |
| Caracterización mínima por ciclo vital (solo conteos) | Bienestar Social, con veeduría de la Defensoría y la Personería |
| Tablero de seguimiento de brechas (abierta → en curso → cerrada) | DATIC, Secretaría de Gestión del Riesgo |

### DESPUÉS (recuperación y retorno)
| Mecanismo | Organismo responsable |
|---|---|
| Checklist de retorno: salida de la población → limpieza → inspección → reparación → acta de entrega | Secretaría de Infraestructura, Secretaría del Deporte, Bienes y Servicios |
| Lecciones aprendidas y actualización de la ficha del espacio | Secretaría de Gestión del Riesgo |

### Demo para el sábado (60 s)
"Alerta naranja, río Cauca a 9,25 m. Hay 300 personas de Calimio Norte que necesitan reubicarse." El sistema descarta los espacios del oriente que están en zona inundable, propone 3 alternativas con sus brechas y dice quién responde por cada una. Luego se cambia el escenario a "sismo" y la recomendación cambia. Así se cubren los indicadores de la ficha.

**Herramientas:** Google Sheets como base de datos, Glide o Softr para la app, Looker Studio para el mapa y el tablero. **Datos reales** (decisión del 25 de septiembre; ver la sección 6.2 y `docs/DATASETS.md`). Solo el IoT y la ocupación de la demo son simulados, y así se marcan.

### Filtro legal de la propuesta
- Es una recomendación; la decisión la toma la autoridad (Ley 1523).
- No reemplaza evaluaciones estructurales (NSR-10).
- No emite conceptos de bomberos (Ley 1575).
- Solo conteos agregados, sin datos de menores (Ley 1581 y Ley 1098).
- Reglas visibles y explicables.
- Sin reconocimiento facial.

## 6.1 Integración de las ideas del equipo (25 de septiembre)

### Las 4 piezas
| Pieza | Quién | Qué aporta | Qué hay que ajustar |
|---|---|---|---|
| **Cali Activa multiamenaza** | Bitácora del equipo | La aptitud de un espacio depende de la amenaza; matriz de quién responde; albergues autogestionados; retorno | Nada: es la columna vertebral |
| **Cali Lista** (`docs/cali_lista_contexto.md` y `docs/cali_lista.pdf`) | Pablo (fork) | Formulario de caracterización con 6 categorías; clasificación por **funciones** (albergue, acopio, punto de salud, conectividad); **adecuaciones mínimas permanentes** (por ejemplo, un punto fijo de agua) que sirven en la vida cotidiana y en la emergencia; ciclo que se retroalimenta | 1. Cambiar la palabra **"peritaje"** por "caracterización" o "verificación de aptitud": un peritaje suena a dictamen técnico, y eso cruza la línea roja de la NSR-10. 2. Cruzar las funciones con la amenaza. 3. El "tiempo real" se muestra con datos simulados o IoT |
| **Refugios modulares de PVC + IoT** | Integrante del equipo (aún no ha subido material) | Cierran rápido las brechas físicas (cubierta, divisiones); se **reutilizan** en eventos, así que están en uso, mantenidos y probados; los sensores alimentan el tablero | Filtro legal fuerte: fuego, estructura, espectro y datos (ver abajo). En el prototipo va como maqueta o ficha técnica, con datos de sensores simulados |
| **Marco legal** | Tú | Filtro transversal de todas las piezas | — |

### Propuesta integrada en 3 capas
1. **Capa de decisión (el software que se prototipa el sábado).**
   - La ficha del espacio usa las variables de Cali Lista más una columna de aptitud por amenaza (sismo, inundación y sequía).
   - Catálogo único de funciones: albergue, centro de acopio, punto de apoyo a salud (no reemplaza a la Secretaría de Salud), punto de agua, punto de información y conectividad, y zona de amortiguación (sin uso humano).
   - Regla explicable: **aptitud = f(espacio, amenaza, función)** → los 3 mejores espacios → brechas según Esfera → entidad responsable → seguimiento → retorno.
2. **Capa de adecuaciones permanentes.** Es una recomendación de salida del sistema, no una obra en el hackathon: toma de agua, puntos para conectar baños, energía solar y anclajes para los módulos. Se priorizan los espacios con mayor probabilidad de uso. Tiene respaldo en los referentes de Tokio (parques de prevención) y Ciudad del Cabo (puntos de agua).
3. **Capa del kit modular y el IoT.**
   - Módulos de PVC guardados en bodega. En tiempos normales se usan en eventos (CicloVida, ferias); en una emergencia cierran la brecha de "área cubierta".
   - Sensores **sin cámaras**: nivel del tanque de agua, conteo agregado de entradas y salidas, temperatura y humedad.
   - El nivel del río se toma de las fuentes oficiales (CVC o IDEAM); no lo mide un sensor propio.

**Demo integrada:**
1. Alerta naranja del Cauca.
2. El sistema recomienda 3 espacios.
3. Brecha de 9 baños → EMCALI y UAESP; brecha de 200 m² cubiertos → 2 kits de la bodega X.
4. El tablero muestra "tanque al 40 %" (dato SIMULADO).
5. Cambio a sismo: la recomendación cambia.
6. Retorno: los módulos vuelven a la bodega y se firma el acta.

### Filtro legal por capa (a cargo de quien lleva el marco legal)
| Capa | Riesgo | Norma | Cómo lo resolvemos |
|---|---|---|---|
| Decisión | Que la herramienta decida | Ley 1523 de 2012 | Recomienda; decide la Secretaría o el Consejo Municipal |
| Decisión | Que se confunda con una evaluación estructural | Ley 400 de 1997 y NSR-10 | Evitar la palabra "peritaje"; solo registrar si hay evaluación vigente y su fecha |
| Decisión | Datos de personas | Leyes 1581 de 2012 y 1098 de 2006 | Solo conteos por ciclo vital |
| Adecuaciones | Obras en el espacio público | Decreto 1504 de 1998; POT (Acuerdo 0373 de 2014); licencia de intervención y ocupación del espacio público, Decreto 1077 de 2015 (verificar) | Solo se recomiendan; las ejecuta la entidad competente con licencia |
| Kit PVC | Incendio: el PVC libera cloruro de hidrógeno (gas tóxico) al quemarse | Ley 1575 de 2012 (Bomberos) | Material con retardante de llama y ficha técnica; **se pide concepto a Bomberos**, nosotros no lo emitimos |
| Kit PVC | Estabilidad frente a viento y réplicas | NSR-10 y su aplicación a estructuras temporales (verificar) | Diseño y firma de un profesional competente; en el prototipo, solo la ficha |
| Kit PVC | Condiciones dignas y protección | Estándares Esfera (3,5 m² por persona); Ley 1257 de 2008; Ley 1618 de 2013 | Módulos con divisiones, zonas diferenciadas y accesibilidad |
| Kit PVC | Compra | Ley 80 de 1993, Ley 1150 de 2007; contratación especial en calamidad, Ley 1523 art. 66 (verificar el alcance) | Comprar y guardar **antes** por contratación ordinaria; no depender de la urgencia manifiesta |
| Kit PVC | Uso en eventos | Marco de aprovechamiento económico del espacio público de Cali (verificar) | El kit es de la Alcaldía; el uso en eventos queda reglado y **tiene prioridad la emergencia** |
| Kit PVC e IoT | Fin de vida útil | Ley 1672 de 2013 (RAEE, residuos electrónicos) | Plan de devolución y reciclaje de los sensores |
| IoT | Espectro y equipos | Resolución ANE 105 de 2020 (uso libre en 915–928 MHz, 2,4 GHz y 433 MHz); homologación CRC | Solo equipos homologados en bandas de uso libre |
| IoT | Rastreo de personas | Ley 1581; líneas rojas del reto | Sin cámaras ni captura de direcciones MAC o Bluetooth; solo conteos anónimos y variables ambientales |
| IoT | Seguridad y apertura | Decreto 767 de 2022 (MSPI); Ley 1712 de 2014 | Cifrado; datos operativos agregados como datos abiertos |
| IoT | Alertas oficiales | Ley 1523 (competencias) | Los sensores dan datos operativos; las alertas las emiten el IDEAM, la CVC, el SGC o la autoridad |

## 6.2 Datos reales y zonas más afectadas (25 de septiembre)
**Decisión:** el alcance es Santiago de Cali y el prototipo usa **datos reales y públicos**, no simulados. El detalle está en `docs/DATASETS.md`, los datos en `prototipo/datos/` y los scripts en `prototipo/scripts/`.

- **Sismo del 10 de agosto:** 1.090 puntos de daño georreferenciados (Copernicus EMSR916, ICube-SERTIT, Microsoft/Airbus y sedes del MEN) cruzados con las comunas. Las más afectadas son la **19** (Nueva Tequendama, Cuarto de Legua, Los Cámbulos), la **20** (Siloé), la **2**, la **13**, la **9** (Barrio Obrero, Sucre) y la **3**. *Sesgo:* la cobertura satelital es parcial, así que hay que pedir el RUD por barrio.
- **Cifras oficiales:** RUD con corte al 17 de septiembre: 45.138 familias, 879 viviendas destruidas y 16.357 averiadas. Balance del 23 de septiembre: 3.403 edificaciones evaluadas (1.078 rojo, 1.272 amarillo y 1.053 verde) y 333 personas en alojamientos temporales.
- **Hallazgo multiamenaza con datos:** en el occidente y el sur (comunas 1, 3, 9, 17, 18, 19 y 20) estuvo el daño sísmico, pero la falta de intersección en el cruce puntual original **no acredita aptitud como albergue ni ausencia de amenaza**; requiere evaluación técnica. En el oriente, sobre el Jarillón (comunas 6, 7, 13, 14 y 21), entre el 55 y el 92 % de los espacios tiene amenaza alta de inundación y casi todos están en suelo licuable, lo que exige revisión específica antes de proponer funciones; el cruce no autoriza alojamiento ni amortiguación por sí solo.
- **Validación de la Defensoría:** los parques de Chiminangos I y II y de Calimio, donde hubo albergues autogestionados, tienen amenaza **alta** de inundación, están en suelo **licuable** y quedan **a entre 72 y 152 m del dique** del río Cauca en Urbanización Calimio.
- **Vacíos:** el RUD y las evaluaciones por barrio, el nivel del río en Juanchito (la CVC no tiene API), el aforo y los servicios de los escenarios, la población de 2026 por comuna y las redes de EMCALI.

## 6.3 Maqueta 3D — paso 1 (25 de septiembre)

Se inició la estructura de `PROMPT_CODEX_3D.md`, siguiendo su instrucción de detenerse al terminar cada paso. `maqueta3d/src/data/site.ts` centraliza las medidas, las posiciones relativas, el equipamiento, la procedencia y los cálculos. Las dimensiones desconocidas se conservan como `null` con marcador **POR MEDIR**. El detalle pendiente está en `maqueta3d/PENDIENTES.md`.

- Se leyó la ficha RETO-01 del portafolio local y se incorporó en `docs/portafolio_retos_alcaldia_cali.pdf`: confirma **143 personas** en la Cancha de Hockey. Es evidencia del caso descrito por el reto, no un reporte de ocupación actual.
- Cálculos reproducibles según el prompt: **8 kits, 5 interiores, 3 exteriores, 8 baños y 2.145 L/día de uso no potable**. Los 5 kits interiores se obtienen por división de áreas; **no demuestran encaje físico ni aforo autorizado**.
- Las medidas deportivas se transcriben de la propuesta; falta verificar sus referencias y medir el sitio. Hockey: https://www.fih.hockey/static-assets/pdf/fih-junior_world-cup-_events_field_specifications-16-01-05.pdf · Voleibol: https://faculty.kfupm.edu.sa/pe/abuhilal/volleyball_rules.html
- Quedan por verificar la interpretación del parámetro de agua frente a Esfera, cantidad y capacidad útil de tanques, distribución, accesibilidad y evaluaciones estructurales vigentes. No se deduce disponibilidad de suministro del volumen geométrico.
- Se aplica el filtro de autoridad, estructura, Bomberos, minimización de datos y explicabilidad. No se implementa registro nominal; el eventual código de demostración no puede vincularse a personas. La trazabilidad simulada de lotes prevista en el prompt requiere resolver su diferencia con la restricción de simulación de AGENTS.md antes del paso 4.
- El paso 1 incluye solo datos TypeScript; todavía no hay escena navegable, capturas ni exportación GLB.

## 6.4 Mapa por sector y escena general — paso 2 (25 de septiembre)

Por solicitud del equipo, antes de distribuir el refugio se construyó un mapa con datos reales. La aplicación en `maqueta3d/` integra **Vite + React + TypeScript estricto + Leaflet + Fiber/Drei** y se abre con `cd maqueta3d` y `npm run dev` (instalar primero con `npm ci`).

- **Verificación de origen:** nueve capas descargadas completas desde WFS IDESC coinciden en geometrías y atributos con los originales archivados (sin comparar IDs transitorios del servicio). Resultado en `maqueta3d/public/data/source-checks.json`, fuentes/licencias/huellas SHA-256 en `manifest.json`. Se consultaron las fichas primarias https://datos.cali.gov.co/dataset/epou-espacio-publico-efectivo y https://datos.cali.gov.co/dataset/inundacion-fluvial. Descargas: https://ws-idesc.cali.gov.co/geoserver/ows (URL parametrizada de cada capa en el manifiesto y en `prototipo/datos/FUENTES.md`).
- **Cobertura:** 1.970 polígonos EPOU y 1.021 registros deportivos. No equivalen a 2.991 lugares únicos: las fuentes pueden compartir predios. Se conservan 52 registros sin comuna asignada, consultables mediante filtro.
- **Sectores:** comuna y barrio/sector de los límites oficiales archivados (22 comunas y 342 barrios/sectores). El resumen agrupa 313 combinaciones observadas, incluidas filas sin asignar; no es un nuevo número oficial de barrios.
- **Mapa:** filtros por comuna, barrio, inventario y cruce de amenaza; búsqueda; capas de inundación y licuación/corrimiento; fichas; descarga CSV. Los límites y datos funcionan desde archivos locales; las calles opcionales requieren internet.
- **Método:** toda la huella EPOU frente a polígonos de amenaza, incluido contacto de borde; solo el punto disponible para escenarios deportivos. El cruce da 884 registros con intersección de inundación y 1.369 con licuación/corrimiento. Son resultados derivados del método, no evaluaciones técnicas ni cifras oficiales de riesgo.
- **Corrección:** “sin cruce detectado” no significa “sin amenaza” ni “apto”. Se corrigieron conclusiones excesivas en `docs/DATASETS.md` y en esta bitácora. El CSV histórico no alimenta la clasificación del mapa.
- **Disponibilidad:** no hay confirmaciones documentadas de aforo, baños, agua, evaluación estructural vigente, administración/acceso o activación. Todos los espacios se marcan **por confirmar**; no se inventan zonas disponibles. Quedan por consultar las entidades y por incorporar otras amenazas.
- **Privacidad:** exportación por lista de atributos permitidos; se excluyen visitadores, contactos e identificadores prediales. No hay personas ni registros nominales en la aplicación.
- **Escena general:** hockey, volumen genérico del coliseo, diamante y recuadro de Evangelista Mora; órbita y vistas predefinidas. Posiciones aproximadas y dimensiones ilustrativas/por medir rotuladas. Las medidas están en `src/data/site.ts`. La escena no está georreferenciada al mapa: falta confirmar los escenarios de nombre genérico del catálogo.
- **Validación:** compilación de producción y TypeScript estricto sin errores; 3 pruebas de geometrías/integridad y 2 pruebas de navegador (escritorio y móvil) aprobadas. Capturas en `maqueta3d/deliverables/renders/`.
- **Pendiente del prompt:** distribución de refugio (paso 3), acopio (4), estados (5) y GLB/renders finales (6). Las capturas actuales documentan únicamente el mapa y la escena general.

## 6.5 Google Maps y zona de refugio — paso 3 (25 de septiembre)

A petición del equipo se mejoró la referencia visual del mapa y se avanzó al paso 3 de `PROMPT_CODEX_3D.md`.

- **Mapa:** calles OpenStreetMap activadas por defecto y capas de amenaza menos opacas. Cada ficha y el panel sobre el mapa enlazan el punto IDESC a Google Maps, vista satélite y Street View. Sin selección, el enlace de zona sigue el centro y zoom al desplazar el mapa. Los enlaces usan coordenadas, no nombres ambiguos ni Place IDs inventados. Google se abre en otra pestaña; la base de la aplicación sigue siendo OpenStreetMap, con atribución. No se pide geolocalización personal.
- **Fuente técnica:** documentación oficial Google Maps URLs, https://developers.google.com/maps/documentation/urls/get-started. Incluye `api=1`, codificación de parámetros y conversión GeoJSON longitud/latitud → latitud,longitud. No requiere clave de API. No se copiaron teselas de Google.
- **Límites visibles:** punto de referencia del inventario, no entrada verificada; Street View depende de cobertura y las imágenes deben revisarse por fecha. Google Maps no certifica disponibilidad, aforo ni seguridad. Si las calles no cargan, aparece un aviso y las geometrías IDESC siguen disponibles.
- **Refugio:** 5 kits interiores y 3 exteriores, 5 particiones de 2 × 2 m por kit, 3 cubiertas exteriores, 2 módulos cerrados (NNA y salud), 8 baños, kit solar portátil, 2 tanques ilustrativos junto al coliseo conectados con bajantes superficiales y punto de registro (mesa, lector y pantalla). Todo el equipamiento es propuesto, no un inventario instalado.
- **Disposición:** las huellas interiores son franjas de 4,8 × (70/4,8) m, conservan 70 m² y caben geométricamente en la referencia 24 × 15 m sin solaparse; las cubiertas exteriores mantienen 10 × 7 m. Este encaje matemático no certifica circulación, evacuación, accesibilidad, dignidad del alojamiento ni aforo: requiere validación profesional. Las medidas/posiciones se centralizan en `maqueta3d/src/data/site.ts`.
- **Privacidad:** pantalla con código ficticio DEMO-0001 y conteos “143 personas · 40 menores · SIMULADO”; no hay registro individual, identificación, reconocimiento facial ni datos personales. Se mantiene la decisión de activación en la autoridad y los conceptos técnicos en sus responsables.
- **Agua:** dos tanques dibujados a modo ilustrativo; cantidad operativa y capacidad útil siguen sin confirmar. Los 2.145 L/día son el cálculo de referencia solicitado, no suministro demostrado ni validación de su interpretación frente a Esfera.
- **Interacción 3D:** vistas general, campo, coliseo, registro y acopio; órbita y control de cubiertas. Capturas del refugio, campo y registro a 1920 × 1080, además de la captura del mapa vinculado a Google Maps.
- **Validación:** compilación de producción y TypeScript estricto aprobados; 7 pruebas de lógica/geometría y 4 de navegador aprobadas, con repetición dirigida de la prueba de refugio tras ajustar etiquetas y sombras. No se validaron servicios operativos ni la identificación exacta de los escenarios en Google.
- **Pendiente:** paso 4 (centro de acopio y ruta), paso 5 (estados y transiciones) y paso 6 (GLB y revisión/capturas finales).

## 6.6 Centro de acopio y ruta al refugio — paso 4 (25 de septiembre)

Se construyó el centro de acopio en el volumen ilustrativo del Diamante de Béisbol, siguiendo `docs/propuesta_cali_activa.md` (Centros de acopio por zona y Trazabilidad de insumos) y `PROMPT_CODEX_3D.md`, sección 3. No se incorporaron datasets ni cifras externas nuevas.

- **Siete sectores seleccionables:** lista pública de necesidades, recepción, clasificación, descarte, bodega/inventario, despacho y pantalla de trazabilidad. Etiquetas 3D y panel HTML accesible por teclado con la explicación de cada función.
- **Mobiliario ilustrativo:** cartelera, mesa, cinco contenedores de clasificación (alimentos, agua de uso no potable, aseo, abrigo y kits), contenedor de descarte, estanterías, plataformas de despacho y pantalla. El número y tamaño de los muebles son decisiones visuales de la maqueta, no inventario real. Valores centralizados en `maqueta3d/src/data/site.ts`.
- **Flujo:** recepción → clasificación; aceptados → bodega → despacho. Los rechazados van a descarte por un ramal independiente sin salida hacia bodega/despacho. La conexión gráfica a trazabilidad representa registrar un movimiento, no trasladar allí el insumo.
- **Necesidades:** se muestran los requerimientos brutos calculados en el escenario de 143 personas, sin restar existencias desconocidas. No se presentan como faltantes confirmados ni como donaciones recibidas.
- **Ruta conceptual:** conecta el despacho con el acceso propuesto junto al registro del refugio; tiene flechas, vista de cámara propia y control para mostrar/ocultar. Evita el equipamiento dibujado del campo, pero **no es ruta vial, de evacuación ni levantamiento georreferenciado**. Falta verificar accesos, circulación y obstáculos reales.
- **Trazabilidad:** interfaz con lote, tipo, cantidad, origen, destino y hash. Estado **Sin registro verificado**; no hay cantidades de existencias, movimientos o hash inventados ni conexión a blockchain. Se resolvió la diferencia con el ejemplo simulado del prompt dando prioridad a AGENTS.md, que limita la simulación a IoT y ocupación. Es necesario un lote real validado para poblar la pantalla.
- **Alcance y competencias:** los muebles y el trazado son ilustrativos; la disponibilidad real del diamante, sus dimensiones, accesos y operación requieren validación. Se mantiene la activación en la autoridad y los conceptos de estructura, seguridad y Bomberos en sus responsables. Sin personas, dinero ni identificación individual en la trazabilidad.
- **Archivos:** `maqueta3d/src/Storage.tsx`, integración en `SiteScene.tsx`, datos en `site.ts`, estilos, pruebas y documentación. Capturas de acopio, trazabilidad y ruta en `maqueta3d/deliverables/renders/`, a 1920 × 1080.
- **Validación:** compilación de producción y TypeScript estricto aprobados; 11 pruebas de lógica/geometría y 6 de navegador aprobadas. Se verificaron sectores sin solapamiento, descarte separado, ruta sin colisiones con el equipamiento representado, trazabilidad vacía, teclado y móvil. Las pruebas no validan condiciones físicas ni disponibilidad real.
- **Pendiente:** incorporar lote/inventario real verificado, validar la operación con actores y continuar con estados/transiciones (paso 5) y GLB/revisión final (paso 6).

## 6.7 Estados y transiciones de la maqueta — paso 5 (25 de septiembre)

Se implementó la sección 4 de `PROMPT_CODEX_3D.md`, siguiendo el uso cotidiano y la Fase 4 de `docs/propuesta_cali_activa.md`. No se incorporaron datasets ni cifras externas nuevas.

- **Selector accesible:** Uso cotidiano, Emergencia (sismo) y Recuperación, con estado seleccionado, explicación y aviso de transición. El selector representa una propuesta visual; no modifica el estado operativo ni autoriza activaciones.
- **Reutilización:** se conservan los mismos ocho kits en la escena. En uso cotidiano forman stands de feria en el campo; en emergencia vuelven a las cinco posiciones interiores y tres exteriores; en recuperación se compactan primero y luego se desplazan a la bodega ilustrativa. Campo y coliseo quedan sin equipamiento temporal. El desplazamiento visual no representa una ruta logística validada ni movimientos reales de inventario.
- **Uso cotidiano:** tanques con conexión superficial ilustrativa a zona verde para riego de uso no potable. No se inventan caudal, suministro ni evento programado. Acopio vacío; registro y servicios de emergencia ocultos.
- **Transiciones:** admiten cambios rápidos de destino desde la posición visual actual. Control de movimiento reducido, respetando también la preferencia del sistema. Cámaras y cubiertas continúan disponibles.
- **Información contextual:** cifras de refugio, registro SIMULADO, panel de acopio y ruta de despacho solo aparecen en emergencia. Recuperación recuerda la revisión, limpieza y acta pendientes, sin certificarlas.
- **Límites:** geometría y secuencia ilustrativas; sin datos personales, identificación facial, logos ni obra civil. La autoridad conserva la decisión y las evaluaciones estructurales y conceptos de Bomberos corresponden a sus responsables. No hay disponibilidad real confirmada ni trazabilidad inventada.
- **Validación:** compilación de producción y TypeScript estricto aprobados; 12 pruebas de lógica/geometría y 8 pruebas de navegador aprobadas por bloques. Incluyen conservación/encaje de kits, ciclo completo, interrupciones rápidas, retorno a emergencia, movimiento reducido, teclado, móvil y regresión de mapa/refugio/acopio. Capturas revisadas y etiquetas/encuadre corregidos. No validan operaciones reales.
- **Archivos:** `maqueta3d/src/Lifecycle.tsx`, `SiteScene.tsx`, `Refuge.tsx`, medidas y cantidades en `src/data/site.ts`, estilos, pruebas y documentación. Capturas de revisión `cotidiano.png` y `recuperacion.png`; la exportación GLB y revisión final pertenecen al paso 6.

## 6.8 Entrega de la maqueta — paso 6 (25 de septiembre)

Se implementó la exportación local de la escena de emergencia mediante `GLTFExporter` de Three.js, conforme a `PROMPT_CODEX_3D.md`, secciones 5–7. No se agregaron datasets ni cifras externas.

- **Descarga:** botón “Descargar emergencia en GLB”, habilitado al completar la transición a emergencia con cubiertas y ruta visibles. Se exporta una copia independiente de la escena y no se envía a servicios externos. Se evita exportar posiciones intermedias, incluso con movimiento reducido.
- **Archivo:** `maqueta3d/deliverables/renders/cali_activa.glb`, geometría estática con kits, servicios propuestos, acopio y ruta. Metadatos con unidades, procedencia, cantidades, limitaciones y trazabilidad sin registro verificado. No incluye pantallas/etiquetas HTML, animaciones, controles, mapa IDESC ni el recuadro externo de Evangelista Mora.
- **Capturas:** `general.png`, `refugio_coliseo.png`, `refugio_campo.png`, `acopio.png`, `registro.png`, `cotidiano.png` y `recuperacion.png`, a 1920 × 1080. La cubierta del coliseo se oculta solo en su captura para permitir revisar las particiones.
- **Reproducibilidad:** `npm run deliverables` genera capturas y GLB; `npm run verify:deliverables` valida el GLB, comprueba dimensiones y genera `manifest.json` con tamaños y SHA-256. `LEEME.md` acompaña los archivos con fuentes y límites; `validacion_glb.json` conserva el informe del validador.
- **Revisión de líneas rojas:** sin datos personales, reconocimiento facial, logos, fachadas reales ni obra civil. Registro agregado SIMULADO; inventario/hash desconocidos, no inventados. Agua rotulada de uso no potable. Equipos, distribución y ruta ilustrativos; dimensiones por medir explicitadas. Autoridad, evaluación estructural y conceptos de Bomberos permanecen en sus responsables.
- **Validación final:** `npm run build` aprobado; 12 pruebas de lógica/geometría y 9 de navegador aprobadas por bloques. El GLB se recargó con GLTFLoader: 8 kits, 40 particiones, 8 baños, 2 tanques, 2 módulos cerrados, 7 sectores y ruta presentes; kits en posiciones finales. glTF Validator: **0 errores y 0 advertencias**, con avisos informativos de atributos UV no usados (no hay texturas) y nodos vacíos de etiquetas HTML. Siete PNG a 1920 × 1080, revisados visualmente.
- **Límites pendientes:** mediciones y orientación reales, disponibilidad/servicios/accesibilidad, evaluaciones técnicas, inventario de insumos verificado y validación con actores. La entrega técnica de la maqueta no resuelve esos pendientes operativos ni valida por sí misma IRL 3.

## 6.9 Mediciones preliminares — alcance sin validación con entidades (25 de septiembre)

Por instrucción del usuario se deja **fuera de esta etapa** la validación con entidades y se pasa a mediciones. No se marca como validación realizada ni se certifican condiciones operativas. La idea principal del frontend sigue siendo explorar espacios/amenazas y explicar su transformación: hoy implementa mapa y maqueta; la recomendación multiamenaza y el tablero completo de brechas siguen pendientes.

- **Fuente nueva:** WFS `catastro:cat_bas_construcciones` de IDESC, recorte del piloto, solicitando solo `the_geom` (51 geometrías con propiedades vacías). URL de descarga/licencia por verificar registradas en `prototipo/datos/FUENTES.md` y `fuentes.csv`. No se descargaron atributos personales ni prediales. No se presume la licencia de la capa distinta de SIBICA.
- **Voleibol:** una construcción contiene los puntos `deporte-230`, `deporte-268` y `deporte-791`; se considera candidata a Francisco Chois, no identificación confirmada. Huella calculada ≈ **3.069 m²**, perímetro **236,7 m**, envolvente **68,7 × 47,0 m**, eje largo **47,5° respecto al norte**. No son dimensiones interiores, superficie disponible ni número actual de canchas. La precisión de la fuente no está verificada.
- **Hockey:** la fuente municipal identifica a Miguel Calero como **coliseo de hockey en línea**, en contradicción con la referencia de campo abierto 91,40 × 55 m utilizada por la propuesta. No tratar esa referencia como medida real del sitio ni como área disponible. La maqueta anterior permanece conceptual, sin recalibrar hasta aclarar la identidad/planta. Fuentes: https://www.cali.gov.co/deportes/publicaciones/139089/escenarios-gratuitos/ y https://idesc.cali.gov.co/download/turismo/recursos_zonas/RT-65-C19p.pdf.
- **Evangelista Mora:** la ficha municipal publica **3.586 m²** sin precisar superficie útil. Es referencia documental, no medición nueva ni aforo: https://www.cali.gov.co/deportes/publicaciones/131771/unidades-deportivas-de-alto-rendimiento/.
- **Verificación:** regeneración del cálculo y revisión visual del SVG; control independiente por fórmula de área plana ≈ 3.069,2 m², consistente con el área esférica al redondear. Se confirmó que las 51 entidades descargadas carecen de atributos. No se modificó el frontend ni el GLB de la maqueta.
- **Entregables:** `maqueta3d/deliverables/mediciones/LEEME.md`, medidas JSON, distancias rectas entre puntos CSV (incluye alternativas de hockey) y plano SVG. Script reproducible `maqueta3d/scripts/measure-pilot.mjs`. Altura y superficie útil permanecen sin dato. Sin cambios de geometría en el GLB previo.

## 6.10 Preparación por espacio seleccionado — frontend (25 de septiembre)

Se implementó el siguiente flujo solicitado por el usuario, manteniendo fuera del alcance actual la validación con entidades. **Miguel Calero sí existe**: se corrigió la asociación falsa entre ese nombre y las medidas de un campo abierto. La pestaña anterior pasa a “Demostración de refugio”, con aviso de modelo fijo/conceptual y vínculo a la fuente municipal; el nombre del campo modelado deja de ser Miguel Calero. No se elimina ni inventa un registro del inventario público.

- **Flujo:** mapa → seleccionar un registro → “Preparar este espacio” → pestaña “Preparar intervención”. Se muestra el nombre/ID real, ubicación y Google Maps del objetivo.
- **Adaptación automática:** se dibuja la geometría Polygon/MultiPolygon del registro IDESC, conservando huecos, en coordenadas locales métricas y con encuadre automático. Solo es huella plana, sin altura ni interior inventado. Para puntos deportivos se informa que falta contorno; no se copia el piloto. La distribución de kits no es automática: requiere medidas de superficie útil, accesos y obstáculos.
- **Comparación explicable:** hasta tres polígonos EPOU del sector filtrado por comuna/barrio, ordenados por distancia recta al registro de referencia; empate por ID. No se mezclan puntos deportivos con polígonos para evitar duplicados entre fuentes; no se afirma resolver duplicados internos distintos del mismo ID. El sector y los criterios están visibles. Búsqueda, fuente y filtro de cruce del mapa no restringen esta comparación.
- **Amenazas:** inundación descarta cruces de las capas disponibles; sismo excluye de la preselección los cruces de licuación/corrimiento y exige inspección aun sin cruce. No son evaluaciones sísmicas completas. Sequía no produce candidatos porque faltan datos de amenaza/abastecimiento. No se rellenan resultados con descartados.
- **Población y servicios:** conteo agregado SIMULADO, entero entre 1 y 100.000 como límite de entrada del prototipo, no aforo. Modifica necesidades, no el orden de candidatos: no hay capacidades confirmadas. Calcula baños, agua para necesidades básicas y área habitable cubierta. Existencia desconocida permanece `null` y brecha “No calculable”; nunca se convierte automáticamente en cero. La huella no sustituye área útil cubierta.
- **Esfera:** referencias 2018 (WASH 2.1, saneamiento a medio plazo y alojamiento/espacio habitable): 15 L/persona/día, 1 baño/20 personas y 3,5 m²/persona, contextualizables. Los 15 L **no son exclusivamente uso no potable**; se corrige esa interpretación en el nuevo módulo. Fuentes: https://spherestandards.org/wp-content/uploads/Sphere-Handbook-2018-EN.pdf y https://handbook.spherestandards.org/en/sphere/. La descarga directa PDF devolvió 403 en la consulta; se contrastaron los extractos indexados y el manual en línea, sin afirmar validación operativa de la dotación.
- **Responsables y seguimiento:** UAESP, EMCALI y Gestión del Riesgo como asignaciones **propuestas por el equipo** en `docs/propuesta_cali_activa.md`, no como matriz oficial validada. Estados “Por medir”/“En revisión” guardados localmente por espacio/servicio; no permiten certificar cierre de brechas sin evidencias. Si falla almacenamiento, se informa. Descarga JSON con escenario, criterios, candidatos, necesidades, faltantes desconocidos, seguimiento y fuentes.
- **Privacidad y límites:** datos públicos y conteos simulados, sin identificación individual ni reconocimiento facial. No se envían comunicaciones, no se activa un espacio y no se emiten evaluaciones estructurales o conceptos de Bomberos. Continúa pendiente el motor de aptitud operacional con caracterización real de servicios y aforos.
- **Archivos:** `Intervention.tsx`, `SelectedSpaceScene.tsx`, `planning.ts`, integración en `App.tsx`; referencias y parámetros en `src/data/site.ts`. Corrección conceptual en `SiteScene.tsx`, estilos y pruebas. Sin datasets nuevos.
- **Validación:** compilación de producción y TypeScript aprobados; 17 pruebas de lógica/geometría y 11 de navegador aprobadas por bloques. Se comprobaron cambio de huella, puntos sin contorno, escenarios, necesidades, brechas desconocidas, seguimiento local, exportación JSON, móvil y regresiones del mapa y la demostración. Captura `intervencion.png` revisada; siete capturas finales y GLB regenerados, con 0 errores y 0 advertencias del validador glTF. Las pruebas verifican el software, no la disponibilidad física de los espacios.

## 6.11 Revisión de representación 3D y skills (25 de septiembre)

El usuario pidió corregir la falta de lógica física visible de la maqueta e instalar skills de renderizado. El enlace https://worldskills.org/skills/id/483/ describe la especialidad **3D Digital Game Art**; no contiene una skill instalable de Codex ni se instaló software de WorldSkills.

- **Skills instaladas:** `threejs-r3f`, `threejs-lighting`, `threejs-materials` y `threejs-geometry`, desde https://github.com/cesartevisual/threejs-skills, revisión `84f9bcb4bea1f7a28d57fe7f0af78f7f9c3dc467`. Se revisaron sus instrucciones y se usó el instalador del sistema. Ubicación local: `~/.codex/skills/`; no se añaden dependencias del frontend ni scripts del proveedor al repositorio. Disponibles en el siguiente turno; se aplicaron sus guías leídas durante esta revisión.
- **Cubiertas y apoyos:** techos opacos con pendiente, cerchas/travesaños y apoyos visibles; cubiertas de carpas, registro y sectores de acopio. Las particiones interiores se alojan bajo el techo conceptual del coliseo; la feria exterior incorpora cubierta. Ocultar techos activa un aviso explícito de “Vista de corte”, no un estado operativo sin protección.
- **Agua:** vista dedicada “Sistema de agua”. Dos recipientes superficiales ilustrativos junto al coliseo, base, jaula, tapa, canaleta, bajantes, filtro propuesto, entradas superiores, salidas bajas, rebose, válvula y bomba propuesta. Los tramos se construyen por extremos conectados. Panel con secuencia captación → entrada → almacenamiento → servicio; agua exclusivamente no potable. No se conecta a consumo humano ni se supone alimentación de baños portátiles. Capacidad útil, caudal, energía, primeras aguas, tratamiento y destino final del rebose pendientes; la lluvia no acredita continuidad del suministro. No se simula circulación de agua ni nivel de llenado como si estuvieran medidos.
- **Renderizado:** materiales opacos con rugosidad, iluminación direccional/hemisférica, exposición y encuadre de sombras ajustados por vista; no se agregan modelos descargados, texturas remotas ni datos de espacios inventados.
- **Límites:** geometría constructiva **propuesta y por verificar**, centralizada en `construction` dentro de `src/data/site.ts`. No es cálculo de cargas, estabilidad, anclajes, simulación hidráulica ni levantamiento del sitio. Siguen fuera de alcance la validación con entidades y la certificación de activación. Sin datos personales, identificación individual o reconocimiento facial; se conservan controles HTML y contraste.
- **Verificación:** compilación y TypeScript aprobados; 17 pruebas de lógica y 8 pruebas de navegador relevantes aprobadas por bloques (mapa/refugio, agua, acopio, ciclo y entregables). Se revisaron capturas y se corrigió la orientación inicial de los faldones. El GLB se recargó y comprobó con rayos que la cumbrera esté más alta que los aleros; conserva 23 faldones/techos opacos y los elementos del circuito de agua. glTF Validator: 0 errores y 0 advertencias. Diez PNG 1920 × 1080 y manifiesto SHA-256 regenerados; metadatos GLB incluyen procedencia y condición ilustrativa de la construcción.

## 6.12 Incendios en el flujo de preparación (25 de septiembre)

Se incorporan **Incendio forestal** e **Incendio en edificación** en “Preparar intervención”, a petición del usuario. Es preparación de atención a población; no simulación de propagación, combate al fuego ni evaluación de seguridad humana.

- **Datos consultados:** el GetCapabilities WFS de IDESC no devolvió una capa de incendios en la consulta; las capas de protección forestal no se interpretan como amenaza. Fuente de acceso oficial: https://www.cali.gov.co/planeacion/publicaciones/46691/servicios-wms-idesc/; servicio consultado: https://ws-idesc.cali.gov.co/geoserver/ows?service=WFS&request=GetCapabilities.
- **Hallazgo no incorporado:** una capa pública ArcGIS llamada “Zonas de amenaza por incendios forestales”, en https://services7.arcgis.com/fHfQ8qeNWagUQB9e/arcgis/rest/services/BDG_Bomberos_Cali_WFL1/FeatureServer/6, tiene descripción/atribución vacías y su ficha https://www.arcgis.com/sharing/rest/content/items/43695bad5c514344a027330550bcd9b3?f=json no declara licencia. El título no acredita procedencia oficial. No se descargó geometría, no se agregó como dataset y no se usa para decisiones. Esto no prueba que no existan otras fuentes oficiales.
- **Reglas:** ambos escenarios devuelven “sin evidencia suficiente”, sin candidatos, aunque el espacio no cruce inundación/sismo o esté cerca de la referencia. No se infiere el foco a partir de la selección del mapa ni se inventan radios de seguridad. Se separan en el resumen los descartes por cruce cartográfico de los casos pendientes por falta de evidencia; también se corrige esa distinción para sequía. Amenazas no soportadas no producen una recomendación por defecto.
- **Preparación por subtipo:** forestal requiere información de área/restricciones, accesos, amenaza/interfaz con vegetación y humo/entorno. Edificación requiere área/restricciones, accesos, edificio/entorno e inspecciones. Es una lista de información propuesta por el equipo, no un protocolo oficial. Las evidencias permanecen `null`.
- **Seguimiento y exportación:** “Por medir”/“En revisión” por espacio, subtipo y tarea, guardados solo en el navegador. Ningún cambio de tarea habilita recomendaciones ni acredita seguridad. El JSON incluye subtipo, decisiones, conteos de casos sin evidencia, tareas, fuentes de contexto y límites. Cambiar entre incendio e inundación no mezcla reglas ni tareas.
- **Agua y maqueta:** las necesidades humanitarias de agua no representan caudal de extinción; los tanques ilustrativos no son una red contra incendios. No se acredita resistencia al fuego de materiales ni aptitud del kit. No se añaden llamas, humo ni perímetros ficticios a la geometría real.
- **Fuentes primarias de contexto institucional:** https://www.cali.gov.co/gestiondelriesgo/publicaciones/140522/recomendaciones-en-caso-de-emergencias/ y https://www.cali.gov.co/gestiondelriesgo/publicaciones/184412/por-inconsciencia-ciudadana-nuevamente-se-presenta-incendio-forestal-en-pichinde/. Son contexto sobre atención de emergencias, no evidencia de aptitud de cada predio.
- **Filtro obligatorio:** solo datos públicos y conteos agregados SIMULADOS; sin identificación personal o reconocimiento facial. Criterios y vacíos visibles, controles con etiquetas y soporte móvil. Recomienda sin activar; no sustituye a la autoridad, evaluaciones estructurales ni conceptos de Bomberos. Se mantiene fuera del alcance actual la validación con entidades.
- **Verificación:** compilación/TypeScript y 18 pruebas de lógica aprobadas. Cuatro pruebas de navegador aprobadas (dos específicas de incendios y dos de regresión de preparación): subtipos, persistencia, exportación, falta de candidatos, agua humanitaria, regreso a inundación, teclado y móvil. Captura `incendio_forestal.png` revisada visualmente; no se validó eficacia ante incendios reales.

## 6.13 Corrección del botón Revisar (25 de septiembre)

El usuario reportó que “Revisar epou-9465” no mostraba nada. Se reprodujo con el registro real **Parque · Colinas del Sur · EPE_1064**: el botón solo actualizaba el estado del espacio, dejando su ficha más abajo sin desplazar la vista. Al pulsar el espacio ya seleccionado, no ocurría ningún cambio visible.

- Cada clic ahora selecciona el espacio y, después de actualizar el contenido, desplaza la vista y enfoca el título de su ficha. Funciona también al repetir el mismo ID y con teclado.
- “Revisar el espacio de referencia” usa la misma navegación. Los botones vinculan el contenido mediante `aria-controls`; la ficha tiene título accesible y foco visible.
- La corrección no modifica geometrías, reglas de amenaza, aptitud, disponibilidad ni evaluación técnica. Sigue siendo una revisión informativa, sin activar espacios o emitir conceptos de Bomberos; sin datos personales nuevos.
- Se agregó prueba de regresión con `epou-9465` en escritorio y móvil, comprobando clic inicial, otro candidato, repetición y teclado. La prueba reprodujo el fallo antes de la corrección. Tras corregirlo: compilación/TypeScript aprobados y cuatro pruebas de navegador aprobadas (dos nuevas y dos de regresión del flujo de preparación).

## 6.14 Avisos de acopio para toda la población (25 de septiembre)

El usuario solicita comunicar por SMS la ubicación de los puntos de acopio definidos y aclara que el público es **toda la población**, sin identificar previamente quién es damnificado. Se incorpora a la ficha de preparación “Preparar aviso SMS de acopio”.

- **Contenido:** nombre e ID del espacio real, enlace Google Maps con sus coordenadas, horario propuesto e información de recepción/entrega de ayudas. Mensaje general para quienes puedan colaborar, quienes necesiten ayudas y quienes quieran informarse.
- **Estado actual:** borrador revisable, copiable y descargable en JSON. No hay proveedor SMS conectado, envío real, destinatarios ni confirmaciones de entrega. No se afirma cobertura de toda Cali. `audience=general-population`, `deliveryStatus=not-sent`, `recipients=null`, `openingConfirmed=false`.
- **Zonas todavía no habilitadas:** seleccionar un espacio no lo convierte en acopio abierto. El borrador indica apertura no confirmada y no invita a acudir todavía. Los campos propuestos no acreditan inventario, horarios efectivos, capacidad o rutas seguras. La autorización de activación sigue correspondiendo a la autoridad.
- **Privacidad:** no se piden teléfonos, nombres, condición de damnificado ni datos de menores. Los campos operativos permanecen en memoria; se limpian al cambiar de espacio para no atribuir horarios o ayudas al lugar equivocado. No hay comunicaciones externas automáticas.
- **Integración pendiente:** proveedor/canal, cobertura, distribución a población, suscripciones y bajas cuando corresponda, revisión/autorización del aviso y estados de entrega. Un SMS preparado no equivale a difusión masiva ni reemplaza un canal oficial. No se contrata ni activa ningún servicio de pago.
- **Filtro del proyecto:** conserva datos públicos y criterios explícitos, no decide activación ni sustituye evaluaciones estructurales o Bomberos, sin reconocimiento facial o identificación individual; controles etiquetados y vista móvil. La validación con entidades continúa fuera de esta etapa.
- **Verificación:** compilación/TypeScript aprobados y tres pruebas de navegador aprobadas por bloques: aviso general en móvil (coordenadas, descarga sin envío, vacíos y limpieza al cambiar de espacio) y dos regresiones de Revisar en escritorio/móvil. Se corrigió una etiqueta del borrador detectada durante las pruebas.

## 6.15 Difusión simulada y cultura ciudadana (25 de septiembre)

Por instrucción expresa del usuario, el canal SMS se implementa **como simulación para el prototipo**, sin proveedor real. Esta excepción amplía el alcance de simulación autorizado en esta etapa; no altera los datos geográficos públicos ni confirma aperturas.

- **Recorrido:** mapa → seleccionar espacio → Preparar este espacio → Preparar aviso SMS de acopio → **Simular envío masivo**. Incluye vista previa marcada SIMULADA, audiencia agregada ficticia configurable, procesamiento y resultados. Escenarios deterministas: entrega completa o 5 % pendientes (redondeado hacia arriba); son cifras ilustrativas elegidas para la demo, no métricas medidas ni cobertura real de Cali.
- **Privacidad y estados:** cero envíos reales, sin proveedor, teléfonos, contactos, credenciales ni solicitudes de envío por red. Se bloquea el doble clic durante el proceso. Editar el aviso o cambiar el espacio reinicia los resultados. El mensaje conserva apertura no confirmada: no invita a acudir a un punto sin habilitación.
- **Nueva pestaña “Análisis preventivo”:** orientación antes/durante/después para inundación, sismo e incendio forestal; explicación de encuentro/acopio/alojamiento; revisión de fuente, fecha, apertura y acceso; enlace al mapa y a Gestión del Riesgo de Cali. Lista de aprendizaje sin persistencia y pregunta interactiva para distinguir un registro cartográfico de un punto habilitado.
- **Límites:** contenido educativo, no alerta vigente, orden de evacuación, evaluación estructural ni concepto de seguridad contra incendios. No calcula rutas seguras. La autoridad conserva la decisión de activación. Sin identificación individual, reconocimiento facial o datos personales; controles etiquetados y uso móvil. La validación con entidades sigue fuera de esta etapa.
- **Verificación:** compilación TypeScript/Vite aprobada; tres pruebas de navegador aprobadas (borrador en móvil, simulación sin solicitudes de envío y aprendizaje interactivo móvil). Verifican validación de audiencia, bloqueo durante envío simulado, resultados, reinicio al editar, cambio de amenaza y retorno al mapa.
- **Pitch:** segmento listo para narrar en `entregables/guion_prevencion_difusion.md`. Explica la conexión entre preparación, territorio y comunicación, sin atribuir resultados reales a la simulación.
- **Fuentes primarias educativas consultadas el 25 de septiembre de 2026:** [UNGRD, boletín de inundaciones](https://repositorio.gestiondelriesgo.gov.co/bitstream/handle/20.500.11762/32902/BoletinInundaciones.pdf?isAllowed=y&sequence=33), [UNGRD, recordatorios frente a sismo](https://portal.gestiondelriesgo.gov.co/paginas/old_noticias/2122.aspx), [UNGRD, prevención de incendios forestales](https://portal.gestiondelriesgo.gov.co/Paginas/recomendaciones-incendios-forestales.aspx) y [Gestión del Riesgo de Cali](https://www.cali.gov.co/gestiondelriesgo/). Las publicaciones son material de orientación, no evidencia de un incidente actual. No se añade ningún dataset.

## 6.16 Acopio limitado por superficie del espacio (25 de septiembre)

El usuario solicita considerar el tamaño del parque o zona al asignar acopio para evitar sobrellenarlo. La ficha de preparación incorpora un balance de superficies asociado al espacio seleccionado.

- **Base real:** área geodésica calculada por Turf sobre el Polygon/MultiPolygon público seleccionado, conservando huecos. Los registros puntuales, sin polígono, quedan sin capacidad calculable. Procedencia del inventario: DAPM/IDESC, documentada con descarga, licencia y atribución en `prototipo/datos/FUENTES.md`; fuente primaria https://idesc.cali.gov.co/. No se añade un dataset ni se altera el área original.
- **Entradas SIMULADAS / por verificar:** área no utilizable; circulación, accesos y evacuación; atención, entrega y espera; otros usos u ocupación existente; huella por módulo de almacenamiento y cantidad propuesta. Sin valores prellenados ni porcentajes normativos inventados. Los campos vacíos no equivalen a cero y se exige reservar circulación y atención.
- **Regla explicable:** superficie para almacenamiento = huella menos las cuatro reservas/exclusiones; máximo teórico de módulos = parte entera de superficie restante / huella por módulo. Las reservas no deben superponerse entre sí. Se muestran superficie pedida, restante, déficit y módulos excedentes. Las reservas que por sí solas exceden el parque también producen sobreocupación.
- **Verificación:** 22 pruebas de lógica, compilación TypeScript/Vite y cinco pruebas de navegador aprobadas; incluyen exceso, límite exacto, falta de datos, exportación de supuestos, invalidación al editar/cambiar espacio y regresiones de preparación, SMS simulado y prevención móvil.
- **Control del borrador:** solo permite “Incluir distribución de acopio en el borrador” si los datos están completos, el balance no excede la superficie y las reglas de amenaza no excluyen el espacio ni lo dejan pendiente de evidencia. Cambios de medidas, espacio o amenaza invalidan la inclusión. La exportación general incorpora entradas, resultados, regla, procedencia y `includedInDraft`; no autoriza activación.
- **Límites:** el máximo es un techo aritmético por área, no demuestra encaje de módulos en polígonos irregulares, ni aforo de personas, capacidad de carga o toneladas almacenables. La población del escenario no equivale a asistentes simultáneos. Área útil, distribución, acceso, suelo, protección de ayudas y evaluación operacional siguen por verificar. La preselección por cercanía no acredita capacidad.
- **Filtro del proyecto:** recomendación sin activar, sin evaluación estructural ni concepto de Bomberos; solo áreas y conteos agregados, sin datos personales ni reconocimiento facial; criterios visibles y controles etiquetados. La validación con entidades continúa fuera de esta etapa por decisión del usuario.

## 6.17 Video animado del proyecto: 1 minuto y 20 segundos (25 de septiembre)

A petición del usuario se produce una pieza tipo caricatura de **80 segundos**, con dos voces sintéticas en español de Colombia, música instrumental original, efectos suaves y subtítulos. Entregable: `entregables/video/cali-activa-80s.mp4`; guion, SRT, storyboard, créditos y código de regeneración en la misma carpeta.

- **Ocho escenas:** problema/propuesta; prevención; territorio real y criterios por amenaza; balance de área para acopio; necesidades y responsables propuestos; decisión de la autoridad; SMS simulado; retorno al uso cotidiano con revisión y acta como objetivo del proyecto.
- **Formato:** horizontal 1280 × 720, 24 fotogramas por segundo, 1.920 fotogramas, H.264 y AAC estéreo. Narración ajustada por escena sin cortar frases. Subtítulos incrustados y SRT separado; personajes con gestos y movimientos de boca, mapa con marcador animado y acopio con límite visual.
- **Datos y atribución:** comunas reales y polígono del parque `epou-9465` (Colinas del Sur, EPE_1064) desde los archivos públicos del repositorio. Fuente visible: Alcaldía de Santiago de Cali, DAPM/IDESC; adaptaciones cartográficas CC BY-SA 4.0. [Espacio público efectivo](https://datos.cali.gov.co/dataset/epou-espacio-publico-efectivo) y [comunas](https://www.datos.gov.co/dataset/Comunas-de-Santiago-de-Cali/dx2g-2mhm). No se incorpora ningún dataset nuevo.
- **Verificación final:** MP4 de 80,000 segundos y 1.920 fotogramas; video H.264 1280 × 720 a 24 fps y audio AAC de dos canales. Decodificación completa sin errores, señal de audio en las ocho escenas, sin recorte digital detectado y 22 bloques de subtítulos dentro de la duración y el recuadro. Storyboard y escenas revisados visualmente. Resultados reproducibles en `entregables/video/verificacion.json`.
- **Producción:** ilustraciones y música originales por código Python; tipografía DejaVu Sans; montaje con [FFmpeg](https://ffmpeg.org/); voces sintéticas Salome/Gonzalo mediante [edge-tts](https://github.com/rany2/edge-tts). Únicamente el guion público se procesa para síntesis, sin datos personales ni imitación de voces del equipo. Herramientas instaladas en rutas temporales, sin modificar dependencias del frontend.
- **Filtro del proyecto:** la pieza explica que la autoridad decide y no sustituye evaluaciones estructurales ni conceptos de Bomberos. Datos desconocidos por verificar, ocupación/medidas propuestas y SMS marcados SIMULADOS. No se envían SMS ni se presenta el parque como abierto. No es una alerta, grabación literal de la interfaz ni evidencia de validación con entidades. La devolución del espacio se presenta como parte del flujo previsto, no como un acto realizado.

## 6.18 Video v2: personajes de referencia y decisiones explícitas (25 de septiembre)

El usuario solicita mejorar el video con un diagrama de flujo más específico y los personajes que aporta en la carpeta **Imagen Refe**. Se genera una segunda versión en `entregables/video/v2/cali-activa-80s.mp4`, conservando el primer video y los 80 segundos de duración.

- **Referencia local confirmada:** el usuario trasladó la lámina a `Imagen Refe/d91e7ea3-5b16-4aea-986f-cf69824be45e.jpeg` dentro del repositorio. Se revisó visualmente: es la misma referencia utilizada para v2. Se actualizan procedencia y enlace; no se regenera el video ni se cambia su duración.
- **Personajes:** narrador de cabello castaño y bufanda; narradora pelirroja con gafas redondas. PNG transparentes adaptados con la herramienta integrada image_gen y la skill imagegen; fuentes del usuario identificadas y prompts completos en `entregables/video/v2/src/prompts-personajes.json`. Ilustraciones con movimiento suave e indicador de voz; no se imitan voces del equipo.
- **Diagrama animado:** definir amenaza/sector/población; filtro de evidencia y restricciones; existencia de polígono; reservas de superficie; comparación carga/capacidad teórica; necesidades y brechas; responsables; decisión de la autoridad; revisión del aviso; SMS simulado; recuperación. Rombos Sí/No, flechas de avance y retorno para corregir sobreocupación. Versión Mermaid completa en `entregables/video/v2/flujo.md`.
- **Ejemplo reproducible:** área real de `epou-9465` = 447,2149007228903 m². Reservas SIMULADAS: 100 m² no utilizables + 80 m² circulación + 60 m² atención + 40 m² otros usos. Restan 167,2149007228903 m². Con módulos SIMULADOS de 10 m², máximo teórico de 16; proponer 20 excede, reducir a 16 cumple el balance. Se usan los resultados de `acopioCapacity` del frontend, no cifras inventadas como datos medidos. Exportación en `src/ejemplo-acopio.json` de la carpeta del video. El cambio visual de 20 a 16 se vincula al tramo correspondiente de narración.
- **Datos:** polígono DAPM/IDESC ya archivado; atribución y CC BY-SA 4.0 en video/créditos. Fuente primaria: https://datos.cali.gov.co/dataset/epou-espacio-publico-efectivo. Sin nuevos datasets. No se atribuye disponibilidad, aforo certificado, encaje físico o apertura al parque.
- **Filtro:** el sistema propone y la autoridad decide. No sustituye evaluaciones estructurales o conceptos de Bomberos; sin datos personales o reconocimiento facial. El diagrama de habilitación es proceso previsto, no evidencia de una autorización ni nueva integración con entidades. La validación con entidades sigue fuera de esta etapa. El SMS continúa SIMULADO y sin envío real.
- **Verificación v2:** 80,000 segundos, 1.920 fotogramas a 24 fps, 1280 × 720, H.264/AAC; decodificación completa sin errores y audio presente en ocho escenas. Los 25 bloques de subtítulos caben en dos líneas y dentro de la duración. Se revisaron storyboard, estados del ejemplo y un fotograma extraído del MP4 final a los 40,5 segundos. Balance aritmético contrastado con la función del frontend. Resultados en `entregables/video/v2/verificacion.json`.
- **Entregables:** MP4, SRT, guion, storyboard, PNG de personajes, diagrama, reproductor local, código y registro de verificación. El reproductor principal apunta a v2; la primera versión queda disponible.

## 6.19 Presentación profesional en reemplazo del video (25 de septiembre)

El usuario cancela el enfoque de video y solicita una presentación más profesional y llamativa. Se entrega `entregables/presentacion/Cali_Activa_Presentacion.pptx` y su PDF, con **10 diapositivas principales y 2 anexos**, formato panorámico 16:9. Los videos anteriores quedan como historial; no se continúa trabajando en ellos.

- **Diseño:** composición editorial con fondos marfil/azul verdoso, acentos verde lima, titulares grandes, cifras protagonistas y diagramas editables. Cartografía real de Cali y captura real del prototipo. Sin personajes ni fotogramas del video anterior.
- **Narrativa:** problema → propuesta → base territorial → tres decisiones → caso de acopio → necesidades/responsables → prevención/SMS → demostración → valor público/equipo. Anexos de alcance y fuentes.
- **Pitch:** 240 segundos sugeridos, distribuidos en notas del presentador y `Guion_del_pitch.md`, alineados con el formato de cuatro minutos del hackathon. El límite de 80 segundos pertenecía al video cancelado y no se aplica automáticamente a esta nueva presentación.
- **Datos:** 1.970 registros de espacio público, sin sumar puntos deportivos duplicables; caso real epou-9465 con 447,21 m² cartográficos. Reservas y módulos del caso marcados SIMULADOS. Escenario de 300 personas SIMULADO; referencias de 4.500 L/día, 15 baños y 1.050 m² cubiertos, no existencias ni aforo certificado.
- **Fuentes:** DAPM/IDESC, https://datos.cali.gov.co/dataset/epou-espacio-publico-efectivo y https://www.datos.gov.co/dataset/Comunas-de-Santiago-de-Cali/dx2g-2mhm; adaptaciones cartográficas CC BY-SA 4.0. La captura conserva atribución de calles © OpenStreetMap (https://www.openstreetmap.org/copyright). Referencias Esfera ya usadas por el frontend: https://spherestandards.org/wp-content/uploads/Sphere-Handbook-2018-EN.pdf. No se agrega ningún dataset.
- **Filtro:** la autoridad decide activación; no sustituye evaluaciones estructurales ni conceptos de Bomberos. Desconocidos y simulaciones explícitos, sin datos personales o reconocimiento facial. Criterios visibles, alto contraste y texto editable. Responsables propuestos; validación con entidades fuera de esta etapa. No se declara integración SMS real ni impacto medido.
- **Producción y verificación:** PowerPoint nativo con 200 cuadros de texto editables y notas en 12 diapositivas. PDF renderizado con LibreOffice, revisión visual de las 12 páginas y comprobación automática de textos completos, límites del lienzo y relación 16:9. Resultados en `entregables/presentacion/verificacion.json`. Vistas generales y portada exportadas para revisión. Scripts y dependencias de regeneración dentro de `src/`; no se cambian dependencias del frontend.

## 6.20 Territorio Preparado: identidad y presentación ampliada (25 de septiembre)

El usuario elige **Territorio Preparado** como nombre del sistema. Descriptor editorial: **Espacios y ayudas coordinados ante emergencias**. **Cali Activa** se conserva como nombre oficial del RETO-01; las menciones históricas a propuestas anteriores no se reescriben.

- **Frontend:** identidad centralizada en `maqueta3d/src/brand.ts`, cabecera, pie, prevención, mensajes de acopio y metadatos de exportación. Se conserva la información guardada del prototipo.
- **Presentación principal:** `entregables/presentacion-ampliada/Presentacion_Ampliada.pptx` y PDF. Doce diapositivas principales, con 240 segundos de guion sugerido, y cuatro anexos. Incluye actores, matriz multiamenaza, flujo detallado de decisiones, cartografía real, desglose de áreas, exceso/ajuste del acopio, necesidades y responsables propuestos, prevención, SMS simulado, arquitectura, límites, hoja de ruta y fuentes.
- **Diseño:** texto y diagramas nativos editables, capturas reales del frontend e ilustración arquitectónica conceptual mediante image_gen/skill imagegen. Prompt y procedencia en `entregables/presentacion-ampliada/src/prompt-ilustracion.json`. No es fotografía de Cali ni implantación automática de un parque; no acredita obras ni servicios existentes.
- **Datos:** se mantienen el inventario local y el caso `epou-9465`, con área cartográfica real y reservas/módulos SIMULADOS. Los cálculos no son aforo certificado ni prueba de encaje geométrico. SMS con destinatarios y resultados ficticios, cero envíos reales. No se incorpora ningún dataset nuevo. Fuentes primarias: https://datos.cali.gov.co/dataset/epou-espacio-publico-efectivo · https://www.datos.gov.co/dataset/Comunas-de-Santiago-de-Cali/dx2g-2mhm · https://www.openstreetmap.org/copyright · https://spherestandards.org/wp-content/uploads/Sphere-Handbook-2018-EN.pdf. Adaptaciones cartográficas CC BY-SA 4.0.
- **Filtro:** criterios explicables y vacíos visibles; la autoridad decide activación. No sustituye evaluaciones estructurales ni competencias de Bomberos, sin datos personales ni reconocimiento facial. Validación con entidades fuera de esta etapa. Recuperación como proceso previsto, sin declarar integración real o impacto medido.

- **Verificación de esta entrega:** compilación de producción, 22 pruebas unitarias y tres pruebas de navegador de avisos/SMS/prevención móvil. Presentación con 16 páginas y notas, 288 cuadros de texto editables, sin textos perdidos ni elementos fuera del lienzo en la exportación PDF; revisión visual de portada y láminas. Resultados en `entregables/presentacion-ampliada/verificacion.json`.

## 6.21 Idea principal, alcance real y publicación (25 de septiembre)

A petición del usuario se crea `docs/PROPUESTA_REAL.md`: el núcleo es preparar una propuesta revisable de uso temporal de espacios públicos, con restricciones por amenaza, balance de superficie y necesidades pendientes. Se distingue la visión de coordinación completa del comportamiento implementado: preselección por distancia, sin capacidades operativas confirmadas; huella 3D adaptada, sin distribución automática; seguimiento local; SMS simulado; recuperación conceptual. Se conserva la validación con entidades fuera de esta etapa. No se agregan datos, normas o métricas de impacto.

También se crea `docs/SUBIR_A_GITHUB.md`, con la configuración comprobada: `origin` apunta a https://github.com/helynecheverry/hackaton-camaracomercio2026 y `upstream` a https://github.com/leonidas452528/hackaton-camaracomercio2026. Rama local `propuesta-cali-activa`; rama principal remota de upstream `main`, comprobada mediante `git ls-remote --symref upstream HEAD`. La guía explica push al fork y pull request, y la alternativa de push directo de la rama si se dispone de permisos. No se ejecuta push: el usuario solicita instrucciones para hacerlo.

Validación: contraste documental con el código y la bitácora, revisión de remotos/rama y enlaces locales. Cambio exclusivamente documental; se regenera este PDF sin repetir pruebas del frontend.

## 6.22 Propuesta integral en Word para presentar (25 de septiembre)

Se entrega `entregables/propuesta-completa/Territorio_Preparado_Propuesta_Completa.docx`, con PDF complementario. Trece páginas: portada; resumen ejecutivo; solución y actores; cinco fases (conocer/prevenir, dimensionar, coordinar/decidir, informar/acompañar y recuperar/aprender); arquitectura y maqueta; caso reproducible; evidencia y entregables; hoja de ruta; fuentes. Once tablas editables y dos imágenes conceptuales identificadas. Se incluye el caso `epou-9465` y los supuestos de superficie ya documentados, sin nuevas cifras de emergencias ni datasets.

El texto distingue consulta y cálculos implementados, escenarios SIMULADOS, coordinación local, SMS sin envío real y fases operativas pendientes. La huella se adapta al polígono; no hay distribución automática ni aforo certificado. Recuperación, validación institucional, trazabilidad de lotes y operación real no se presentan como realizadas. La validación con entidades continúa fuera de la etapa actual; TRL 3 / IRL 3 son metas, no certificaciones obtenidas. Se conservan decisiones de autoridad, límites técnicos, privacidad y criterios explicables.

Fuentes primarias y licencias reutilizadas del catálogo: https://datos.cali.gov.co/dataset/epou-espacio-publico-efectivo · https://www.datos.gov.co/dataset/Comunas-de-Santiago-de-Cali/dx2g-2mhm · https://www.openstreetmap.org/copyright · https://spherestandards.org/wp-content/uploads/Sphere-Handbook-2018-EN.pdf · fuentes educativas UNGRD de la sección 6.15. Ilustración de portada reutilizada de la presentación ampliada y captura del circuito de agua de la maqueta, ambas conceptuales.

Verificación: DOCX editable y PDF de 13 páginas; texto completo de párrafos y tablas conservado al exportar; 11 tablas y dos imágenes con descripción alternativa; revisión visual de las 13 páginas, sin páginas de desborde. Scripts, dependencias, vistas generales y `verificacion.json` dentro de la carpeta de entrega. No se modifica código del frontend ni se repiten sus pruebas. Se regenera el PDF de esta bitácora.

## 6.23 Referencias visuales del kit (26 de septiembre)

Por solicitud del usuario, se incorporan las tres imágenes de `Imagen Refe/` al documento vigente `entregables/Territorio_Preparado_Propuesta.docx` y a la pestaña **El kit** del frontend: camas y divisiones de cartón (descanso y privacidad en interiores secos), cisterna flexible de lona (almacenamiento de agua) y panel solar portátil plegable (apoyo a iluminación y comunicaciones). El Word incluye una página visual dentro del apartado 5 y actualiza las filas de refugio, agua y energía de su tabla de componentes.

Las imágenes son referencias aportadas por el equipo para expresar una idea; no acreditan instalaciones en Cali, prestaciones o disponibilidad. Se conserva el crédito visible @MECATRÓNICA de la referencia de cartón. Capacidades, materiales, batería y autonomía quedan por definir. No se añaden datasets ni cifras técnicas. Se mantiene el filtro del proyecto: activación por la autoridad, sin sustituir evaluaciones estructurales ni conceptos de Bomberos, sin identificación personal en el frontend y con criterios y límites visibles.

Validación: compilación de producción correcta; revisión en navegador a 1440 y 390 píxeles, tres imágenes cargadas con texto alternativo y sin desborde horizontal. Word con cinco imágenes totales; página de referencias comprobada mediante exportación a PDF. Se respetan las eliminaciones y los demás cambios previos del usuario.

## 6.24 Fork de Herlin, entregables del evento y pitch 4.2 (26 de septiembre)

- **Fork de Herlin integrado** (rama `propuesta-cali-activa`): pestaña **05 El kit** con referencias de cartón, cisterna de lona y panel solar (sección 6.23), y Word vigente `entregables/Territorio_Preparado_Propuesta.docx`, que reemplaza la carpeta `propuesta-completa/`. `AGENTS.md`, `CLAUDE.md`, `README.md` y `PROMPT_CODEX_3D.md` se conservan en la raíz para que GitHub muestre el README y las IA lean sus instrucciones.
- **Equipo:** el nombre del integrante anterior se retiró de los Markdown, del Word vigente y de los PDF de la guía del 25 de septiembre y de la ruta de aprendizaje. El equipo es William Ortiz, Herlin Echeverry, Pablo Arango y Bryan Martínez Villamarín.
- **6 entregables del evento** (TDR, sección 3.9, "Entregables de los equipos"), en `entregables/entregables-evento/`, Word y PDF: 1) alineación con el reto (artefactos 1 y 2); 2) arquitectura de la solución (artefacto 3); 3) propuesta de valor (artefacto 4); 4) viabilidad GovTech (artefacto 4); 5) elevator pitch de 1 minuto (4.2), 140 palabras; 6) bitácora de validación (artefacto 5). Cada uno indica el criterio de evaluación de los TDR que evidencia, las líneas rojas y sus fuentes. Se generan con `src/crear_entregables.py`.
- **Formato según referencias de otros equipos** (revisadas solo como modelo, no se suben al repo): el pitch 4.2 pasa al formato «foco en solución» de 1 página (solución, cómo opera en tres pasos, impacto y cierre; 138 palabras). Se agrega `Entregable final - Territorio Preparado.docx` con la tabla del artefacto 5 (equipo y reto, prototipo, rondas, bitácora de evidencia, aprendizajes). Nombre del equipo: **Territorio Preparado**.
- **Rondas de prueba SIMULADAS (2):** la guía del evento permite «Simular un usuario con Claude» (artefacto 4, paso 3). Personajes construidos con testimonios públicos, sin nombres: una lideresa comunitaria del nororiente (https://www.eltiempo.com/amp/colombia/cali/resistir-con-un-plato-de-sancocho-la-solidaridad-comunitaria-que-sostiene-a-los-damnificados-del-barrio-chiminangos-ii-nororiente-de-cali-3577720 · https://www.elpais.com.co/cali/personas-en-albergues-de-cali-tras-el-terremoto-piden-no-ser-olvidados-llegada-de-ayudas-ha-disminuido-2305.html) y un funcionario de Gestión del Riesgo (https://www.cali.gov.co/boletines/publicaciones/193628/alcaldia-de-cali-refuerza-la-atencion-integral-a-familias-afectadas-por-el-sismo-mediante-la-disposicion-de-albergues-temporales/ · https://occidente.co/cali/traslado-de-los-damnificados-en-cali-hoteles-alojamiento-sismo/). Ajustes definidos y pendientes de implementar: lenguaje claro en la ficha, resumen exportable legible, aforos medidos para ordenar candidatos, alojamientos no públicos como categoría y registro agregado de albergues comunitarios. IRL 3 queda en curso.
- **Sin inventar:** la validación con actores reales queda PENDIENTE; los costos se presentan como rubros por estimar; TRL 3 e IRL 3 son metas, no certificaciones. No se agregan cifras ni datasets nuevos.
- **Verificación:** 6 DOCX y 6 PDF (3 a 8 páginas), revisión visual de páginas de muestra, `npm test` y compilación de la app correctos.

## 6.25 Informe de preparación legible (fork de Herlin) (26 de septiembre)

La descarga principal de **Preparar intervención** pasa de JSON a un documento HTML autónomo en español, que se abre sin conexión en el navegador e incluye **Imprimir / guardar como PDF**. Presenta espacio y ubicación, amenaza, población SIMULADA, necesidades de agua/baños/superficie, existencia y brecha, responsables propuestos y seguimiento local. Añade estimación conceptual de kits (redondeo superior de personas/20, según la configuración existente), componentes de descanso/privacidad, cisterna de lona, panel solar, saneamiento, salud/protección y logística, con dimensionamientos pendientes explícitos. El número de kits no demuestra encaje ni equivale a los módulos del acopio.

Incluye todas las entradas y resultados disponibles del balance de acopio, su inclusión o exclusión del borrador, candidatos, criterio de comparación, tareas específicas de incendio cuando corresponden, próximos pasos, fuentes y límites. Los datos desconocidos se muestran como **Por confirmar**; no se inventan existencias, potencias, capacidades de cisternas ni cantidades de equipos. El JSON se conserva como opción técnica secundaria. Se mantienen decisiones de autoridad, revisiones técnicas y competencias de Bomberos; sin información personal ni comunicaciones reales.

Validación: compilación de producción; siete pruebas de navegador de planificación, acopio, incendios e informe; prueba de escape de texto externo y bloqueo de enlaces ejecutables. Verificación de exportación para 301 personas (16 baños, 4.515 L/día, 1.053,5 m², 16 kits conceptuales), seguimiento, datos incompletos, sobreocupación, incendio y opción de impresión. Revisión visual de PDF A4 y prueba móvil de 390 píxeles. Sin dependencias nuevas ni datasets adicionales.

Con esto queda resuelto el ajuste «resumen exportable legible» que salió de las rondas de prueba SIMULADAS (sección 6.24).

## 6.26 Base de datos: del modelo al SQL (3 y 4 de octubre)

El 3 de octubre quedaron en `db/docs/` el modelo de datos para **Supabase** (PostgreSQL + PostGIS), el diccionario, los 8 roles con su matriz de permisos y 9 decisiones de arquitectura. En `docs/cumplimiento/` quedaron las normas verificadas, los entes decisores, la red comunitaria y la matriz normativa. El 4 de octubre se escribió el **SQL en borrador** (`db/supabase/migrations/`, 11 migraciones con el formato de la CLI de Supabase), que queda en revisión del responsable de la BD.

Lo que la base hace cumplir por sí misma, sin depender del frontend:
- **Recomienda ≠ decide:** solo `gestion_riesgo` con verificación en dos pasos registra una activación, y debe citar el acto administrativo. Si no sigue la recomendación, exige justificación.
- **Exclusión por diseño:** no hay tabla de personas. Los reportes comunitarios son conteos (los grupos de edad deben sumar el total), y los textos libres rechazan correos, teléfonos y números largos.
- **Desconocido ≠ cero:** el faltante de una brecha es `NULL` si no hay medición **verificada**. Verificar exige evidencia y otra persona (cuatro ojos). De la evaluación estructural solo se guarda sí/no y la fecha, nunca un concepto.
- **Alcance:** cada entidad ve y actualiza solo sus brechas y tareas; cada junta, solo su zona. `consulta` ve agregados, con supresión de conteos menores a 5 (umbral propuesto).
- **Continuidad:** los permisos van al cargo. El traspaso de cargo conserva el historial, y una suspensión surte efecto de inmediato.
- **Trazabilidad:** auditoría de solo inserción encadenada por SHA-256. La prueba incluye una manipulación deliberada, que la verificación detecta.
- **Una sola puerta:** el frontend solo ve el esquema `api` (contrato en `db/docs/CONTRATO_API.md`), y ningún rol escribe directo en las tablas.

Validación: `cd db && npm install && npm test` aplica las migraciones en PGlite (PostgreSQL 18 + PostGIS 3.6 en WASM; aquí no hay Docker ni CLI de Supabase) y corre **69 pruebas, todas en verde**. Todo lo institucional (entidades, matriz de responsabilidades, protocolo de 11 pasos, funciones del espacio por amenaza) va como **propuesta**, sin plazos ni cifras inventadas. Los ajustes al pasar del diccionario al SQL están en `db/docs/DICCIONARIO.md` §0.

## 6.27 Base de datos: carga de los datos reales (4 de octubre)

`db/scripts/cargar_datos_reales.mjs` carga en la base los datos abiertos que ya usa la app, en una sola transacción y de forma repetible:
- **Primero verifica la fuente:** el `sha256` y el conteo de los 9 archivos crudos de la IDESC coinciden con `maqueta3d/public/data/manifest.json`. Si uno no coincide, no toca la base.
- **Carga:** 22 comunas, 342 barrios, 2.991 espacios (1.970 EPOU con huella + 1.021 escenarios deportivos con punto), 660 zonas de amenaza y las 182 JAC (organizaciones, no personas), con licencia, atribución y fecha de corte en `ref.fuentes`.
- **Mismo resultado que la app:** con PostGIS (`ST_Intersects`) salen **884 espacios con cruce de inundación y 1.369 con cruce sísmico, idénticos uno a uno** a los que precalculó la app con Turf. Hallazgo: la capa sísmica de la app usa 5 de los 16 polígonos de microzonificación (los que tienen susceptibilidad a licuación o corrimiento); el filtro queda anotado en la base.
- **Sin inventar:** 52 espacios sin comuna, 23 JAC cuyo código de barrio no aparece en la capa de barrios, y 3 huellas y 18 zonas con geometría no válida según GEOS se cargan tal como vienen y quedan reportadas.

Validación (`cd db && npm test`): 69 pruebas del SQL y 17 de carga, entre ellas la idempotencia, la atomicidad ante una falla a mitad de camino y la lectura pública como `anon`. Falta correrla en un proyecto real de Supabase; la URL de conexión se pasa solo por la terminal.

## 6.28 Montaje en Supabase y acceso del equipo (4 de octubre)

- **Repo privado:** el repo pasó a privado y la demo de GitHub Pages sigue publicada. Se invitó con permiso de escritura a Herlin (`helynecheverry`), Pablo (`PabloEArangoM`) y Bryan (`bryanmavi`). Las copias que ellos hicieron con fork **siguen públicas** hasta que cada uno las cierre.
- **Pull request:** la base de datos va en el PR #2 (`db/esquema-inicial` → `main`).
- **Supabase `dev`:** proyecto `rqxltixtsiqsakxapdue`, creado con la cuenta de GitHub. La CLI de Supabase quedó como dependencia de `db/`, con `db/supabase/config.toml`. Las **12 migraciones se aplicaron** con `supabase db push`.
- **API verificada en Supabase real:** solo se expone el esquema `api`. Como público se leen los catálogos; las decisiones, la auditoría y las escrituras quedan bloqueadas, y `ops` y `public` no están expuestos.
- **Datos reales en Supabase:** 2.991 espacios, 660 zonas, 22 comunas, 342 barrios y 182 JAC, con los mismos cruces de amenaza que la app (0 diferencias). Región del proyecto: EE. UU. este (`us-east-1`).
- **Documentos:** `db/docs/INFORME_MONTAJE_SUPABASE.pdf` (qué se hizo, con el detalle) y `db/docs/ACCESO_EQUIPO.pdf` (paso a paso para cada integrante).

## 7. Pendientes
- [ ] **Base de datos:** el responsable de la BD revisa el SQL del Hito 1 y responde las 10 decisiones de `db/docs/MODELO_DATOS.md` §9 (el borrador asume el valor propuesto en cada una).
- [x] **Base de datos (H2):** script de carga de los datos reales con verificación de `sha256` (sección 6.27).
- [ ] Revisar las 3 huellas y las 18 zonas de amenaza con geometría no válida (¿reportarlas a la IDESC?), y las 23 JAC cuyo código de barrio no está en la capa de barrios.
- [x] **Base de datos (H3):** migraciones aplicadas en Supabase `dev` y `api` como único esquema expuesto (sección 6.28).
- [x] Supabase `dev`: datos reales cargados y verificados (2.991 espacios; cruces idénticos a la app; TLS verificado con la CA de Supabase).
- [ ] Supabase `dev`: activar el MFA TOTP y el hook del token, y **cambiar la contraseña de la base** (quedó expuesta en el chat).
- [ ] Cada integrante acepta la invitación, cierra su copia pública y sigue `db/docs/ACCESO_EQUIPO.pdf`. William los invita a la organización de Supabase con el rol Developer.
- [x] Sustituir la descarga técnica principal por un informe de preparación legible, con todas las necesidades y opción de guardar como PDF.
- [x] Integrar el fork de Herlin del 26 de septiembre (El kit y Word vigente) y publicar en GitHub Pages.
- [x] Los 6 entregables del evento y el texto del pitch 4.2 (`entregables/entregables-evento/`).
- [ ] Reemplazar las 2 rondas SIMULADAS por rondas con actores reales (Secretaría y JAC) y registrarlas en el entregable 6 y el final (solo roles, sin nombres).
- [ ] Implementar los ajustes de las rondas: lenguaje claro en la ficha, resumen exportable en tabla/PDF, aforo medido para ordenar candidatos, alojamientos no públicos.
- [x] Incorporar las referencias de cartón, cisterna de lona y panel solar como partes del kit en el Word vigente y en la página.
- [x] Integrar los forks de Herlin (maqueta, app, video, presentación y Word) y de Pablo (módulo preventivo) en `main`.
- [x] Cambio de integrante: **Bryan Martínez Villamarín** se incorpora al equipo (actualizado en los Markdown, el PPTX, el DOCX y sus PDF).
- [x] Auditoría del 25 de septiembre y guion del pitch de **1 minuto** (tiempo máximo): `entregables/pitch-1min/Guion_1_minuto.md` y `entregables/guia-25-sep/`.
- [ ] Armar las 4 diapositivas del pitch de 1 minuto y ensayarlo con cronómetro.
- [ ] Unificar el nombre: el video v2 y la captura `mapa_cali.png` todavía dicen "Cali Activa".
- [x] Publicar la demo en GitHub Pages: https://leonidas452528.github.io/hackaton-camaracomercio2026/ (falta un respaldo sin conexión: video y capturas).
- [ ] Documentar al menos un contacto de validación real (JAC o Secretaría de Gestión del Riesgo) para el IRL 3.
- [ ] Integrar en la app el peritaje de entorno del módulo preventivo de Pablo (puntaje 60/40).
- [ ] Quitar las columnas de correo y teléfono de `prototipo/datos/raw/sismo/men_sedes.csv` (datos mínimos).
- [x] Crear el documento Word integral con fases, soluciones, alcance actual y material para presentar; PDF complementario verificado.
- [x] Explicar la idea principal y el alcance realmente implementado en un Markdown independiente; guiar la publicación en GitHub.
- [x] Nombre elegido por el usuario: **Territorio Preparado**. Aplicado al frontend y a la presentación; Cali Activa permanece como reto oficial.
- [x] Enriquecer la presentación con matriz multiamenaza, flujo de decisiones, organización conceptual del espacio, capturas del cálculo de acopio, prevención, SMS simulado y anexos de alcance/fuentes.
- [x] Nueva entrega solicitada: presentación profesional PowerPoint/PDF, 10 diapositivas de pitch y 2 anexos, con guion y notas. Sustituye el enfoque de video por decisión del usuario.
- [x] Segunda versión del video: personajes de referencia y flujo detallado con decisiones y corrección de sobreocupación.
- [x] Video animado de 80 segundos con voces, música, subtítulos y flujo general del proyecto, solicitado por el usuario. Esta pieza no sustituye automáticamente el video final de 4 minutos previsto por el hackathon.
- [x] Preparar avisos generales de acopio con ubicación real, horario/información propuesta, copia y descarga, sin identificar damnificados.
- [x] Canal SMS SIMULADO y sección de análisis preventivo/cultura ciudadana, por solicitud del usuario.
- [ ] **Fuera del alcance de esta demo:** envío SMS real, proveedor, cobertura, autorización de avisos y seguimiento de entrega.
- [x] Corregir Revisar: selección, desplazamiento y foco a la ficha, incluidos clic repetido y teclado.
- [x] Incorporar incendios forestales/en edificación con tareas por subtipo, exportación y bloqueo de preselección sin evidencia.
- [ ] Incorporar cartografía de incendios con procedencia/licencia verificadas e información vigente del incidente antes de habilitar preselección para esos escenarios.
- [x] Instalar skills Three.js y revisar cubiertas, apoyos, vista de corte y funcionamiento conceptual del agua.
- [ ] Dimensionamiento profesional de estructuras, anclajes y sistema de agua; capacidad, primeras aguas, suministro y descarga por verificar.
- [x] Frontend: preparar espacio seleccionado, adaptar huella pública, preseleccionar candidatos con criterios, calcular necesidades y seguir brechas desconocidas; exportar borrador.
- [x] Balance de superficie del acopio sobre huella pública, con reservas explícitas SIMULADAS y bloqueo de inclusión por sobreocupación.
- [ ] Comprobar encaje geométrico y distribuir kits por superficie útil y accesos medidos; completar aforos/servicios para calcular faltantes reales y aptitud operacional.
- [x] Maqueta 3D, paso 1: medidas y cálculos centralizados con procedencia.
- [x] Maqueta 3D, paso 2: escena general con controles y mapa de inventarios reales por comuna/barrio, fuentes y cruces verificados.
- [ ] **Fuera de la etapa actual por decisión del usuario:** validación con entidades de disponibilidad, administración/acceso, evaluaciones y servicios; no se marca como realizada.
- [x] Mediciones cartográficas iniciales: huella candidata a voleibol, plano, distancias reproducibles y fuentes.
- [ ] Resolver identidad de hockey y planta de los escenarios antes de recalibrar la maqueta; dimensiones interiores/alturas y área útil siguen sin verificar.
- [x] Mapa: calles activadas por defecto y vínculos oficiales a Google Maps, satélite y Street View por coordenadas.
- [x] Maqueta 3D, paso 3: refugio y equipamiento ilustrativo, vista de registro y control de cubiertas.
- [x] Maqueta 3D, paso 4: centro de acopio, sectores seleccionables, ramal de descarte, ruta conceptual y pantalla de trazabilidad preparada.
- [ ] Obtener lote e inventario reales verificados para poblar la trazabilidad (cantidad, origen, destino, movimientos y hash); no fabricar datos.
- [x] Maqueta 3D, paso 5: estados de uso cotidiano, emergencia y recuperación con transiciones y movimiento reducido.
- [x] Maqueta 3D, paso 6: siete capturas finales, exportación GLB y revisión final de las líneas rojas.
- [ ] Artefacto 2: redactar los 6 campos y el "¿Cómo podríamos…?" con los hallazgos propios (albergues autogestionados y la amenaza cruzada con el Jarillón).
- [ ] Artefacto 3: generar 6 a 8 ideas y filtrarlas.
- [ ] Artefacto 4: propuesta de valor, validación con un usuario real (JAC de Chiminangos o Calimio Norte, o la Secretaría de Gestión del Riesgo) y plan del prototipo.
- [x] Datos reales de Cali: inventario de 1.970 espacios × amenazas y afectación del sismo por comuna (`docs/DATASETS.md`).
- [ ] Derecho de petición a la Secretaría de Gestión del Riesgo: RUD y evaluaciones de edificaciones **agregadas por barrio** (Leyes 1712 y 1755).
- [ ] Geocodificar los 4 alojamientos oficiales y los 3 autogestionados, y agregarlos al inventario.
- [ ] Sábado: subir `inventario_espacios_cali.csv` a Sheets, construir el prototipo No-Code y grabar el video.
- [ ] Agregar a la ficha de aptitud el campo "papel según la amenaza" (albergue, amortiguador o punto de agua) y los atributos de agua almacenada, baños sin red y energía propia (ver los referentes internacionales).
- [x] Ruta de aprendizaje y Gema de Gemini para entrenar al equipo: `gema/INSTRUCCIONES_GEMA.md` y `gema/RUTA_APRENDIZAJE.pdf` (incluye el análisis de la competencia del RETO-01).
- [x] **Decidir el nombre:** Territorio Preparado, elegido por el usuario; Cali Activa es el nombre del reto.
- [ ] Pedirle al integrante de los refugios de PVC su material (ficha, bocetos, sensores) y sumarlo a `docs/`.
- [ ] Unificar el formulario de Cali Lista con las columnas de `inventario_espacios_cali.csv`.
- [ ] Marco legal: verificar las normas marcadas con (verificar) en la sección 6.1.
- [ ] Actualizar la Gema (`gema/RUTA_APRENDIZAJE`) con la propuesta integrada.
- [ ] Confirmar las cifras oficiales de muertos en Cali (105 vs. 154) y las normas marcadas con (verificar).

## 8. Fuentes consultadas
- **Catálogo con la URL de descarga de cada dataset: `prototipo/datos/FUENTES.md` y `prototipo/datos/fuentes.csv`**
- Datos reales (ver `docs/DATASETS.md`): https://datos.cali.gov.co · https://idesc.cali.gov.co (WFS ws-idesc.cali.gov.co) · https://rapidmapping.emergency.copernicus.eu/EMSR916/ · https://sertit.unistra.fr/cartographie-rapide/cartoaction/845/ · https://datosdelterremoto.org/municipio/cali/ · https://github.com/18orkidea/monitor-terremoto-colombia · https://rud.gestiondelriesgo.gov.co/ · https://portal-hidroclimatologico.cvc.gov.co/ · https://www.datos.gov.co/resource/bdmn-sqnh
- https://www.elpais.com.co/cali/alcaldia-de-cali-entrega-balance-de-gestion-tras-el-sismo-mas-de-3400-edificaciones-evaluadas-y-45000-familias-damnificadas-2338.html
- https://www.elpais.com.co/cali/cali-antes-y-despues-del-terremoto-asi-cambiaron-los-sectores-mas-afectados-desgarradoras-imagenes-1636.html
- Portafolio de Retos HSC, Alcaldía de Cali v2.0 (PDF, Sesión 1)
- Guía de uso de los artefactos, Sesiones 2 y 3 (DOCX) y presentación de la Sesión 2 (PPTX)
- https://es.wikipedia.org/wiki/Terremoto_de_Colombia_de_2026
- https://www.infobae.com/colombia/2026/09/25/ocha-alerta-vacios-de-informacion-y-atencion-tras-terremoto-que-deja-486917-afectados-en-colombia/
- https://datosdelterremoto.org/municipio/cali/
- https://www.defensoria.gov.co/web/guest/-/defensoria-pide-atencion-urgente-para-336-familias-en-albergues-de-cali
- https://www.vanguardia.com/colombia/2026/09/13/el-terremoto-no-termina-la-vida-en-los-albergues-de-cali/
- https://www.elpais.com.co/cali/terremoto-en-cali-estos-son-los-lugares-habilitados-para-recibir-a-los-damnificados-1038.html
- https://www.elnuevosiglo.com.co/nacion/cali-abren-albergue-en-cancha-de-hockey-y-evaluan-subsidios-para-damnificados
- https://www.semana.com/nacion/cali/articulo/tras-el-terremoto-cali-informa-cuales-escenarios-deportivos-vuelven-a-estar-al-servicio-de-los-atletas-desde-este-31-de-agosto/202628/
- https://occidente.co/regionales/valle-del-cauca/36-escenarios-deportivos-estan-afectados/
- https://www.icbf.gov.co/noticias/el-icbf-mantiene-atencion-ininterrumpida-en-territorios-afectados-por-el-terremoto
- https://cwmas.com.co/cali/2026/02/24/rio-cauca-en-alerta-naranja-aumenta-el-caudal-en-el-oriente-de-cali/
- https://www.cali.gov.co/boletines/publicaciones/191712/el-jarillon-del-rio-cauca-no-es-una-via-se-limitara-el-acceso-y-transito-de-vehiculos-sobre-su-estructura/
- https://www.fondoadaptacion.gov.co/index.php/component/sppagebuilder/?view=page&id=168
- https://www.lafm.com.co/actualidad/medidas-aumento-incendios-forestales-cali-fenomeno-nino-405401
- https://ciudadregion.com/regiones/valle-del-cauca/cali/pico-fenomeno-nino-noviembre-valle-cauca-niveles-embalses
- https://ciudadregion.com/regiones/valle-del-cauca/cali/sequia-valle-del-cauca-niveles-represas-incendios-forestales
- https://www.cali.gov.co/gobierno/publicaciones/193607/terremoto-de-cali-repositorio-oficial-de-informacion/
- https://www.unocha.org/publications/report/colombia/colombia-prediccion-impactos-por-desarrollo-de-el-fenomeno-del-nino-2026-2027-19-de-junio-de-2026
- https://www.cdp.net/en/insights/yokohama
- https://adaptation-platform.nies.go.jp/en/db/measures/report_043.html
- https://www.tokyo-park.or.jp/special/bousai/english/sisetsu.html
- https://www.smithsonianmag.com/smart-news/tokyo-has-built-disaster-preparedness-fabric-city-180952366/
- https://www.kubota.com/corporatehistory/ourchallenges/japan-water-03/2/
- https://reliefweb.int/report/nepal/updated-report-83-open-spaces-identified-humanitarian-purposes-kathmandu-valley
- https://nepalitimes.com/kathmandu-loses-its-open-spaces
- https://www.turkeyrecap.com/p/out-of-space-lack-of-safe-zones-deepens
- https://www.elimparcial.com/mexico/2026/09/19/simulacro-nacional-2026-303-altavoces-de-cdmx-no-sonaron-segun-c5-asi-puedes-reportar-una-falla/
- https://www.urbanisten.nl/work/benthemplein
- https://www.dutchwatersector.com/news/new-innovative-water-square-combines-leisure-and-storm-water-storage-in-rotterdam-the
- https://stateofgreen.com/en/solutions/125669/
- https://toposmagazine.com/enghaveparken-copenhagen-denmark/
- https://www.preventionweb.net/news/chinas-sponge-cities-aim-re-use-70-rainwater-heres-how
- https://de.wikipedia.org/wiki/Trinkwassernotbrunnen
- https://www.bbk.bund.de/DE/Themen/Kritische-Infrastrukturen/Sektoren-Branchen/Wasser/Wassersicherstellung/wassersicherstellung_node.html
- https://iol.co.za/capeargus/news/watercrisis-city-of-cape-town-unveils-scant-dayzero-plans-12989659
- https://siwi.org/news/how-cape-town-saved-itself-from-day-zero
- https://phys.org/news/2024-02-barcelona-restrictions-drought-emergency-declared.html
- https://ajuntament.barcelona.cat/urbanisme-accio-climatica-mobilitat-pla-barris-serveis-urbans/en/aigua/la-sequera
- docs/cali_lista.pdf (propuesta de Pablo, desde su fork)
- https://normograma.crcom.gov.co/crc/compilacion/docs/resolucion_ane_0105_2020.htm
- https://www.researchgate.net/publication/45637651_Hydrogen_Chloride_in_Fires
