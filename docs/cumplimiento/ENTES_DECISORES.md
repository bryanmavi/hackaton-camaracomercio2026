# Entes que deciden y ejecutan ante una emergencia en Cali

> **Para qué sirve:** dejar claro quién decide, quién ejecuta y quién apoya, para que la base de datos (`ref.entidades`, `ref.responsabilidades`, `idn.cargos`, `ops.decisiones_activacion`) modele la realidad institucional y no la de un gobierno de turno.
> **Cómo leer las marcas:** 📜 texto oficial leído; 📁 documento del repo; 🧠 sin verificar. Detalle en [`FUENTES.md`](FUENTES.md). Todo lo que no tenga 📜 es una **propuesta que debe validar la Secretaría de Gestión del Riesgo**.

## 1. Quién decide (lo que dice la ley)

| Instancia | Qué le toca | Fuente |
|---|---|---|
| **Alcalde** | Representa al Sistema Nacional en el municipio y es **responsable directo** de implementar los procesos de gestión del riesgo, incluido el **manejo de desastres** (art. 14). Es conductor del sistema en su nivel territorial (art. 12) | Ley 1523 de 2012 📜 |
| **Consejo Municipal de Gestión del Riesgo de Desastres** | Instancia de **coordinación, asesoría, planeación y seguimiento** (art. 27). Lo preside el alcalde o su delegado. Lo integran: la dependencia de gestión del riesgo, las entidades de servicios públicos, la corporación autónoma regional, la Defensa Civil, la Cruz Roja, el cuerpo de bomberos, un secretario de despacho, el comandante de Policía, y **representantes del sector privado y comunitario** (art. 28) | Ley 1523 📜 |
| **Dependencia de gestión del riesgo** | En municipios de más de 250.000 habitantes **debe existir** una dependencia o entidad de gestión del riesgo, que facilita la labor del alcalde, coordina el consejo y la continuidad de los procesos (art. 29, par. 1). En Cali es la **Secretaría de Gestión del Riesgo de Emergencias y Desastres** (SGRED), owner del RETO-01 | Ley 1523 📜; ficha del reto 📁 |
| **Declaratoria de calamidad pública** | La declara el alcalde, **previo concepto favorable del consejo municipal** (art. 57). La definición está en el art. 58 | Ley 1523 📜 |
| **Declaratoria de desastre nacional** | El Presidente, por decreto, previa recomendación del Consejo Nacional (art. 56) | Ley 1523 📜 |

### Lo que la ley **no** dice, y hay que validar

La Ley 1523 no habla de "activar albergues". Que **la Secretaría de Gestión del Riesgo determine qué albergues activar y de ahí se despliegue el protocolo** viene de la ficha del reto y de `docs/propuesta_cali_activa.md` ("la decisión final es de la Secretaría de Gestión del Riesgo") 📁. Hay que confirmarlo en el decreto de estructura de la Secretaría, en el Plan Municipal de Gestión del Riesgo y en la Estrategia Municipal de Respuesta de Cali (no se leyeron todavía). Por eso la base registra **el acto administrativo** que respalda cada decisión (`acto_tipo`, `acto_numero`, `acto_fecha`) y no presume quién lo firmó.

## 2. Cómo se despliega el protocolo (propuesta)

```
Alerta oficial (IDEAM, CVC, SGC u otra autoridad)         ← el sistema no emite alertas
        │
        ▼
SGRED y Consejo Municipal evalúan la situación
        │   (opcional) el sistema ofrece una recomendación explicable
        ▼
DECISIÓN de activar un espacio y su función  ──►  acto administrativo registrado
        │
        ▼
Se instancian las brechas y las tareas del protocolo
        │   cada servicio va a su entidad según la matriz de responsabilidades
        ▼
Entidades ejecutan y actualizan su estado   ◄──  red comunitaria reporta (solo su zona)
        │
        ▼
Retorno del espacio a su uso: checklist y acta de entrega
```

## 3. Entidades y su papel en el protocolo (propuesta, sin validar)

La lista sale de la ficha del RETO-01 📁 y de la composición del consejo (Ley 1523 art. 28 📜). La columna "Papel" es **propuesta del equipo**: ninguna fila está validada institucionalmente.

| Entidad | Papel propuesto | Origen en las fuentes |
|---|---|---|
| Alcaldía de Santiago de Cali (alcalde) | Responsable legal del manejo de desastres; declara la calamidad pública con el consejo | Ley 1523 arts. 14 y 57 📜 |
| Consejo Municipal de Gestión del Riesgo | Asesora y coordina; concepto previo para la calamidad pública | Ley 1523 arts. 27, 28 y 57 📜 |
| **Secretaría de Gestión del Riesgo de Emergencias y Desastres** | **Decide la activación de espacios y dispara el protocolo**; valida mediciones; cierra retornos | Ficha 📁, `propuesta_cali_activa.md` 📁, Ley 1523 art. 29 📜 |
| DATIC | Líder técnico del reto; soporte de la plataforma y calidad de datos | Ficha 📁 |
| Secretaría de Salud Pública | Define y opera el punto de salud; vigilancia en salud | Ficha 📁, `propuesta_cali_activa.md` 📁 |
| Secretaría de Bienestar Social | Atención social, ruta de niños, niñas y adolescentes, adultos mayores | Ficha 📁 |
| Secretaría de Educación | Sedes educativas como espacios o apoyo; retorno a clases | Ficha 📁 |
| Secretaría del Deporte y la Recreación | Escenarios deportivos: disponibilidad y retorno | Ficha 📁 |
| Secretaría de Infraestructura | Adecuaciones permanentes y obras (con licencia) | Ficha 📁 |
| Secretaría de Seguridad y Justicia | Seguridad del espacio y el entorno | Ficha 📁 |
| Planeación (DAPM) | Datos del territorio (IDESC) y uso del espacio público | Ficha 📁; datasets 📁 |
| UAE de Gestión de Bienes y Servicios | Administración de bienes públicos | Ficha 📁 |
| EMCALI | Agua y energía | Ficha 📁, `site.ts` 📁 |
| UAESP | Saneamiento (baños) y servicios públicos | Ficha 📁, `site.ts` 📁 (confirmar competencia en Cali) |
| Bomberos (comandante en el consejo) | Concepto de seguridad humana y contra incendios; **el sistema no lo emite** | Ley 1523 art. 28 📜; Ley 1575 de 2012 🧠 |
| Defensa Civil, Cruz Roja Colombiana | Apoyo operativo y humanitario; integran el consejo | Ley 1523 art. 28 📜 |
| Policía Nacional (comandante) | Seguridad y orden público; integra el consejo | Ley 1523 art. 28 📜 |
| Corporación Autónoma Regional (CVC) y autoridad ambiental urbana | Datos del río Cauca, caudales y alertas hidrológicas; integra el consejo | Ley 1523 art. 28 📜; CVC como autoridad en la jurisdicción 🧠 |
| UNGRD (nivel nacional) | Protocolo de alojamientos temporales y Registro Único de Damnificados | Bitácora 📁 (documento exacto por confirmar) |
| Gobernación del Valle y su consejo departamental | Apoyo departamental | Ley 1523 art. 27 📜 |
| ICBF, Defensoría del Pueblo, Personería | Aparecen en la investigación del equipo (atención de niños, vigilancia de derechos); competencia por verificar | `docs/PROYECTO.md` §5 📁 |

## 4. Quiénes **no** son el centro del diseño: los gobiernos de turno

Los alcaldes y sus equipos cambian cada cuatro años; la gestión del riesgo no puede reiniciarse con ellos. El diseño se ancla en **cargos, dependencias y comunidad**:

- Los permisos pertenecen al **cargo** (`idn.cargos`), no a la persona; el traspaso es una operación del superusuario que cierra una asignación y abre otra (`idn.asignaciones_cargo`).
- Las entidades tienen **vigencia y sucesora** (`ref.entidades.vigente_desde`, `vigente_hasta`, `sucesora_id`): cuando una secretaría cambia de nombre o se fusiona, no se pierde su historia.
- Las decisiones, brechas y retornos son **memoria institucional permanente** y no se borran al cambiar de administración.
- La **red comunitaria** (juntas de acción comunal, administradores de conjuntos) es la capa estable del territorio: ver [`RED_COMUNITARIA.md`](RED_COMUNITARIA.md).
- Los datos se exportan en formatos abiertos (SQL, CSV, GeoJSON) para que la siguiente administración o un aliado pueda continuar sin depender del equipo ni del proveedor.

## 5. Pendientes de verificación

1. Decreto de estructura de la Secretaría de Gestión del Riesgo de Cali, y si el consejo municipal tiene reglamento propio.
2. Plan Municipal de Gestión del Riesgo y Estrategia Municipal de Respuesta de Cali: ¿quién activa los alojamientos temporales y con qué acto?
3. Documento exacto, versión vigente y autor del "Protocolo de Alojamientos Temporales" que cita la bitácora.
4. Competencia real de la UAESP en Cali para saneamiento en albergues.
5. Mecanismo oficial (derecho de petición, Leyes 1712 y 1755, 🧠) para pedir esa información a la Secretaría: está en los pendientes de `docs/PROYECTO.md` §7.
6. Nada de esto se marca como validado hasta tener una **ronda real** con la Secretaría o una junta (pendiente del IRL 3 en la bitácora); no se inventan conversaciones.
