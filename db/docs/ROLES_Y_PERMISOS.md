# Roles y permisos (Hito 1, para revisión)

> El **cargo** manda, no la persona. Los permisos viven como datos en `idn.rol_permisos`, así se pueden auditar y probar con pgTAP.
> Mecanismo: `custom_access_token_hook` de Supabase mete `user_role`, `entidad_id` y la zona en el JWT, y las políticas RLS llaman a `authorize('permiso')`. Las escrituras sensibles exigen MFA (`aal2`) con una política `restrictive`. Patrón oficial: https://supabase.com/docs/guides/database/postgres/custom-claims-and-role-based-access-control-rbac

## 1. Los 8 roles

| Rol | Quién es | Qué hace | Qué **no** hace |
|---|---|---|---|
| `superusuario` | Administrador de la plataforma | Crea, suspende y asigna roles; traspasa cargos; edita entidades | No opera la emergencia, no decide activaciones, no lee datos operativos (separación de funciones) |
| `gestion_riesgo` | Secretaría de Gestión del Riesgo y su coordinación de respuesta | **Decide qué albergues activar** y dispara el protocolo; valida mediciones; cierra retornos; ajusta el protocolo | No crea usuarios |
| `entidad_responsable` | UAESP, EMCALI, Salud Pública, Bienestar Social y demás entidades de la matriz | Actualiza brechas y tareas de **sus** servicios; declara mediciones | No decide activaciones; no ve las tareas de otras entidades |
| `datic_tecnico` | DATIC (líder técnico del reto) | Calidad de datos, catálogos y fuentes | No decide ni lee el detalle operativo |
| `comunitario` | Juntas de acción comunal y administradores de conjuntos residenciales | Reporta conteos agregados y estado del espacio **solo en su zona**; declara mediciones | No verifica, no ve datos de otras zonas, no usa texto libre sensible |
| `auditor` | Control interno, personería, órganos de control, jurados técnicos | Lee la auditoría y todo lo operativo | No escribe nada |
| `consulta` | Jurados, Cámara de Comercio, aliados | Lee lo operativo agregado | No escribe; no ve cuentas ni auditoría |
| `anon` | Público | Lee solo los datos abiertos y la matriz de responsabilidades (marcada "propuesta") | No escribe nada |

## 2. Permisos (`idn.rol_permisos`)

| Permiso | superusuario | gestion_riesgo | entidad_responsable | datic_tecnico | comunitario | auditor | consulta |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| `espacios.leer` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| `operativo.leer` (decisiones, brechas, tareas) | | ✓ | propias | | zona (decisiones vigentes) | ✓ | agregado |
| `recomendacion.crear` | | ✓ | ✓ | | | | |
| `decision.activar` (aal2) | | **✓** | | | | | |
| `retorno.cerrar` | | ✓ | | | | | |
| `brecha.actualizar` | | ✓ | propias | | | | |
| `tarea.completar` | | ✓ | propias | | | | |
| `medicion.declarar` | | ✓ | ✓ | | ✓ (zona) | | |
| `medicion.validar` | | ✓ | su servicio | | | | |
| `reporte.crear` | | | | | **✓ (zona)** | | |
| `catalogos.editar` (fuentes, servicios, parámetros) | | parámetros | | ✓ | | | |
| `protocolo.editar` | | ✓ | | | | | |
| `entidades.editar` | ✓ | | | | | | |
| `usuarios.gestionar` (aal2) | **✓** | | | | | | |
| `usuarios.leer_minimo` | ✓ | | | | | ✓ | |
| `auditoria.leer` | | | | | | **✓** | |

"propias" = filas de su entidad según la matriz de responsabilidades. "zona" = comunas o barrios de su perfil.

**En el SQL** (`…08_permisos_y_rls.sql`) cada permiso es binario. Por eso la lectura agregada de `consulta` se llama `operativo.leer_agregado`, y "editar parámetros" de `gestion_riesgo` se llama `parametros.editar`, aparte de `catalogos.editar` (DATIC). Las funciones para editar catálogos, protocolo y entidades **no existen todavía**: por ahora esos cambios se hacen con migraciones.

## 3. Cuentas de demostración (13, ficticias)

**Creadas el 4 de octubre de 2026 en Supabase `dev`** con `db/scripts/crear_usuarios_demo.mjs` (`npm run cuentas-demo`). Todas tienen `es_simulado = true`, correo `@example.org` (dominio reservado, nadie lo recibe) y alias institucional, no nombre de persona. Las contraseñas son aleatorias y quedan **solo** en el equipo del responsable de la BD: `~/.config/territorio-preparado/cuentas_demo_<ref>.csv`, con permisos 600. `superusuario` y `gestion_riesgo` deben inscribir un factor TOTP para decidir o gestionar usuarios.

Las cuentas comunitarias pertenecen a organizaciones **ficticias** (`JAC demo A (simulada)` en la comuna 06, `JAC demo B (simulada)` en la comuna 05 y `Conjunto residencial demo (simulado)` en el barrio 0610 Ciudadela Floralia). No se asocian a juntas reales del dataset, para no dar a entender que una junta real usa el sistema.

| # | Alias visible | Rol | Entidad / organización | Zona |
|---|---|---|---|---|
| 1 | Administración de plataforma (demo) | `superusuario` | Plataforma | |
| 2 | Secretaría de Gestión del Riesgo (demo) | `gestion_riesgo` | SGRED | Toda |
| 3 | Coordinación de respuesta (demo) | `gestion_riesgo` | SGRED | Toda |
| 4 | UAESP, saneamiento (demo) | `entidad_responsable` | UAESP | Toda |
| 5 | EMCALI, agua y energía (demo) | `entidad_responsable` | EMCALI | Toda |
| 6 | Salud Pública (demo) | `entidad_responsable` | Secretaría de Salud Pública | Toda |
| 7 | Bienestar Social (demo) | `entidad_responsable` | Secretaría de Bienestar Social | Toda |
| 8 | DATIC soporte técnico (demo) | `datic_tecnico` | DATIC | |
| 9 | Junta de acción comunal A (demo) | `comunitario` | JAC demo A (simulada) | Comuna 06 |
| 10 | Junta de acción comunal B (demo) | `comunitario` | JAC demo B (simulada) | Comuna 05 |
| 11 | Administración de conjunto residencial (demo) | `comunitario` | Conjunto residencial demo (simulado) | Barrio 0610 |
| 12 | Control y auditoría (demo) | `auditor` | | |
| 13 | Jurado y aliados (demo) | `consulta` | | |

Correos: `plataforma`, `sgred`, `coordinacion`, `uaesp`, `emcali`, `salud`, `bienestar`, `datic`, `jac-a`, `jac-b`, `conjunto`, `auditoria` y `jurado`, cada uno seguido de `.demo@example.org`.

## 4. Operaciones de cuentas (solo `superusuario`, con `aal2`, todas auditadas)

- **Crear usuario:** lo hace el **servidor** con la Admin API de Supabase (la clave `service_role` vive solo en el backend o en Vercel, jamás en el navegador). La base aporta `idn.provisionar_perfil` (ejecutable solo por `service_role`).
- **Cambiar rol, suspender, traspasar cargo:** `api.cambiar_rol`, `api.suspender_usuario`, `api.traspasar_cargo`. El traspaso cierra la asignación vigente del cargo y abre otra, sin tocar el historial.
- **Quién vigila al superusuario:** el `auditor` ve cada una de estas operaciones en `aud.eventos`.

## 5. Preguntas abiertas

1. ¿`entidad_responsable` valida mediciones de su servicio, o solo `gestion_riesgo`? (la tabla supone que sí, limitado a su servicio)
2. ¿`consulta` ve brechas y decisiones agregadas, o solo los datos abiertos? (supone que ve agregados)
3. ¿Hace falta un rol de **Consejo Municipal de Gestión del Riesgo** que apruebe la decisión (doble control), o basta el acto administrativo citado?
