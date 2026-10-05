# Referentes internacionales: ideas, normas y leyes que podemos tomar

> **Para qué sirve:** reunir lo que hace el mundo ante sismos, inundaciones e incendios, y decidir **qué adoptamos en Cali y qué no**, con su respaldo legal.
> **Marcas** (detalle en [`../cumplimiento/FUENTES.md`](../cumplimiento/FUENTES.md), sección G): 📜 texto oficial leído; 🔎 solo resumen de búsqueda; 🧠 sin verificar. Consultado el 3 de octubre de 2026.
> **Honestidad sobre la cobertura:** sismo, inundación y animales están razonablemente cubiertos; **incendio es la parte más débil** (solo Cataluña y las normas NFPA, que no pude leer). Falta una segunda ronda (por ejemplo Chile, Portugal, Grecia y California).

## 1. Las 10 ideas que más valen la pena

| # | Idea | Quién la hace | Respaldo | Qué adoptamos en Cali |
|---|---|---|---|---|
| 1 | **Separar el punto de reunión inmediato del alojamiento temporal** (y del acopio) | Japón por ley en 2013; Turquía; Italia | Reforma de 2013 de la Ley Básica de Gestión de Desastres 📜 (el motivo, 🔎) | `ref.funciones_espacio` con fase; `punto_reunion_inmediata` como función |
| 2 | **Mascotas en los albergues**, con animales de servicio siempre admitidos | EE. UU. (PETS Act 2006), Japón (guía 2013/2018), Italia, Colombia (Ley 2474 de 2025) | PETS Act 📜; Ley 2474 📜; D.Lgs. 1/2018 art. 1 📜; guía japonesa 🔎 | Servicio `animals`, atributos del espacio y conteo agregado |
| 3 | **Proteger las áreas designadas**: en Estambul se pierden por construcción | Turquía (AFAD) | Prensa y estudios académicos 🔎 | `geo.espacios.estado_proteccion_uso` y alerta de cambio de uso |
| 4 | **Medir el déficit de espacio por habitante** | Turquía (1,29 m² por persona en Estambul, 3.021 áreas) | 🔎 | Indicador `ep_m2_por_hab` por comuna (ya existe en el repo) |
| 5 | **Mapas públicos de peligrosidad y de riesgo, más planes de gestión** | Unión Europea | Directiva 2007/60/CE: mapas a más tardar el 22-dic-2013 y planes (art. 7) 📜 | Mapa de aptitud público y versionado; capas abiertas con `sha256` |
| 6 | **Norma técnica para abrir, operar y cerrar refugios** | Ciudad de México | NT-SGIRPC-RTA-010-2025 🔎 (no leída) | Tomarla de guía para el protocolo y el retorno; leerla antes de citarla |
| 7 | **Un documento municipal único de protección civil** | Cataluña (DUPROCIM) | 🔎 | Nuestra ficha del espacio y el protocolo cumplen ese papel; formato comparable para Barcelona |
| 8 | **Planes por amenaza** (sísmico, inundación, incendio forestal) | Cataluña: SISMICAT, INUNCAT, INFOCAT, PROCICAT | 🔎 | Una plantilla de protocolo por amenaza (`ref.protocolo_plantillas`) |
| 9 | **Selección de albergues con análisis multicriterio en un SIG**, con calidad, capacidad y accesibilidad | Literatura (COSI-SAFE y otros) | 🔎 | Índice de aptitud (ver `INDICE_APTITUD_Y_MAPA_DE_CALOR.md`) |
| 10 | **Gemelo digital con escenarios "qué pasa si"** | Japón (PLATEAU), Singapur, Helsinki, Esri | 🔎 | Modo A/B en la maqueta 3D (fase 2, ver §5) |

## 2. Por amenaza

### Sismo
| Referente | Qué hace | Respaldo | Adoptamos | No adoptamos |
|---|---|---|---|---|
| Turquía | Áreas de reunión designadas tras Marmara (1999), con áreas de alojamiento temporal aparte | 🔎 | Funciones por fase; protección de áreas; déficit por habitante | Su lista de áreas como si fuera la nuestra |
| Japón | Lugares de evacuación de emergencia y albergues designados por separado; los informa a la población | Reforma 2013 📜 | Designación explícita y pública por función | — |
| Cataluña | SISMICAT: estructura de respuesta y procedimientos | 🔎 | Plantilla de protocolo sísmico | — |
| Colombia | NSR-10 y Ley 400 de 1997 (evaluación estructural) | 🧠 | Solo registrar si hay evaluación vigente y su fecha | **Emitir conceptos estructurales** |

### Inundación
| Referente | Qué hace | Respaldo | Adoptamos | No adoptamos |
|---|---|---|---|---|
| Unión Europea | Mapas de peligrosidad y de riesgo y planes de gestión por demarcación | Directiva 2007/60/CE 📜 | Mapas y plan versionados; escenarios por probabilidad | — |
| España | Transposición por el Real Decreto 903/2010 | 🔎 | Referencia de método | — |
| Cataluña | INUNCAT: qué municipios deben hacer planes de actuación según las zonas inundables | 🔎 | Criterio de obligatoriedad por zona (idea para el POT de Cali) | — |
| Países Bajos (Rotterdam) | Plazas de agua que sirven al ocio y al drenaje | Bitácora del equipo 📁 | Idea para adecuaciones permanentes | Obras en este proyecto |

### Incendio (cobertura débil)
| Referente | Qué hace | Respaldo | Adoptamos | No adoptamos |
|---|---|---|---|---|
| Cataluña | INFOCAT: plan de emergencias por incendios forestales | 🔎 | Plantilla de protocolo forestal | — |
| NFPA 101 | Seguridad de vida en edificios, incluidos los de reunión | 🔎 (de pago) | Referencia para que la entidad competente evalúe | **Emitir conceptos contra incendios** (competencia de Bomberos, Ley 1575 de 2012 🧠) |
| NFPA 1140 y 1144 | Incendios forestales y zona urbano-forestal; espacio defendible | 🔎 (de pago) | Criterios de entorno para el índice de aptitud por incendio forestal, cuando haya cartografía verificada | — |
| NFPA 1600 | Programas de gestión de emergencias y continuidad | 🔎 (de pago) | Referencia, junto a ISO 22301 y 22320 | — |

## 3. Transversales

| Tema | Referente | Respaldo | Adoptamos | No adoptamos |
|---|---|---|---|---|
| **Animales** | PETS Act; guía de Japón; Italia; **Ley 2474 de 2025** (arts. 3, 11, 12, 13, 14) | 📜 / 🔎 | Ver `MODELO_DATOS.md` §10. Además: Ley 2474 art. 14 pide que los sistemas de información territoriales incluyan datos de animales | Registro de dueños o de animales individuales |
| **Personas que necesitan ayuda para evacuar** | Japón: listas nominales de quienes la requieren, y base de datos de damnificados | Reforma 2013 📜 | Solo el **concepto** de planificar con ellas, mediante conteos agregados y atributos del espacio (accesibilidad) | **Las listas nominales**: chocan con la exclusión por diseño (ADR-0008) y con la Ley 1581, art. 7. Si la entidad las necesita, las lleva ella, fuera de esta plataforma |
| **Participación comunitaria** | Ley 1523 art. 2 y 28 📜; Ley 2166 de 2021 📜; Ley 2474 art. 15 (hogares de paso) 📜 | 📜 | Red comunitaria (`RED_COMUNITARIA.md`) | Registrar personas que ofrecen hogares de paso |
| **Marco global** | Marco de Sendai 2015-2030: comprender el riesgo, fortalecer la gobernanza, invertir en reducción, mejorar la preparación y la recuperación | 🔎 | Alinear el relato del pitch: datos abiertos (prioridad 1), roles por cargo (2), adecuaciones permanentes (3), protocolo y retorno (4) | — |
| **Estándares humanitarios** | Sphere 2018 (ya en uso: baños, agua, área cubierta); LEGS para ganado | 🔎 | Seguir con Esfera; LEGS solo si hay ganado | Inventar cifras para mascotas |
| **Latinoamérica** | Chile Ley 21.364 (SINAPRED y SENAPRED, instrumentos por escala); Perú Ley 29664 (SINAGERD); México LGPC (refugios temporales que no son centros de acopio) | 🔎 | Idea de instrumentos por escala (ciudad, comuna, barrio); separar refugio y acopio (decisión pendiente) | — |

## 4. Lo que **no** se adopta, y por qué

| Idea | Por qué no |
|---|---|
| Listas nominales de personas vulnerables y bases de damnificados (Japón) | Exclusión por diseño; Ley 1581 arts. 5 y 7 📜; el registro nominal es del RUD de la UNGRD |
| Que la plataforma designe o declare (alcalde y consejo lo hacen en Japón, Italia y Colombia) | Ley 1523 arts. 14 y 57 📜 |
| Cifras para mascotas tipo Esfera | No verifiqué ninguna; no se inventan |
| Conceptos estructurales o contra incendios | NSR-10 y Ley 1575 🧠 |

## 5. La ciudad en maqueta 3D del Smart City Expo

No pude identificar con certeza qué proyecto viste. Candidatos (🔎), con lo que ofrece cada uno:

| Candidato | Qué es | Parecido con lo que describes | Para nosotros |
|---|---|---|---|
| **Project PLATEAU** (MLIT, Japón) | Modelos 3D semánticos (CityGML) de unas 250 ciudades como datos abiertos, con Re:Earth y simulación de inundaciones; el ministerio tuvo presencia en el Smart City Expo 2025 | Alto: gemelo digital abierto con simulaciones | Idea de estructura semántica y de inundación 3D; no hay datos de Cali |
| **ArcGIS Urban** (Esri) | Dibuja edificios, prueba zonificación y compara escenarios | **Alto para "hacer y deshacer edificios"** | Modo de escenarios A y B |
| **vCity** | Plataforma de gemelos urbanos centrada en el ciudadano, que simula escenarios | Alto | Participación ciudadana en el escenario |
| **Virtual Singapore** | Gemelo digital del país, nacido tras las inundaciones de 2011 | Medio | Caso de uso de inundación |
| **Helsinki 3D+** | Dos modelos 3D de la ciudad (semántico y de malla) | Medio | Modelo abierto de ciudad |
| Gemelos del **BSC** (Barcelona) | Gemelos digitales con supercomputación | Medio | Contacto local en Barcelona |

**Necesito una pista tuya** para acotarlo: país o empresa del stand, si era una mesa física (maqueta con piezas) o una pantalla, colores o logotipos, o qué pasaba al quitar un edificio.
**Ideas que sí podemos tomar:** modo "qué pasa si" (añadir o quitar kits y comparar brechas y aptitud entre dos escenarios), capa de inundación 3D con nivel de agua variable, y estructura semántica de los edificios. **Datos para Cali:** huellas de edificios de OpenStreetMap y las de Microsoft/Airbus que el repo ya trae (`prototipo/datos/raw/sismo/msft_danos.csv` 📁). Es fase 2.

## 6. Lo que falta verificar

1. Textos primarios de: Marco de Sendai (el PDF de la ONU no descargó), D.Lgs. 1/2018 arts. 6 y de las áreas de emergencia, planes de Cataluña, norma técnica de la Ciudad de México, leyes de Chile y Perú y reglamento mexicano sobre refugios y acopio.
2. Una segunda ronda sobre **incendios** (estructura de la cobertura: forestal y de edificaciones).
3. Si la UNGRD expidió ya los protocolos de la Ley 2474 art. 11 y si Cali ajustó su plan (art. 12).
4. Identidad del proyecto 3D.
