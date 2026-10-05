# Registro de fuentes (obligatorio)

> **Regla:** ninguna norma, cifra o afirmación técnica de `db/` y `docs/cumplimiento/` se cita sin una fila en este registro. Cada fila dice de dónde salió y **cuánto se verificó**.
> **Consultado:** 3 de octubre de 2026 (todas las búsquedas y lecturas web de esa fecha).

## Estados de verificación

| Marca | Significado | Qué hacer antes de citarlo en el video, el pitch o un documento oficial |
|---|---|---|
| 📁 | Archivo local del repo leído o ejecutado | Nada: es reproducible |
| 📜 | **Texto oficial leído** (copia consolidada del Senado, de la Alcaldía de Bogotá o PDF de la SIC), con el artículo exacto | Citar con el artículo; comprobar la vigencia en la nota de "Vigencia y jurisprudencia" de la fuente |
| ✅ | Página del proveedor leída con WebFetch (el texto lo resumió un modelo automático) | Releer la página si la decisión es crítica |
| 🔎 | Solo vi un resumen de resultado de búsqueda; **no abrí el texto primario** | Abrir la URL primaria y confirmar el artículo exacto |
| 🧠 | Dato de mi conocimiento previo, que no se confirmó | **Verificar contra el texto primario**; hasta entonces es "(verificar)" |
| ⛔ | No se pudo leer | Revisar a mano |

**Nota de acceso:** el Gestor Normativo de Función Pública (`funcionpublica.gov.co`) devolvió "unable to verify the first certificate" y no se pudo abrir desde aquí. Los textos se leyeron en el Senado (`secretariasenado.gov.co`, algunas páginas parciales) y en el Régimen Legal de Bogotá (`alcaldiabogota.gov.co`). Son copias consolidadas, no el Diario Oficial.

## A. Archivos del repo (📁)

| Dato usado | Fuente |
|---|---|
| 2.991 espacios (1.970 EPOU con polígono + 1.021 deportivos con punto), IDs `epou-N` y `deporte-N`, sin duplicados; `capacity`, `toilets`, `waterLitersPerDay`, `structuralAssessment` en `null`; `availability` "Por confirmar con la entidad responsable" en todos | `maqueta3d/public/data/spaces.json` (perfilado con Python el 2026-10-03) |
| Licencias (CC BY y CC BY-SA), `sha256`, conteos y fecha de corte 2026-09-25; fluvial 423, pluvial 227, no mitigable 3, licuación 16, efectos sísmicos 2 | `maqueta3d/public/data/manifest.json` |
| 653 polígonos de inundación, 7 sísmicos, 22 comunas, 342 barrios | `maqueta3d/public/data/{flood,seismic,communes,neighborhoods}.json` |
| Amenazas de la app (`flood`, `earthquake`, `drought`, `wildfire`, `building-fire`), servicios y tareas de incendio, reglas 20 personas por baño, 15 L por persona al día, 3,5 m² por persona, 100.000 personas máximo, seguimiento de 2 estados en `localStorage` (`cali-activa-followup-v1`), responsables UAESP, EMCALI y Gestión del Riesgo | `maqueta3d/src/{types,planning,fire,Intervention}.ts`, `maqueta3d/src/data/site.ts` |
| 182 organismos de acción comunal con nombre, comuna, barrio y dirección (organizaciones, no personas), licencia CC BY-SA | `prototipo/datos/raw/idesc/pfp_ivc_organismos_accion_comunal.geojson`, `prototipo/datos/fuentes.csv` |
| Organismos de socorro con teléfonos institucionales | `prototipo/datos/raw/cali_abiertos/organismos_socorro.csv` |
| `men_sedes.csv` incluye correo y teléfono (pendiente de limpiar para cumplir datos mínimos) | `prototipo/datos/raw/sismo/men_sedes.csv`; pendiente en `docs/PROYECTO.md` §7 |
| Marco legal que ya usa el equipo, filtro por capa, pendientes y reglas del proyecto | `docs/PROYECTO.md` §4, §6.1, §7; `AGENTS.md` §3 y §7 (la bitácora marca varias normas "verificar") |
| Owner del reto (Secretaría de Gestión del Riesgo de Emergencias y Desastres), líder técnico (DATIC) y entidades a articular (UAE de Gestión de Bienes y Servicios, Infraestructura, Deporte y Recreación, Seguridad y Justicia, Salud Pública, Bienestar Social, Educación, Planeación, EMCALI, UAESP) | `docs/portafolio_retos_alcaldia_cali.pdf`, ficha RETO-01 |
| Matriz de entidades responsables "propuesta sin validar"; "la decisión final es de la Secretaría de Gestión del Riesgo"; registro nominal custodiado por la entidad; conectar con el RUD de la UNGRD (verificar cómo opera hoy) | `docs/propuesta_cali_activa.md` |
| El entorno no tiene Docker, Supabase CLI ni psql; `gh` está autenticado; el remoto `origin` es público | comandos `which`, `gh auth status` y `git remote -v` del 2026-10-03 |

## B. Normas colombianas

| Dato usado | Fuente | Estado |
|---|---|---|
| **Ley 1581 de 2012**, art. 3 (autorización, dato personal, encargado, responsable, titular); art. 5 (datos sensibles: incluye salud y biometría); art. 7 (queda **proscrito** el tratamiento de datos de niños, niñas y adolescentes, salvo los de naturaleza pública); art. 14 (consultas: 10 días hábiles, prórroga de máximo 5); art. 15 (reclamos: 15 días hábiles, prórroga de máximo 8; leyenda "reclamo en trámite" en 2 días hábiles); art. 17 lit. n (informar a la autoridad las violaciones a los códigos de seguridad y los riesgos en la administración de la información); art. 26 (prohibida la transferencia a países sin nivel adecuado, con excepciones) | http://www.secretariasenado.gov.co/senado/basedoc/ley_1581_2012.html | 📜 |
| **Decreto 1377 de 2013**, art. 3 (aviso de privacidad; dato público: incluye la calidad de servidor público), art. 24 (las **transmisiones** internacionales entre responsable y encargado no requieren informar ni obtener consentimiento del titular si hay contrato del art. 25), art. 25 (contenido mínimo del contrato de transmisión), art. 26 (responsabilidad demostrada) | https://www.alcaldiabogota.gov.co/sisjur/normas/Norma1.jsp?i=53646 | 📜 |
| Decreto 1074 de 2015, cap. 25, compila el Decreto 1377; la **numeración compilada** de los arts. 24 y 25 (que yo recordaba como 2.2.2.25.5.1 y 2.2.2.25.5.2) no se confirmó | La página del decreto en Bogotá solo trae el índice; resultados de búsqueda de entidades que lo citan | 🔎 |
| **Circular Externa 005 de 2017 de la SIC**, numeral 3.2: la lista de países con nivel adecuado incluye Alemania, Austria, Bélgica, Bulgaria, Chipre, Costa Rica, Croacia, Dinamarca, Eslovaquia, Eslovenia, Estonia, España, **Estados Unidos de América**, Finlandia, Francia, Grecia, Hungría, Irlanda, Islandia, Italia, Letonia, Lituania, Luxemburgo, Malta, México, Noruega, Países Bajos, **Perú**, Polonia, Portugal, Reino Unido, República Checa, República de Corea, Rumania, Serbia, Suecia y "los países que han sido declarados con nivel adecuado de protección por la Comisión Europea". **Brasil no figura por su nombre.** La SIC puede modificar la lista (la Circular 008 de 2017 añadió Japón, según un resumen) | PDF de la circular https://operaciones.colombiacompra.gov.co/sites/cce_public/files/cce_informe_seguimiento/superindustria-circularexterna-2017-n0000005_20170810_1.pdf (extraído con `pdftotext`); https://normas.cra.gov.co/gestor/docs/circular_superindustria_0008_2017.htm | 📜 (lista de 2017) y 🔎 (modificaciones posteriores) |
| **Ley 1523 de 2012**, art. 2 (la gestión del riesgo es responsabilidad de todas las autoridades y habitantes; entidades públicas, privadas y **comunitarias** ejecutan los procesos; los habitantes son corresponsables); art. 12 (alcaldes: conductores del sistema en su nivel territorial); art. 14 (el alcalde representa al Sistema Nacional y es responsable directo de los procesos de gestión del riesgo, incluido el manejo de desastres); art. 27 (consejos territoriales como instancias de coordinación, asesoría, planeación y seguimiento); art. 28 (presidido por el alcalde o su delegado; integrantes; incorporan representantes del sector privado y comunitario); art. 29 par. 1 (municipios de más de 250.000 habitantes tienen una dependencia o entidad de gestión del riesgo); art. 55 a 58 (desastre; declaratoria; **calamidad pública: el alcalde la declara previo concepto favorable del consejo municipal, art. 57**) | https://www.alcaldiabogota.gov.co/sisjur/normas/Norma1.jsp?i=47141 y http://www.secretariasenado.gov.co/senado/basedoc/ley_1523_2012.html (esta última, parcial) | 📜 |
| **Ley 2474 de 2025** (Diario Oficial 53.176, 9-jul-2025), texto oficial completo leído. Modifica la Ley 1523 para incluir a los animales: art. 3 añade el principio 16 de **solidaridad con los animales** (todas las personas naturales y jurídicas, públicas o privadas, deben apoyar con acciones de prevención, protección, cuidado y atención a los animales expuestos o afectados) y el principio 17 de **prevalencia de la vida humana** cuando haya conflicto con la vida animal; art. 5 y 8 (la respuesta atiende a población y animales); art. 6 (directrices de bienestar animal); art. 10 (nuevo criterio para declarar desastre o calamidad: animales en peligro); **art. 11** (la UNGRD actualiza la Estrategia Nacional de Respuesta en 3 meses, caracteriza a los animales de cada zona y coordina en 6 meses protocolos sectoriales que incluyen evaluación y rescate, transporte, cuidados veterinarios y alimentación, **alojamiento temporal y reubicación** y disposición final); **art. 12** (dentro del año siguiente, es decir **hasta el 9 de julio de 2026**, las entidades territoriales deben ajustar sus estrategias y planes de gestión del riesgo con criterios de protección animal); art. 13 (campañas de la UNGRD, incluido el manejo seguro en refugios temporales); **art. 14** (los sistemas de información territoriales deben incluir información sobre animales e interoperar con el nacional); art. 15 (incentivos a hogares de paso); art. 16 (fondos territoriales) | https://sidn.ramajudicial.gov.co/SIDN//NORMATIVA/TEXTOS_COMPLETOS/7_LEYES/LEYES%202025/Ley%202474%20de%202025.pdf (PDF del Diario Oficial) | 📜 |
| **Ley 2166 de 2021**: deroga la Ley 743 de 2002; los organismos de acción comunal son de primero a cuarto grado (art. 6); la junta de acción comunal es de primer grado, con personería jurídica, integrada por residentes (art. 7); puede constituirse una junta por barrio, **conjunto residencial**, sector o etapa; entre las comisiones de trabajo figura la "Comisión accidental para la atención de emergencia". La entidad que ejerce inspección, vigilancia y control no se localizó en lo leído | http://www.secretariasenado.gov.co/senado/basedoc/ley_2166_2021.html | 📜 |
| **Ley 675 de 2001**, art. 1: regula la propiedad horizontal "con el fin de garantizar la seguridad y la convivencia pacífica en los inmuebles". Las funciones del administrador no se leyeron (la página del Senado vino parcial) | http://www.secretariasenado.gov.co/senado/basedoc/ley_0675_2001.html | 📜 (art. 1) y 🧠 (resto) |
| **Circular Externa 002 de 2024 de la SIC** (21-ago-2024): lineamientos de datos personales en sistemas de IA; criterios de idoneidad, necesidad, razonabilidad y proporcionalidad; responsabilidad demostrada | https://sedeelectronica.sic.gov.co/sites/default/files/normativa/Circular%20Externa%20No.%20002%20del%2021%20de%20agosto%20de%202024.pdf; resúmenes de Cuatrecasas (cuatrecasas.com) y CERLATAM (cerlatam.com) | 🔎 (existencia confirmada) |
| Registro Nacional de Bases de Datos: Decreto 090 de 2018 (obliga a sociedades y entidades sin ánimo de lucro con activos superiores a 100.000 UVT y a personas jurídicas de naturaleza pública) | https://www.funcionpublica.gov.co/eva/gestornormativo/norma_pdf.php?i=85039; Deloitte, "Registro Nacional de Bases de Datos 2025" | 🔎 |
| Alojamientos temporales: guía conjunta MinSalud, UNGRD e INS; los consejos de gestión del riesgo identifican los sitios; Circular UNGRD 040 de 2015; Resolución UNGRD 1390 de 2015. **El título exacto del "Protocolo de Alojamientos Temporales de la UNGRD" que cita la bitácora sigue sin confirmar** | https://bogota.gov.co/mi-ciudad/integracion-social/listos-los-protocolos-para-la-implementacion-de-alojamientos-temporale; https://www.cancilleria.gov.co/sites/default/files/Normograma/docs/pdf/resolucion_ungrd_1390_2015.pdf | 🔎 |
| Resolución MinTIC 500 de 2021 (modelo de seguridad y privacidad), Decreto 767 de 2022 (Política de Gobierno Digital), Decreto 338 de 2022 (gobernanza de la seguridad digital) | https://normas.cra.gov.co/gestor/docs/resolucion_mintic_0500_2021.htm | 🔎 |
| Ley 594 de 2000 (archivos y tablas de retención documental), CONPES 4144 de 2025 | Mi conocimiento o la bitácora (la página del Senado de la Ley 594 vino parcial) | 🧠 |
| Resto del marco de la bitácora: Ley 1098 de 2006, Ley 1712 de 2014, Ley 1273 de 2009, Ley 527 de 1999, Ley 1575 de 2012, Ley 400 de 1997 y NSR-10, Decreto 2157 de 2017, Resolución MinTIC 1519 de 2020 | `docs/PROYECTO.md` §4 (elaborada por el equipo, sin verificar aquí) | 🧠 |

## C. Estándares ISO

Las normas ISO son de pago: **no leí ningún texto**. Lo que sigue son títulos públicos y noticias de publicación.

| Dato usado | Fuente | Estado |
|---|---|---|
| ISO/IEC 27701:2025 ya es una norma independiente (sistema de gestión de información de privacidad) | https://www.kiwa.com/nl/en-nl/about-kiwa/news/isoiec-277012025-published-updated-privacy-standard-offers-organizations-more-guidance/ | 🔎 |
| ISO/IEC 27001:2022: 93 controles del Anexo A en 4 temas (organizacionales 37, personas 8, físicos 14, tecnológicos 34) | https://kertos.io/en/blog/what-are-iso-27001-controls-and-why-do-you-need-to-know-them | 🔎 |
| ISO/IEC 27035-1:2023, gestión de incidentes de seguridad | https://webstore.iec.ch/en/publication/83157 | 🔎 |
| Existencia y título de ISO/IEC 27005, 27017, 27018, 27031 y 27002:2022; ISO 22301, 22320, 22319, 31000, 42001; ISO/IEC 29134; ISO 37120 y 37122; numeración de controles del Anexo A (por ejemplo 8.15 registro de eventos, 8.31 separación de entornos) | Mi conocimiento previo | 🧠 |

## D. Proveedores y herramientas

| Dato usado | Fuente | Estado |
|---|---|---|
| Supabase ofrece la región São Paulo (`sa-east-1`) | https://supabase.com/docs/guides/platform/regions | 🔎 |
| RBAC con tablas `user_roles` y `role_permissions`, `custom_access_token_hook`, función `authorize()` y permisos restringidos al hook | https://supabase.com/docs/guides/database/postgres/custom-claims-and-role-based-access-control-rbac | ✅ |
| Plan Free sin backups automáticos; Pro guarda 7 días; Team 14; PITR de pago (unos US$100 al mes por 7 días); los backups no incluyen objetos de Storage | https://supabase.com/docs/guides/platform/backups | ✅ |
| MFA por TOTP y por teléfono; política `restrictive` que exige `aal2`. **La página no precisa en qué planes** | https://supabase.com/docs/guides/auth/auth-mfa | ✅ |
| Supabase Vault guarda secretos (no está pensado para cifrar columnas de datos personales). **No confirmé el estado de pgsodium ni del cifrado transparente de columnas** | https://supabase.com/docs/guides/database/vault | ✅ |
| Supabase y Vercel: ISO/IEC 27001:2022 y SOC 2 Type 2; DPA disponible | https://supabase.com/blog/supabase-is-now-iso-27001-certified.md; https://vercel.com/docs/security/compliance; https://vercel.co/legal/dpa | 🔎 |
| PGlite 0.5.8 soporta PostGIS y pgTAP como paquetes externos | `npm view @electric-sql/pglite` y https://pglite.dev/extensions/ | ✅ |
| El plan Free de Supabase pausa los proyectos inactivos; precio del plan Pro | Mi conocimiento previo | 🧠 |

## E. Derecho de la Unión Europea (solo contexto para Barcelona)

| Dato usado | Fuente | Estado |
|---|---|---|
| El Anexo III del Reglamento (UE) 2024/1689 lista ámbitos de alto riesgo, entre ellos infraestructuras críticas. **No pude confirmar que incluya el despacho de servicios de emergencia, así que no lo afirmo** | https://artificialintelligenceact.eu/ y https://ai-act-service-desk.ec.europa.eu/es/ai-act/article-6 | 🔎 |

## G. Referentes internacionales de desastres (para `docs/referentes/`)

| Dato usado | Fuente | Estado |
|---|---|---|
| **PETS Act de EE. UU.** (Public Law 109-308, 6-oct-2006): modifica la Ley Stafford para que los planes estatales y locales de preparación **tengan en cuenta las necesidades de personas con mascotas y animales de servicio antes, durante y después** de un desastre mayor | https://www.govinfo.gov/content/pkg/PLAW-109publ308/html/PLAW-109publ308.htm | 📜 |
| PETS Act: FEMA puede financiar albergues que admitan mascotas; los albergues deben permitir animales de servicio | https://aldf.org/article/the-pets-act-companion-animals-affected-by-natural-disasters/; https://www.animallaw.info/intro/state-and-federal-disaster-planning-laws-and-pets | 🔎 |
| **Japón:** reforma de junio de 2013 de la Ley Básica de Gestión de Desastres: designación de **lugares de evacuación de emergencia** y de **albergues designados**, listas de **personas que requieren asistencia para evacuar**, base de datos de personas afectadas y certificados de damnificado (láminas de la Oficina del Gabinete) | https://www.bousai.go.jp/en/documentation/reports/pdf/amendment_Jan.pdf | 📜 |
| Japón: la confusión previa entre lugares de evacuación y albergues contribuyó a ampliar el daño (motivo de la reforma) | https://pmc.ncbi.nlm.nih.gov/articles/PMC8580284; https://www.bousai.go.jp/en/documentation/white_paper/pdf/2022/PI1-2.pdf | 🔎 |
| Japón: guía del Ministerio del Ambiente sobre mascotas en desastres (2013, revisada en marzo de 2018), principio "doko hinan" (evacuar con mascotas); no es ley, orienta a los gobiernos locales | https://www.env.go.jp/press/105427.html; https://pmc.ncbi.nlm.nih.gov/articles/PMC7359046 | 🔎 |
| **Italia:** D.Lgs. 1/2018, art. 1, c. 1: la función de protección civil tutela "la vida, la integridad física, los bienes, los asentamientos, **los animales** y el ambiente". Autoridades de protección civil (el alcalde, el presidente de la región y el del Consejo de Ministros, art. 6) y áreas de espera, recepción y concentración en los planes municipales | https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:decreto.legislativo:2018-01-02;1 (art. 1, leído); planes municipales de Arezzo y Prato (áreas) | 📜 (art. 1) y 🔎 (art. 6 y áreas) |
| **Unión Europea:** Directiva 2007/60/CE: mapas de peligrosidad y de riesgo de inundación (a más tardar el 22-dic-2013) y planes de gestión del riesgo de inundación (art. 7). En España, Real Decreto 903/2010 | https://eur-lex.europa.eu/legal-content/ES/TXT/HTML/?uri=CELEX:32007L0060 (leída); https://www.miteco.gob.es/es/agua/legislacion/directiva2007_60_ce_inundaciones_tcm30-215329.pdf | 📜 (Directiva) y 🔎 (RD 903/2010) |
| **Cataluña:** PROCICAT (revisión aprobada por GOV/114/2022), SISMICAT (emergencias sísmicas), INUNCAT (inundaciones), INFOCAT (incendios forestales) y DUPROCIM municipal | https://dsp.interior.gencat.cat/handle/20.500.14007/2844; planes municipales de Manresa, Reus y Riba-roja d'Ebre | 🔎 |
| **Turquía:** AFAD y las áreas de reunión tras el sismo de Marmara de 1999; 3.021 áreas en Estambul y 1,29 m² por persona; las áreas de reunión se usan al instante y las de alojamiento temporal acogen hasta dos años; las áreas se pierden por construcción | https://openaccess.iku.edu.tr/entities/publication/b8e007bf-d7c1-4df5-8227-c72acafd255f; https://bianet.org/haber/questions-resurface-over-istanbul-s-earthquake-assembly-zones-306768; https://stockholmcf.org/?p=67064 | 🔎 |
| **Marco de Sendai 2015-2030** y 4 prioridades (comprender el riesgo, fortalecer la gobernanza, invertir en reducción, mejorar la preparación y la recuperación). El documento oficial de las Naciones Unidas no se pudo descargar (respuesta vacía) | https://www.preventionweb.net/es/sendai-framework/sendai-framework-for-disaster-risk-reduction | 🔎 |
| **Sphere 2018** y estándar complementario **LEGS** (ganado, no mascotas) | https://spherestandards.org/new-companion-standards-to-the-sphere-handbook | 🔎 |
| **Chile:** Ley 21.364 (SINAPRED, SENAPRED, instrumentos nacionales, regionales, provinciales y comunales). **Perú:** Ley 29664 (SINAGERD). **México:** Ley General de Protección Civil y norma técnica NT-SGIRPC-RTA-010-2025 de la Ciudad de México (apertura, operación y cierre de refugios temporales); el reglamento dice que los refugios temporales no pueden funcionar como centros de acopio | https://www.preventionweb.net/publication/policies-and-plans/peru-ley-no-29664-ley-que-crea-el-sistema-nacional-de-gestion-del (URL tal como la devolvió la búsqueda); resultados de búsqueda de la Universidad de Chile y de la Ciudad de México | 🔎 |
| **NFPA 1600** (programas de gestión de emergencias y continuidad), **NFPA 101** (seguridad de vida en edificios), **NFPA 1140 y 1144** (incendios forestales y zona urbano-forestal); normas de pago, no leídas | https://asprtracie.hhs.gov/technical-resources/resource/3175/nfpa-1600-standard-on-disaster-emncy-management-and-business-continuity-programs; https://www.bnibooks.com/products/2024-nfpa-101-life-safety-code | 🔎 |
| **Estudios SIG multicriterio** de ubicación de albergues: criterios (distancia a la falla, densidad de población, espacios verdes, calidad de edificios; pendiente, elevación, uso del suelo, vías, agua y electricidad), marco **COSI-SAFE** (calidad, capacidad y accesibilidad) y caso de la Gran Victoria (los espacios abiertos no coinciden con la población) | https://isprs-archives.copernicus.org/articles/XLVIII-4-W6-2022/473/2023/isprs-archives-XLVIII-4-W6-2022-473-2023.pdf; https://vbn.aau.dk/ws/files/536324384/sustainability_15_04019.pdf; https://www.nat-hazards-earth-syst-sci.net/15/789/2015/nhess-15-789-2015-metrics.html | 🔎 |
| **Gemelos digitales y maquetas 3D urbanas:** Project PLATEAU (MLIT, Japón: ~250 ciudades en CityGML, Re:Earth, simulación de inundaciones), ArcGIS Urban (Esri), Virtual Singapore, Helsinki 3D+, vCity y gemelos del BSC | https://www.mlit.go.jp/plateau/en/; https://www.esri.com/en-us/arcgis/products/arcgis-urban/resources/get-started; https://en.wikipedia.org/wiki/Virtual_Singapore; https://www.bsc.es/news/bsc-news/digital-twins-ai-and-supercomputing-bsc-drives-urban-innovation-smart-city-expo | 🔎 |
| **Smart City Expo World Congress 2025** (4 a 6 de noviembre de 2025, más de 27.000 asistentes de 138 países); su eje fueron los gemelos digitales y la IA | https://www.mlit.go.jp/plateau/en/j001/; https://www.geosolutionsgroup.com/blog/geosolutions-at-scewc-2026/ | 🔎 |
| Ley 1774 de 2016 (animales como seres sintientes), Ley 84 de 1989, Ley 1618 de 2013 (discapacidad) | Mi conocimiento previo | 🧠 |

## F. No leído

| Documento | Qué pasó |
|---|---|
| `Descargas/TDR_Convocatoria_Hackathon_Smart_City_Expo_Cali_2026.pdf` | `pdftotext` no devolvió coincidencias para propiedad intelectual, premios ni Barcelona. **Revisar a mano** las reglas de publicación y propiedad intelectual antes de decidir si `db/` va en un repo público o privado |
| Estructura de la Secretaría de Gestión del Riesgo de Cali, Plan Municipal de Gestión del Riesgo, Estrategia Municipal de Respuesta y protocolo local de activación de albergues | No se buscaron todavía. Se piden por derecho de petición o se leen en el normograma de Cali (ver `ENTES_DECISORES.md`) |

## Correcciones a versiones anteriores del plan

- La ley vigente de acción comunal es la **2166 de 2021**, no la 743 de 2002 (📜).
- La declaratoria de calamidad pública es el **art. 57** de la Ley 1523, no el 27 (📜).
- Los plazos de consulta (10 días hábiles) y reclamo (15) **sí** son los que recordaba, y las prórrogas son de 5 y 8 días hábiles (📜).
- **Brasil no está nominalmente** en la lista de la SIC de 2017; **Estados Unidos y Perú sí**. Esto cambia la discusión de la región de Supabase (ver `MATRIZ_NORMATIVA.md`).
- La **Ley 2474 de 2025** añade animales a la Ley 1523: no estaba en el plan y puede pedir un servicio nuevo en los albergues.
- **Vault no sirve** para cifrar columnas de datos personales; el diseño evita cifrarlas guardando el mínimo.
- El plan **Free de Supabase no hace backups**.
- No se afirma nada del AI Act sobre despacho de emergencias.
- **Ley 2474 de 2025:** el plazo de las entidades territoriales para ajustar sus planes con criterios de protección animal (art. 12) **venció el 9 de julio de 2026**; se debe preguntar a la Secretaría si Cali lo cumplió. El art. 11 obliga a la UNGRD a coordinar protocolos sectoriales, entre ellos de alojamiento temporal de animales: hay que averiguar si ya se expidieron.
