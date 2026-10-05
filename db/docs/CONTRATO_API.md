# Contrato de la API (borrador, Hito 1)

> Lo único que el frontend y el backend pueden usar es el esquema **`api`**. En Supabase hay que configurar **Exposed schemas = `api`** (y quitar `public`). Cliente: `supabase.schema('api').from('espacios')…` y `supabase.schema('api').rpc('…', {…})`.
> Los códigos (`flood`, `toilets`, `albergue`…) son los mismos de la app. `null` significa **desconocido**, nunca cero.

## Vistas públicas (`anon` y `authenticated`)

| Vista | Para qué |
|---|---|
| `espacios` | Los espacios con `lon` y `lat`, sin geometría pesada |
| `espacio_huellas` | La huella GeoJSON de cada espacio EPOU (pedir solo las necesarias) |
| `espacio_ficha` | La ficha completa (solo mediciones **reales**; nunca las simuladas de las cuentas demo): fuente + última medición **verificada** + cruces de amenaza (`cruce_inundacion_fluvial`…). `disponibilidad` vale "Por confirmar con la entidad responsable" si no hay dato |
| `espacio_exposicion` | Cruces espacio × zona de amenaza. Sin cruce no significa sin amenaza |
| `mediciones_verificadas` | Última medición **verificada** por espacio y atributo, con `es_simulado`. El mapa de la app solo usa las reales |
| `comunas`, `barrios`, `zonas_amenaza` | Con `geometria` en GeoJSON |
| `amenazas`, `servicios`, `funciones_espacio`, `parametros_reglas` | Catálogos. `parametros_reglas` reemplaza las constantes de `planningRules` |
| `entidades`, `responsabilidades` | Matriz de responsabilidades, marcada `propuesta` |
| `fuentes` | Licencia, atribución, fecha de corte y `sha256` de cada dataset |

## Vistas con sesión (`authenticated`; la RLS filtra por rol)

| Vista | Quién ve qué |
|---|---|
| `mi_perfil` | El propio perfil, con `permisos` (lista) y `aal2` (si la sesión tiene MFA). Úsala para mostrar u ocultar botones |
| `decisiones` | `gestion_riesgo` y `auditor`: todas. Entidad: donde tiene brechas o tareas. Comunitario: las vigentes de su zona |
| `brechas` | `gestion_riesgo` y `auditor`: todas. Entidad: las suyas. Incluye `bloquea_activacion` |
| `mediciones_pendientes` | Mediciones declaradas sin verificar, según el alcance. Trae `propia` (cuatro ojos) y `puedo_validar`, que sirven para mostrar u ocultar botones; quien autoriza es `validar_medicion` |
| `mis_tareas` | Tareas del protocolo de la propia entidad (o todas para `gestion_riesgo` y `auditor`) |
| `reportes_comunitarios` | Comunitario: los de su organización y su zona. `gestion_riesgo` y `auditor`: todos |
| `resumen_territorial` | Agregados por comuna; los conteos operativos menores al umbral salen `null` |
| `usuarios_minimo` | `superusuario` y `auditor` |
| `auditoria` | Solo `auditor` |

## Funciones (RPC, `authenticated`)

Todas verifican permiso, alcance y, cuando aplica, MFA. Errores: `42501` sin permiso o fuera de alcance, `23514` regla de datos violada, `23001` registro cerrado o inmutable.

| Función | Permiso | Notas |
|---|---|---|
| `registrar_recomendacion(p_amenaza, p_personas, p_origen_espacio, p_ambito, p_version_reglas, p_candidatos, p_resumen_cribado, p_advertencias?, p_simulado?)` | `recomendacion.crear` | Guarda la salida de `compareCandidates()`. `p_candidatos`: hasta 3 objetos `{id, distancia_m, razon}`. Inmutable |
| `registrar_decision_activacion(p_recomendacion, p_espacio, p_amenaza, p_funcion, p_acto_tipo, p_acto_numero, p_acto_fecha, p_justificacion?, p_personas_estimadas?, p_requerimientos?, p_version_reglas?)` | `decision.activar` + **aal2** | Exige justificación si no hay recomendación o si el espacio no estaba entre los candidatos. `p_requerimientos`: `[{"servicio":"toilets","requerido":8}…]` desde `requirements()`. Crea brechas (con el existente **verificado**) y las tareas del protocolo |
| `actualizar_brecha(p_brecha, p_estado?, p_existente?, p_nota?)` | `brecha.actualizar` | Solo avanza: `por_medir → en_revision → asignada → en_ejecucion → cerrada`. Deja un seguimiento |
| `completar_tarea(p_tarea, p_estado?, p_nota?)` | `tarea.completar` | `en_curso`, `completada` o `no_aplica` |
| `crear_reporte_comunitario(p_tipo, p_espacio_id?, p_n_total?, p_n_0_5?, p_n_6_17?, p_n_18_59?, p_n_60_mas?, p_n_discapacidad?, p_n_animales_compania?, p_estado_servicios?, p_observacion?)` | `reporte.crear` | Solo conteos. Los grupos deben sumar el total. Solo espacios de su zona |
| `registrar_medicion(p_espacio_id, p_atributo, p_fuente_texto, p_valor_num?, p_valor_bool?, p_valor_texto?, p_valor_fecha?, p_unidad?, p_evidencia_ref?)` | `medicion.declarar` | Queda `declarado` |
| `validar_medicion(p_id, p_aceptar, p_evidencia_ref?)` | `medicion.validar` | Cuatro ojos; verificar exige evidencia; la entidad solo valida los atributos de sus servicios |
| `cerrar_retorno(p_decision, p_checklist, p_acta_ref, p_fecha_retorno, p_cargos_firmantes?)` | `retorno.cerrar` | Pasa la decisión a `cerrada`; después no se tocan sus brechas ni sus tareas |
| `cambiar_rol`, `suspender_usuario`, `traspasar_cargo` | `usuarios.gestionar` + **aal2** | Nadie se cambia ni se suspende a sí mismo. El traspaso deja al saliente en `consulta` |
| `verificar_auditoria()` | `auditoria.leer` | Recorre la cadena de hash |

**Solo servidor** (clave `service_role`, nunca en el navegador): `api.provisionar_perfil(p_user, p_rol, p_alias, p_entidad_codigo?, p_organizacion_id?, p_zona_comunas?, p_zona_barrios?, p_cargo_nombre?, p_simulado?)`, después de crear el usuario con la Admin API de Supabase, y `api.asegurar_organizacion(p_tipo, p_nombre, p_comuna?, p_barrio?, p_simulado?)`. Las dos son idempotentes. Para suprimir un titular: `idn.anonimizar_perfil(user_id)` por conexión directa. **Hook de Auth:** `idn.custom_access_token_hook`, que se configura en Authentication → Hooks.

## Cómo la consume la app (`maqueta3d`)

- `src/territoryApi.ts` arma, desde `api`, **el mismo** objeto `Territory` que antes salía de los JSON estáticos. Está probado campo por campo: `npm run test:paridad` en `db/` (PGlite) y `scripts/paridad-supabase.mjs` en `maqueta3d/` (Supabase real).
- **Paginación:** Supabase devuelve como máximo 1.000 filas por respuesta. La primera página trae el total (`count=exact`) y las demás se piden **en paralelo**. Se pagina con un orden **único** (`orden_fuente`; `zona_id,espacio_id`; `espacio_id,atributo`). Con un orden repetido, las páginas duplican o saltan filas: ese error ya apareció y quedó corregido.
- **Orden:** `espacios`, `comunas` y `barrios` traen `orden_fuente`, la posición en el archivo de la IDESC, para que listas y mapa salgan en el mismo orden de siempre.
- **Precisión:** la API serializa los decimales con 15 cifras. Las coordenadas del punto representativo difieren de los JSON en menos de 10⁻¹³ grados.
- **Respaldo:** sin variables de entorno, o si la base no responde, la app usa los JSON y lo dice en el encabezado.

## Rendimiento medido en Supabase real (4 de octubre)

| Versión | Carga completa del territorio |
|---|---|
| Primera conexión (páginas en serie, cruces calculados en vivo) | ≈ 8,5 s |
| Cruces precalculados (migración 16) y páginas en paralelo | **1,3 a 1,8 s** (Node y navegador) |

Los cruces de `api.espacio_exposicion` salen de `geo.exposicion_cache`, una vista materializada. La carga de datos la refresca en la misma transacción, y una prueba comprueba que es idéntica al cálculo en vivo.

## Rendimiento medido (PGlite, con los datos reales)

Una ficha tarda 2 ms; `espacios` (2.991 filas), 36 ms; `zonas_amenaza` con GeoJSON, 76 ms; `espacio_ficha` completa, alrededor de 1 s; `resumen_territorial`, alrededor de 0,8 s. Para listas y mapas usa `espacios`; pide `espacio_ficha` por `id`.

## Lo que falta para conectar la app

1. Correr la carga de datos reales en el proyecto de Supabase (`npm run cargar`; el script ya está probado, ver `db/README.md`).
2. Cambiar en la app la lectura de JSON estáticos por estas vistas, conservando los JSON como respaldo público.
3. ~~Crear las 13 cuentas de demostración (H5)~~: hecho. Falta la pantalla de inicio de sesión y la de inscripción del factor TOTP (`supabase.auth.mfa.enroll`, `challenge` y `verify`) para `gestion_riesgo` y `superusuario`.
