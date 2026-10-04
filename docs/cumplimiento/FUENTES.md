# Registro de fuentes (obligatorio)

> **Regla:** ninguna norma, cifra o afirmación técnica de `db/` y `docs/cumplimiento/` se cita sin una fila en este registro. Cada fila dice de dónde salió y **cuánto se verificó**.
> **Consultado:** 3 de octubre de 2026 (todas las búsquedas y lecturas web de esa fecha).

## Estados de verificación

| Marca | Significado | Qué hacer antes de citarlo en el video, el pitch o un documento oficial |
|---|---|---|
| 📁 | Archivo local del repo leído o ejecutado | Nada: es reproducible |
| ✅ | Página oficial del proveedor leída con WebFetch (el texto lo resumió un modelo automático) | Releer la página si la decisión es crítica |
| 🔎 | Solo vi un resumen de resultado de búsqueda; **no abrí el texto primario** | Abrir la URL primaria y confirmar el artículo exacto |
| 🧠 | Dato de mi conocimiento previo, que la búsqueda no confirmó | **Verificar contra el texto primario**; hasta entonces es "(verificar)" |
| ⛔ | No se pudo leer | Revisar a mano |

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
| Matriz de entidades responsables "propuesta sin validar"; registro nominal custodiado por la entidad; conectar con el RUD de la UNGRD (verificar cómo opera hoy) | `docs/propuesta_cali_activa.md` |
| El entorno no tiene Docker, Supabase CLI ni psql; `gh` está autenticado; el remoto `origin` es público | comandos `which`, `gh auth status` y `git remote -v` del 2026-10-03 |

## B. Normas colombianas

| Dato usado | Fuente | Estado | Cómo cerrarlo (Hito 4) |
|---|---|---|---|
| Decreto 1074 de 2015, cap. 25, reglamenta la Ley 1581 de 2012; arts. 2.2.2.25.3.1 (políticas) y 2.2.2.25.4.4 (persona o área encargada) | Resultados de búsqueda de entidades que citan el decreto (Función Pública, políticas de tratamiento) | 🔎 | Leer el decreto en el Gestor Normativo de Función Pública o en el normograma de la SIC |
| Ley 1523 de 2012, art. 14: el alcalde es responsable directo de los procesos de gestión del riesgo; art. 57: la calamidad pública se declara con concepto favorable del consejo. (Corrige "art. 27", que usé al buscar) | Decretos municipales que citan la ley (resultados de búsqueda: Bucaramanga, Cali) | 🔎 | Leer la ley en Función Pública |
| Circular Externa 002 de 2024 de la SIC (21 de agosto de 2024): lineamientos de datos personales en IA, criterios de idoneidad, necesidad, razonabilidad y proporcionalidad, y responsabilidad demostrada | https://sedeelectronica.sic.gov.co/sites/default/files/normativa/Circular%20Externa%20No.%20002%20del%2021%20de%20agosto%20de%202024.pdf; resúmenes de Cuatrecasas (cuatrecasas.com) y CERLATAM (cerlatam.com) | 🔎 (existencia confirmada) | Abrir el PDF de la SIC |
| Ley 2166 de 2021 deroga la Ley 743 de 2002 y regula los organismos de acción comunal. (Corrige mi versión anterior, que citaba la Ley 743) | https://www.funcionpublica.gov.co/eva/gestornormativo/norma.php?i=184758 | 🔎 | Leer la ley |
| Circular Externa 005 de 2017 de la SIC: lista de 36 países con nivel adecuado (incluye Estados Unidos); la Circular 008 de 2017 añadió Japón. **No confirmé si Brasil está en la lista** | Holland & Knight (hklaw.com, 25-ago-2017); https://normas.cra.gov.co/gestor/docs/circular_superindustria_0008_2017.htm | 🔎 | Abrir la circular y la lista vigente de la SIC |
| Registro Nacional de Bases de Datos: Decreto 090 de 2018 (obliga a sociedades y entidades sin ánimo de lucro con activos superiores a 100.000 UVT y a personas jurídicas de naturaleza pública) | https://www.funcionpublica.gov.co/eva/gestornormativo/norma_pdf.php?i=85039; Deloitte, "Registro Nacional de Bases de Datos 2025" | 🔎 | Leer el decreto y la guía vigente de la SIC |
| Alojamientos temporales: guía conjunta MinSalud, UNGRD e INS; los consejos de gestión del riesgo identifican los sitios; Circular UNGRD 040 de 2015; Resolución UNGRD 1390 de 2015. **El título exacto del "Protocolo de Alojamientos Temporales de la UNGRD" que cita la bitácora sigue sin confirmar** | https://bogota.gov.co/mi-ciudad/integracion-social/listos-los-protocolos-para-la-implementacion-de-alojamientos-temporale; https://www.cancilleria.gov.co/sites/default/files/Normograma/docs/pdf/resolucion_ungrd_1390_2015.pdf | 🔎 | Localizar el documento oficial en la UNGRD |
| Resolución MinTIC 500 de 2021 (modelo de seguridad y privacidad), Decreto 767 de 2022 (Política de Gobierno Digital), Decreto 338 de 2022 (gobernanza de la seguridad digital) | https://normas.cra.gov.co/gestor/docs/resolucion_mintic_0500_2021.htm | 🔎 | Leer cada norma |
| Plazos de consulta (10 días hábiles) y reclamo (15 días hábiles) de la Ley 1581, arts. 14 y 15; prohibición de transferir a países sin nivel adecuado, art. 26; deber de informar incidentes de seguridad, art. 17; contrato de transmisión, Decreto 1074 art. 2.2.2.25.5.2 | Mi conocimiento previo; la búsqueda no los confirmó | 🧠 | Leer la Ley 1581 y el decreto |
| Ley 675 de 2001 (propiedad horizontal), Ley 594 de 2000 (archivos y tablas de retención documental), CONPES 4144 de 2025 | Mi conocimiento previo o la bitácora del equipo | 🧠 | Leer cada norma |
| Resto del marco de la bitácora: Ley 1098 de 2006, Ley 1712 de 2014, Ley 1273 de 2009, Ley 527 de 1999, Ley 1575 de 2012, Ley 400 de 1997 y NSR-10, Decreto 2157 de 2017, Resolución MinTIC 1519 de 2020 | `docs/PROYECTO.md` §4 (elaborada por el equipo, sin verificar aquí) | 🧠 | Verificar cada una |

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

## F. No leído

| Documento | Qué pasó |
|---|---|
| `Descargas/TDR_Convocatoria_Hackathon_Smart_City_Expo_Cali_2026.pdf` | `pdftotext` no devolvió coincidencias para propiedad intelectual, premios ni Barcelona. **Revisar a mano** las reglas de publicación y propiedad intelectual antes de decidir si `db/` va en un repo público o privado |

## Correcciones a versiones anteriores del plan

- La ley vigente de acción comunal es la **2166 de 2021**, no la 743 de 2002.
- La declaratoria de calamidad pública es el **art. 57** de la Ley 1523, no el 27.
- **Vault no sirve** para cifrar columnas de datos personales; el diseño evita cifrarlas guardando el mínimo.
- El plan **Free de Supabase no hace backups**.
- No se afirma nada del AI Act sobre despacho de emergencias.
