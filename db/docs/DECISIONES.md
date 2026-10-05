# Decisiones de arquitectura (ADR)

> Formato: contexto, decisión, alternativas, consecuencias. Estado de todas: **propuesta** hasta que el responsable de la BD las apruebe (gate del Hito 1).

## ADR-0001. PostgreSQL con PostGIS en Supabase

- **Contexto:** hay que cruzar 2.991 espacios con polígonos de amenaza (¿este espacio cae en zona inundable?), mantener relaciones (espacio, brecha, entidad), auditar y controlar acceso por fila. La demo se monta en Supabase y Vercel.
- **Decisión:** PostgreSQL gestionado por Supabase con la extensión PostGIS.
- **Alternativas:** Firestore o NoSQL (débil en consultas espaciales y relaciones); SQLite o GeoPackage (solo sirve para una demo local); otro Postgres gestionado sin Auth integrado (habría que construir autenticación).
- **Consecuencias:** estándar abierto y portable (los volcados y las migraciones SQL sirven en cualquier Postgres); Auth y RLS vienen integrados; dependemos de Supabase para el alojamiento, mitigado con migraciones en el repo, volcados cifrados y snapshots públicos estáticos.

## ADR-0002. Solo el esquema `api` queda expuesto

- **Contexto:** PostgREST expone por defecto el esquema `public`; un error de permisos en una tabla la deja abierta. Además, en Postgres las funciones son ejecutables por `PUBLIC` salvo que se revoque.
- **Decisión:** tablas en `ref`, `geo`, `ops`, `idn`, `aud` (no expuestos). El frontend solo ve `api`: vistas con `security_invoker` (respetan la RLS de quien consulta) y funciones RPC. Se revoca `EXECUTE` a `PUBLIC` y `anon` por defecto, y las funciones `SECURITY DEFINER` fijan `search_path = ''`.
- **Alternativas:** exponer tablas con RLS (más simple, pero el contrato con el frontend queda atado al esquema interno).
- **Consecuencias:** el compañero de frontend y backend trabaja contra un contrato estable (`CONTRATO_API.md`); cambiar tablas internas no rompe la app; hay que mantener las vistas.

## ADR-0003. Recomienda no decide

- **Contexto:** la Ley 1523 de 2012 asigna la gestión del riesgo a las autoridades; la ficha del reto prohíbe reemplazar sus decisiones.
- **Decisión:** `ops.recomendaciones` (inmutable, salida del sistema) y `ops.decisiones_activacion` (acto humano) son tablas distintas. Solo `api.registrar_decision_activacion`, ejecutable por `gestion_riesgo` con `aal2`, inserta una decisión, y exige el acto administrativo que la respalda. Si se aparta de la recomendación, exige justificación.
- **Alternativas:** una sola tabla con un campo `estado` (borra la frontera entre lo que dice el sistema y lo que decide la autoridad).
- **Consecuencias:** queda evidencia de cada decisión y de su fundamento; las pruebas verifican que ningún otro camino inserte decisiones.

## ADR-0004. Rol por cargo, no por persona

- **Contexto:** los gobiernos cambian cada 4 años; un sistema atado a personas se rompe en cada transición.
- **Decisión:** el rol y los permisos se atan al **cargo** (`idn.cargos`); las personas lo ocupan por periodos (`idn.asignaciones_cargo`). Las entidades tienen vigencia y sucesora. Los datos pertenecen a la entidad, no al funcionario.
- **Alternativas:** rol directo en el perfil del usuario (más simple, pero el traspaso exige editar usuarios uno por uno).
- **Consecuencias:** el traspaso es una operación auditada del superusuario; el historial sobrevive; hay una tabla más.

## ADR-0005. Desconocido es NULL con estado de verificación

- **Contexto:** la app ya trata capacidad, baños, agua y evaluación estructural como `null` y se niega a convertirlos en cero; los 2.991 espacios están "por confirmar".
- **Decisión:** los atributos verificables van en `geo.mediciones_espacio` con estado (`declarado`, `verificado`, `rechazado`), fuente y evidencia. Sin fila = desconocido. Lo `verificado` exige quién, cuándo y evidencia. De la evaluación estructural solo se guarda sí/no y fecha, nunca un concepto.
- **Alternativas:** columnas fijas en `geo.espacios` (pierden la historia y confunden "no medido" con cero).
- **Consecuencias:** las vistas calculan la ficha con la última medición verificada; el faltante de una brecha es `NULL` cuando no hay dato.

## ADR-0006. Auditoría append-only encadenada por hash

- **Contexto:** los registros digitales sirven de evidencia (Ley 527 de 1999, verificar) y el control de logs es parte de ISO 27002.
- **Decisión:** `aud.eventos` recibe una fila por trigger en cada tabla de `ops`, `idn` y `geo.mediciones_espacio`. Guarda solo el UUID del actor (sin nombres). Cada fila incluye `sha256(hash_previo + contenido)`. UPDATE, DELETE y TRUNCATE están bloqueados y `verificar_cadena()` recorre la cadena. Opcional (P1): publicar el hash de cabecera diario en el repo como ancla externa.
- **Alternativas:** auditoría de Supabase o logs de Postgres (no son consultables por rol ni verificables por el auditor).
- **Consecuencias:** las escrituras se serializan con un bloqueo asesor (aceptable en el MVP); el dueño de la BD técnicamente podría reescribir la tabla, por eso la verificación y el ancla externa.

## ADR-0007. La lógica de reglas sigue en TypeScript

- **Contexto:** `planning.ts` ya calcula candidatos y brechas, con pruebas (`planning.spec.ts`).
- **Decisión:** la BD no duplica las reglas. Guarda parámetros versionados (`ref.parametros_reglas`), entradas y salidas (`ops.recomendaciones`, `ops.brechas`) y la versión usada.
- **Alternativas:** motor de reglas en SQL (dos fuentes de verdad que divergen).
- **Consecuencias:** hay que subir la versión de parámetros cuando cambie una regla; la explicabilidad se conserva porque cada recomendación guarda la versión que la produjo.

## ADR-0008. Exclusión por diseño de datos de personas

- **Contexto:** `AGENTS.md` §3 prohíbe nombres, documentos y datos de menores; el registro nominal es responsabilidad de la entidad y del RUD de la UNGRD.
- **Decisión:** no existe ninguna tabla ni columna para damnificados. Los reportes son conteos agregados por grupo de edad; los textos libres pasan por un filtro que rechaza correos, teléfonos y secuencias numéricas largas; las vistas públicas suprimen celdas menores al umbral N.
- **Alternativas:** guardar registro nominal cifrado (convierte al proyecto en responsable de datos sensibles y de menores).
- **Consecuencias:** el DPIA se reduce a las cuentas institucionales y a los conteos pequeños; si algún día se integra con el RUD, será por interfaz y con agregados.

## ADR-0009. Dos proyectos de Supabase

- **Contexto:** ISO 27002 pide separar desarrollo, prueba y producción; el plan gratuito de Supabase no hace backups automáticos.
- **Decisión (propuesta):** un proyecto `dev` para el equipo y un proyecto `demo` para el evento, este último en un plan con backups o con volcados cifrados programados.
- **Consecuencias:** costo del plan de pago durante el evento (verificar precio vigente); las migraciones del repo son la única forma de llegar de `dev` a `demo`.
