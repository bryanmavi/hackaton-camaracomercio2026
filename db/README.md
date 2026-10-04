# Base de datos de Territorio Preparado

Raíz de la base de datos del proyecto (RETO-01 Cali Activa) para montarla en **Supabase** (PostgreSQL + PostGIS + Auth + RLS) y consumirla desde el frontend en **Vercel**.

## Estado

| Hito | Entrega | Estado |
|---|---|---|
| H1 | Modelo, diccionario, roles y decisiones | **En revisión** (`db/docs/`) |
| H2 | Migraciones y datos reales | Pendiente de aprobar H1 |
| H3 | RLS, auditoría, pruebas y CI | Pendiente |
| H4 | Cumplimiento (Colombia e ISO 27000) | En curso (`docs/cumplimiento/`) |
| H5 | Usuarios de demostración y guía de montaje | Pendiente |

## Dónde leer

1. [`docs/MODELO_DATOS.md`](docs/MODELO_DATOS.md): principios, esquemas, diagrama, flujo y decisiones abiertas.
2. [`docs/DICCIONARIO.md`](docs/DICCIONARIO.md): cada tabla, columna, clase de dato y retención.
3. [`docs/ROLES_Y_PERMISOS.md`](docs/ROLES_Y_PERMISOS.md): los 8 roles, la matriz y las 13 cuentas de demostración.
4. [`docs/DECISIONES.md`](docs/DECISIONES.md): por qué se diseñó así.
5. [`../docs/cumplimiento/FUENTES.md`](../docs/cumplimiento/FUENTES.md): de dónde sale cada dato o norma y cuánto se verificó.

## Reglas para quien trabaje aquí (también la IA del equipo)

- **Nunca** subas claves, contraseñas, la `service_role`, URLs de conexión ni datos personales. El repo es público.
- El frontend y el backend solo usan el esquema `api` (ver el contrato cuando exista `CONTRATO_API.md`).
- Los datos desconocidos son `NULL`, nunca cero. Los datos de demostración llevan `es_simulado = true`.
- No hay tabla de personas damnificadas y no se agrega: ver ADR-0008.
- Cada norma que cites necesita una fila en `docs/cumplimiento/FUENTES.md`.
