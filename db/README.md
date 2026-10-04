# Base de datos de Territorio Preparado

Raíz de la base de datos del proyecto (RETO-01 Cali Activa) para montarla en **Supabase** (PostgreSQL + PostGIS + Auth + RLS) y consumirla desde el frontend en **Vercel**.

## Estado

| Hito | Entrega | Estado |
|---|---|---|
| H1 | Modelo, diccionario, roles y decisiones | **En revisión** (`db/docs/`) |
| H1 SQL | Esquema, catálogos, RLS, auditoría, API y 69 pruebas | **Borrador en revisión** (`db/supabase/migrations/`, `db/tests/`) |
| H2 | Carga de datos reales (espacios, comunas, barrios, amenazas, JAC) | **Lista y probada** (`scripts/cargar_datos_reales.mjs`): falta correrla en Supabase |
| H3 | Pruebas en Supabase real, CI y anclaje externo del hash | Pendiente (la RLS, la auditoría y las pruebas ya existen en borrador) |
| H4 | Cumplimiento (Colombia e ISO 27000) | En curso (`docs/cumplimiento/`) |
| H5 | Usuarios de demostración y guía de montaje | **Hecho en `dev`**: 13 cuentas verificadas (`npm run cuentas-demo`) |

## Cómo probar el SQL (sin Supabase ni Docker)

```bash
cd db
npm install     # PGlite: PostgreSQL 18 + PostGIS 3.6 en WASM, solo para pruebas
npm test        # pruebas del SQL (tests/*.test.sql) y de la carga de datos reales (tests/carga.mjs)
```

`tests/shim_supabase.sql` imita lo mínimo de Supabase (roles `anon`, `authenticated`, `service_role`, `auth.uid()`, `auth.jwt()`); **no se aplica en Supabase**. Las migraciones siguen el formato de la CLI de Supabase (`supabase db push`).

## Cargar los datos reales (Hito 2)

```bash
cd db
DATABASE_URL='postgresql://…?sslmode=require' npm run cargar   # la URL solo en tu terminal, nunca en el repo
```

En una transacción, y se puede repetir sin duplicar: verifica el `sha256` y el conteo de los 9 archivos crudos de la IDESC contra `maqueta3d/public/data/manifest.json`. Después carga 22 comunas, 342 barrios, 2.991 espacios, 660 zonas de amenaza (las capas derivadas que usa la app) y 182 JAC, y comprueba los conteos. Si algo no cuadra, deshace todo. Los cruces de PostGIS coinciden **exactamente** con los que precalculó la app: 884 espacios con cruce de inundación y 1.369 con cruce sísmico.

Se carga tal como viene, sin inventar: 52 espacios sin comuna, 23 JAC cuyo código de barrio no está en la capa de barrios, y 3 huellas y 18 zonas que GEOS marca como geometrías no válidas (no se "reparan" en silencio; se listan con `select id from geo.espacios where not extensions.st_isvalid(huella)`).

## Estructura

| Ruta | Qué hay |
|---|---|
| `supabase/migrations/…01` | Esquemas, extensión PostGIS, tipo `rol_app`, filtro de datos personales |
| `…02` a `…05` | Tablas de `ref`, `geo`, `idn` y `ops` con sus reglas de integridad |
| `…06` | Auditoría encadenada por hash y su verificación |
| `…07` | Semilla de catálogos (todo lo institucional marcado `propuesta`) |
| `…08` | Permisos como datos, funciones de autorización y políticas RLS |
| `…09` y `…10` | Vistas y funciones del esquema `api` (contrato en [`docs/CONTRATO_API.md`](docs/CONTRATO_API.md)) |
| `…11` | Privilegios mínimos explícitos |
| `…12` | `id_fuente` de las organizaciones (para recargar las JAC sin duplicar) |
| `…13` | `api.provisionar_perfil` y `api.asegurar_organizacion`, solo para `service_role` |
| `…14` | `api.mediciones_verificadas` y `orden_fuente` (conexión de la app) |
| `tests/paridad_app.mjs` | La app recibe de la base exactamente lo mismo que de los JSON |
| `scripts/crear_usuarios_demo.mjs` | Las 13 cuentas de demostración (Hito 5) |
| `scripts/cargar_datos_reales.mjs` | Carga del Hito 2 |
| `tests/` | Shim, ejecutor, 69 pruebas de SQL y 17 de carga |

## Dónde leer

- [`docs/ACCESO_EQUIPO.md`](docs/ACCESO_EQUIPO.md): paso a paso para que cada integrante acceda a la base.
- [`docs/ENTORNO_LINUX.md`](docs/ENTORNO_LINUX.md): herramientas, rutas, comandos y errores resueltos del entorno.
- [`docs/INFORME_MONTAJE_SUPABASE.md`](docs/INFORME_MONTAJE_SUPABASE.md): qué se montó en Supabase y qué falta.
0. [`docs/CONTRATO_API.md`](docs/CONTRATO_API.md): lo que puede usar el frontend (vistas y funciones).
1. [`docs/MODELO_DATOS.md`](docs/MODELO_DATOS.md): principios, esquemas, diagrama, flujo y decisiones abiertas.
2. [`docs/DICCIONARIO.md`](docs/DICCIONARIO.md): cada tabla, columna, clase de dato y retención.
3. [`docs/ROLES_Y_PERMISOS.md`](docs/ROLES_Y_PERMISOS.md): los 8 roles, la matriz y las 13 cuentas de demostración.
4. [`docs/DECISIONES.md`](docs/DECISIONES.md): por qué se diseñó así.
5. [`../docs/cumplimiento/FUENTES.md`](../docs/cumplimiento/FUENTES.md): de dónde sale cada dato o norma y cuánto se verificó.
6. [`../docs/cumplimiento/MATRIZ_NORMATIVA.md`](../docs/cumplimiento/MATRIZ_NORMATIVA.md): norma, control y evidencia; discusión de la región.
7. [`../docs/cumplimiento/ENTES_DECISORES.md`](../docs/cumplimiento/ENTES_DECISORES.md): quién decide y ejecuta ante una emergencia en Cali.
8. [`../docs/cumplimiento/RED_COMUNITARIA.md`](../docs/cumplimiento/RED_COMUNITARIA.md): juntas de acción comunal y administradores de conjuntos, y su capacitación.
9. [`../docs/referentes/REFERENTES_INTERNACIONALES.md`](../docs/referentes/REFERENTES_INTERNACIONALES.md): ideas, normas y leyes del mundo por amenaza, y qué adoptamos.
10. [`../docs/referentes/INDICE_APTITUD_Y_MAPA_DE_CALOR.md`](../docs/referentes/INDICE_APTITUD_Y_MAPA_DE_CALOR.md): diseño del mapa de calor de aptitud (fase 2).

## Reglas para quien trabaje aquí (también la IA del equipo)

- **Nunca** subas claves, contraseñas, la `service_role`, URLs de conexión ni datos personales. El repo es público.
- El frontend y el backend solo usan el esquema `api` (ver `docs/CONTRATO_API.md`).
- Todo cambio de esquema es una **migración nueva**; nunca se edita una migración ya aplicada en `dev` o `demo`.
- Los datos desconocidos son `NULL`, nunca cero. Los datos de demostración llevan `es_simulado = true`.
- No hay tabla de personas damnificadas y no se agrega: ver ADR-0008.
- Cada norma que cites necesita una fila en `docs/cumplimiento/FUENTES.md`.
