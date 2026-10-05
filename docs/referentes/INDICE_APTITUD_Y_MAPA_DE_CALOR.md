# Índice de aptitud y mapa de calor de espacios públicos (diseño, fase 2)

> **Estado:** diseño. No hay SQL ni código todavía. Se prepara la base de datos para recibirlo (`DICCIONARIO.md`, "Fase 2").
> **Marcas:** 📜 texto oficial leído; 📁 archivo del repo; 🔎 resumen de búsqueda; 🧠 sin verificar ([`../cumplimiento/FUENTES.md`](../cumplimiento/FUENTES.md)).

## 1. Qué es y qué no es

**Es** una forma de ordenar los espacios públicos de toda la ciudad (2.991 hoy 📁) según su **aptitud relativa** para una función (punto de reunión inmediato o albergue) ante una amenaza (sismo o inundación primero), y de mostrarlo como mapa de calor.
**No es** una declaración de que un espacio sea "seguro". Razones:
- No reemplaza la evaluación estructural ni emite conceptos (NSR-10 y Ley 400 de 1997 🧠).
- La decisión de activar un espacio es de la autoridad (Ley 1523 arts. 14 y 57 📜).
- Las propias capas advierten que **"sin cruce no significa ausencia de amenaza"** y que no se evaluaron remoción en masa, incendio, sequía ni todos los riesgos sísmicos (`manifest.json` 📁).
- Cada puntaje debe poder explicarse (Circular SIC 002 de 2024 🔎): el sistema recomienda con reglas visibles.

Por eso el texto en pantalla dice **"aptitud preliminar para revisión"**, nunca "zona segura".

## 2. Alcance

| Eje | Primera versión | Después |
|---|---|---|
| Espacios | Los 2.991 espacios públicos (EPOU y escenarios deportivos) | Otros equipamientos con permiso de la entidad |
| Amenazas | Sismo e inundación | Incendio (cuando haya cartografía verificada), sequía y remoción en masa |
| Funciones | Punto de reunión inmediato y albergue | Acopio, punto de agua y de salud |
| Unidad del mapa | **Barrio (342) y comuna (22)**, que ya existen 📁 | Celdas hexagonales |

## 3. Método (análisis multicriterio con SIG)

La literatura usa análisis multicriterio en un SIG para escoger albergues (🔎): criterios como **distancia a la falla, densidad de población, acceso a espacios verdes y calidad de los edificios** (sismo) y **pendiente, elevación, uso del suelo, vías, distancia al agua y a la electricidad**; el marco **COSI-SAFE** agrupa la aptitud en **calidad, capacidad y accesibilidad**. Un estudio de la Gran Victoria halló que los espacios abiertos no coinciden con la distribución de la población.

Pasos:
1. **Exclusiones duras** (las que el motor de reglas ya aplica en `planning.ts`): un espacio que cruza amenaza alta o no mitigable de inundación no es candidato a albergue por inundación. Quedan fuera del puntaje, con su razón.
2. **Criterios blandos** normalizados de 0 a 1 (más alto, mejor) según su dirección.
3. **Pesos publicados**: ponderación por grupo (calidad, capacidad, accesibilidad), sumando 100. **El punto de partida son pesos iguales dentro de cada grupo; no invento valores.** Los ajustan expertos.
4. **Puntaje de 0 a 100** por espacio, amenaza y función, con los **componentes visibles** (cada criterio con su valor, peso y aporte).
5. **Agregación** por barrio y comuna (promedio y número de espacios), para el mapa de calor.
6. **Sensibilidad:** mover cada peso un 20 % y medir cuánto cambia el orden; los espacios cuyo puesto cambia mucho se marcan "inestables".
7. **Validación:** comparar con casos reales sin usar los mismos datos como criterio. Los daños del sismo del 10 de agosto de 2026 pueden ser criterio **o** validación, no ambos; se propone dejar la mitad de los puntos de daño fuera del cálculo y comprobar que los espacios de mayor aptitud no tuvieron daños graves cerca.

## 4. Criterios propuestos y datos

Grupo, criterio, amenaza, dirección, dato en el repo y si falta.

| Grupo | Criterio | Amenaza | Mejor si… | Dato | ¿Disponible? |
|---|---|---|---|---|---|
| Calidad | Cruce con inundación fluvial y pluvial | Inundación | no cruza o es baja | `inund_fluvial`, `inund_pluvial` 📁 | Sí |
| Calidad | Distancia al dique del río Cauca | Inundación | es mayor | `dist_dique_cauca_m` 📁 | Sí |
| Calidad | Zona del río Cauca | Inundación | no está | `zona_inund_rio_cauca` 📁 | Sí |
| Calidad | Microzonificación sísmica (zona y `Aa`) | Sismo | amplificación menor | `micro_sismica_zona`, `micro_sismica_Aa` 📁 | Sí |
| Calidad | Licuación y corrimiento lateral | Sismo | no hay | `licuacion`, `corrimiento_lateral` 📁 | Sí |
| Calidad | Daños del sismo en 500 m | Sismo | son menores | `danos_sismo_500m`, `danos_graves_500m` 📁 | Sí (ver validación) |
| Calidad | Pendiente y elevación | Ambas | es adecuada | Modelo digital del terreno | **No** |
| Capacidad | Área de la huella | Ambas | es mayor | `area_m2` 📁 (no equivale a superficie útil ni aforo) | Sí |
| Capacidad | Déficit de espacio por habitante en la comuna | Ambas | hay déficit (más necesidad) | `ep_m2_por_hab` 📁 | Sí |
| Capacidad | Agua y energía en el sitio | Albergue | existen | Mediciones del espacio | **No (hoy desconocidas)** |
| Accesibilidad | Distancia a IPS | Ambas | es menor | `dist_ips_m` 📁 | Sí |
| Accesibilidad | Distancia a organismos de socorro | Ambas | es menor | `dist_socorro_m` 📁 | Sí |
| Accesibilidad | Vías y accesos | Ambas | hay | Red vial (OpenStreetMap) | **No** |
| Accesibilidad | Densidad de población cercana | Reunión inmediata | es mayor (más gente a quien servir) | Población por comuna 📁; fina: falta | Parcial |

**Faltan:** pendiente y elevación (modelo digital del terreno), red vial, densidad de población más fina, y agua y energía de cada espacio. Fuentes a explorar (🧠, por verificar): modelos digitales de elevación abiertos, OpenStreetMap y el censo del DANE. **Los valores desconocidos no entran como cero**: el criterio se omite para ese espacio y se muestra el puntaje con "datos incompletos".

## 5. Cómo se ve

- Mapa de calor por barrio y comuna, con leyenda de **aptitud relativa** (no de seguridad), paleta apta para daltonismo y contraste suficiente (Resolución MinTIC 1519 de 2020 🧠).
- Al pasar por un barrio: puntaje, número de espacios, componentes y los datos que faltan.
- Aviso permanente: "Preliminar. No sustituye evaluación estructural ni la decisión de la autoridad."
- Dos mapas por amenaza y función: reunión inmediata y albergue.

## 6. Límites legales y éticos

| Riesgo | Control |
|---|---|
| Que se lea como "zona segura" y se use sin evaluación | Texto fijo, componentes visibles y bloqueo de la palabra "seguro" en la interfaz |
| Efecto sobre el valor de los predios o las expectativas | Coordinar el lenguaje y el momento de publicación con la Secretaría y Planeación antes de publicar |
| Decisión automática | Ley 1523 📜: el sistema ordena y la autoridad decide; el puntaje no activa nada |
| Explicabilidad | Criterios, pesos y versión guardados; cada puntaje reproducible (Circular SIC 002 de 2024 🔎) |
| Licencias | Las capas son CC BY y CC BY-SA 📁; el índice es obra derivada: **atribuir y compartir igual** |
| Sesgo por datos incompletos | Mostrar la cobertura de datos; no ordenar por encima de lo que se sabe |
| Datos personales | Ninguno: son capas geográficas y conteos por comuna |

## 7. Piezas en la base de datos

Tablas previstas (`DICCIONARIO.md`, "Fase 2"): `ref.criterios_aptitud`, `geo.indice_aptitud` y `geo.mapa_calor_celdas`. El cálculo es un **script reproducible** versionado (Python puro, como los de `prototipo/scripts/`), que lee los criterios, escribe los puntajes y registra la versión. Los resultados se publican como dato abierto derivado, con su `sha256`.

## 8. Decisiones y pasos

**Decisiones tuyas:**
1. Orden de amenazas (propuesta: sismo e inundación primero).
2. Quién valida los pesos (propuesta: Servicio Geológico Colombiano, universidades y la Secretaría).
3. Si el mapa se publica o queda interno hasta validarlo (propuesta: interno hasta validar).

**Pasos (cuando se apruebe):** conseguir el modelo digital del terreno y la red vial; definir los pesos con expertos; implementar el script; probar la sensibilidad y la validación; revisar el lenguaje con la Secretaría; publicar.
