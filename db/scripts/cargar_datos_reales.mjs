// Carga los datos abiertos reales de Cali en la base (Hito 2).
//
// Qué hace, en UNA transacción (todo o nada) y de forma idempotente (se puede repetir):
//   1. Verifica el sha256 de los archivos crudos de la IDESC contra maqueta3d/public/data/manifest.json.
//      Si una huella no coincide, aborta sin tocar la base.
//   2. Registra cada conjunto de datos en ref.fuentes (licencia, atribución, fecha de corte, sha256, conteo).
//   3. Carga comunas, barrios y espacios (upsert), reemplaza las zonas de amenaza y hace upsert de las JAC.
//   4. Comprueba dos conteos: los archivos crudos contra el manifiesto (integridad de la fuente) y lo cargado
//      contra las capas que usa la app. Si algo no cuadra, deshace todo.
// Las zonas de amenaza son las capas DERIVADAS de la app (maqueta3d/scripts/build-territory.mjs): de los 16 polígonos
// crudos de microzonificación solo entran los 5 con susceptibilidad a licuación o corrimiento > 0. Así la base
// reproduce exactamente los cruces de la app; el filtro queda anotado en `atributos` de cada zona.
// No inventa datos: lo que la fuente no trae queda NULL (52 espacios sin comuna, 23 JAC con un barrio que no está en la capa).
//
// Uso contra Supabase o cualquier PostgreSQL (la URL vive SOLO en tu terminal, nunca en el repo):
//   cd db && DATABASE_URL='postgresql://…' node scripts/cargar_datos_reales.mjs
// Las pruebas (tests/carga.mjs) importan cargarDatosReales() y lo corren contra PGlite.

import { createHash } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const raiz = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const datosApp = join(raiz, 'maqueta3d', 'public', 'data');
const crudos = join(raiz, 'prototipo', 'datos', 'raw', 'idesc');

const leerJson = (ruta) => JSON.parse(readFileSync(ruta, 'utf8'));
const sha256 = (ruta) => createHash('sha256').update(readFileSync(ruta)).digest('hex');

// CSV con comillas dobles (prototipo/datos/fuentes.csv)
function leerCsv(ruta) {
  const filas = [];
  let fila = [], campo = '', comillas = false;
  const texto = readFileSync(ruta, 'utf8');
  for (let i = 0; i < texto.length; i++) {
    const c = texto[i];
    if (comillas) {
      if (c === '"' && texto[i + 1] === '"') { campo += '"'; i++; }
      else if (c === '"') comillas = false;
      else campo += c;
    } else if (c === '"') comillas = true;
    else if (c === ',') { fila.push(campo); campo = ''; }
    else if (c === '\n' || c === '\r') {
      if (c === '\r' && texto[i + 1] === '\n') i++;
      fila.push(campo); campo = '';
      if (fila.some((v) => v !== '')) filas.push(fila);
      fila = [];
    } else campo += c;
  }
  if (campo || fila.length) { fila.push(campo); filas.push(fila); }
  const [cabecera, ...resto] = filas;
  return resto.map((f) => Object.fromEntries(cabecera.map((k, i) => [k, f[i] ?? ''])));
}

const TIPO_AMENAZA = {
  fluvial: 'inundacion_fluvial', pluvial: 'inundacion_pluvial', nonMitigable: 'no_mitigable',
  liquefaction: 'licuacion', seismicEffects: 'efectos_sismicos',
};

/** Arma y verifica todo lo que se va a cargar, sin tocar la base. */
export function prepararCarga() {
  const manifiesto = leerJson(join(datosApp, 'manifest.json'));
  const catalogo = leerCsv(join(raiz, 'prototipo', 'datos', 'fuentes.csv'));
  const porArchivo = Object.fromEntries(catalogo.map((f) => [f.archivo, f]));

  const fuentes = manifiesto.sources.map((s) => {
    const archivo = `raw/idesc/${s.name}.geojson`;
    const real = sha256(join(crudos, `${s.name}.geojson`));
    if (real !== s.sha256) throw new Error(`sha256 distinto en ${archivo}: manifiesto ${s.sha256}, archivo ${real}`);
    const nCrudo = leerJson(join(crudos, `${s.name}.geojson`)).features.length;
    if (nCrudo !== s.count) throw new Error(`${archivo} trae ${nCrudo} registros y el manifiesto dice ${s.count}`);
    const cat = porArchivo[archivo];
    if (!cat) throw new Error(`${archivo} no está en prototipo/datos/fuentes.csv`);
    return {
      clave: s.key, nombre: cat.dataset, entidad: cat.entidad, pagina_fuente: s.page, url_descarga: s.download,
      licencia: s.license, atribucion: `${cat.entidad}, Alcaldía de Santiago de Cali · ${cat.dataset} (${s.license}), corte ${s.snapshotDate}`,
      fecha_corte: s.snapshotDate, sha256: s.sha256, n_registros: s.count,
    };
  });

  // JAC: no está en el manifiesto de la app; su huella se registra al cargar (no hay una previa contra la cual comparar).
  const archivoJac = 'raw/idesc/pfp_ivc_organismos_accion_comunal.geojson';
  const jacCat = porArchivo[archivoJac];
  const jac = leerJson(join(raiz, 'prototipo', 'datos', archivoJac));
  fuentes.push({
    clave: 'jac', nombre: jacCat.dataset, entidad: jacCat.entidad, pagina_fuente: jacCat.pagina_fuente,
    url_descarga: jacCat.url_descarga, licencia: jacCat.licencia,
    atribucion: `${jacCat.entidad}, Alcaldía de Santiago de Cali · ${jacCat.dataset} (${jacCat.licencia}), corte ${jacCat.fecha_descarga}`,
    fecha_corte: jacCat.fecha_descarga, sha256: sha256(join(raiz, 'prototipo', 'datos', archivoJac)), n_registros: jac.features.length,
  });

  const capas = {
    comunas: leerJson(join(datosApp, 'communes.json')).features,
    barrios: leerJson(join(datosApp, 'neighborhoods.json')).features,
    espacios: leerJson(join(datosApp, 'spaces.json')).features,
    zonas: [...leerJson(join(datosApp, 'flood.json')).features, ...leerJson(join(datosApp, 'seismic.json')).features],
    jac: jac.features,
  };
  for (const z of capas.zonas) {
    if (!TIPO_AMENAZA[z.properties.sourceKey]) throw new Error(`Capa de amenaza desconocida: ${z.properties.sourceKey}`);
  }
  // Lo que debe quedar en la base = lo que trae cada capa de la app (no el conteo crudo del manifiesto).
  const contar = (lista, clave) => lista.filter((f) => f.properties.sourceKey === clave).length;
  const esperado = {
    communes: capas.comunas.length, neighborhoods: capas.barrios.length,
    publicSpaces: contar(capas.espacios, 'publicSpaces'), sports: contar(capas.espacios, 'sports'),
    ...Object.fromEntries(Object.keys(TIPO_AMENAZA).map((k) => [k, contar(capas.zonas, k)])),
    jac: capas.jac.length,
  };
  return { fuentes, capas, esperado };
}

/** Carga en una conexión con `query(sql, params)` (pg.Client o PGlite). Devuelve un resumen. */
export async function cargarDatosReales(db, { registro = console.log } = {}) {
  const { fuentes, capas, esperado } = prepararCarga();
  registro(`Huellas sha256 y conteos verificados: ${fuentes.length - 1} archivos crudos coinciden con el manifiesto.`);
  const fc = (features) => JSON.stringify({ features });

  await db.query('begin');
  try {
    await db.query(`
      insert into ref.fuentes (clave, nombre, entidad, pagina_fuente, url_descarga, licencia, compartir_igual,
                               atribucion, fecha_corte, sha256, n_registros, es_simulado)
      select f.clave, f.nombre, f.entidad, f.pagina_fuente, f.url_descarga, f.licencia, f.licencia = 'CC BY-SA',
             f.atribucion, f.fecha_corte::date, f.sha256, f.n_registros, false
      from jsonb_to_recordset($1::jsonb) as f (clave text, nombre text, entidad text, pagina_fuente text, url_descarga text,
                                               licencia text, atribucion text, fecha_corte text, sha256 text, n_registros int)
      on conflict (clave) do update set
        nombre = excluded.nombre, entidad = excluded.entidad, pagina_fuente = excluded.pagina_fuente,
        url_descarga = excluded.url_descarga, licencia = excluded.licencia, compartir_igual = excluded.compartir_igual,
        atribucion = excluded.atribucion, fecha_corte = excluded.fecha_corte, sha256 = excluded.sha256,
        n_registros = excluded.n_registros`, [JSON.stringify(fuentes)]);

    await db.query(`
      insert into geo.comunas (codigo, nombre, geom, fuente_clave)
      select f -> 'properties' ->> 'code', f -> 'properties' ->> 'name',
             extensions.st_multi(extensions.st_setsrid(extensions.st_geomfromgeojson(f ->> 'geometry'), 4326)), 'communes'
      from jsonb_array_elements($1::jsonb -> 'features') f
      on conflict (codigo) do update set nombre = excluded.nombre, geom = excluded.geom, fuente_clave = excluded.fuente_clave`,
      [fc(capas.comunas)]);

    await db.query(`
      insert into geo.barrios (codigo, nombre, comuna_codigo, geom, fuente_clave)
      select f -> 'properties' ->> 'code', f -> 'properties' ->> 'name', f -> 'properties' ->> 'commune',
             extensions.st_multi(extensions.st_setsrid(extensions.st_geomfromgeojson(f ->> 'geometry'), 4326)), 'neighborhoods'
      from jsonb_array_elements($1::jsonb -> 'features') f
      on conflict (codigo) do update set nombre = excluded.nombre, comuna_codigo = excluded.comuna_codigo,
        geom = excluded.geom, fuente_clave = excluded.fuente_clave`, [fc(capas.barrios)]);

    // Espacios: upsert (las decisiones y mediciones los referencian, nunca se borran).
    // `estado_proteccion_uso` y `es_simulado` no se tocan en una recarga.
    await db.query(`
      insert into geo.espacios (id, fuente_clave, nombre, tipo, condicion, comuna_codigo, barrio_nombre, comuna_fuente,
                                barrio_fuente, limite_ambiguo, punto, huella, area_m2, metodo_evaluacion)
      select p ->> 'id', p ->> 'sourceKey', p ->> 'name', p ->> 'type', p ->> 'condition', p ->> 'commune',
             p ->> 'neighborhood', p ->> 'sourceCommune', p ->> 'sourceNeighborhood',
             coalesce((p ->> 'boundaryAmbiguous')::boolean, false),
             extensions.st_setsrid(extensions.st_point((p -> 'coordinates' ->> 0)::float8, (p -> 'coordinates' ->> 1)::float8), 4326),
             case when f -> 'geometry' ->> 'type' in ('Polygon', 'MultiPolygon')
                  then extensions.st_multi(extensions.st_setsrid(extensions.st_geomfromgeojson(f ->> 'geometry'), 4326)) end,
             (p ->> 'areaM2')::numeric, p ->> 'assessmentMethod'
      from jsonb_array_elements($1::jsonb -> 'features') f, lateral (select f -> 'properties' as p) x
      on conflict (id) do update set
        fuente_clave = excluded.fuente_clave, nombre = excluded.nombre, tipo = excluded.tipo, condicion = excluded.condicion,
        comuna_codigo = excluded.comuna_codigo, barrio_nombre = excluded.barrio_nombre, comuna_fuente = excluded.comuna_fuente,
        barrio_fuente = excluded.barrio_fuente, limite_ambiguo = excluded.limite_ambiguo, punto = excluded.punto,
        huella = excluded.huella, area_m2 = excluded.area_m2, metodo_evaluacion = excluded.metodo_evaluacion`,
      [fc(capas.espacios)]);

    // Zonas de amenaza: nada las referencia (la exposición es una vista), así que se reemplazan.
    await db.query(`delete from geo.zonas_amenaza where fuente_clave = any ($1::text[])`, [Object.keys(TIPO_AMENAZA)]);
    await db.query(`
      insert into geo.zonas_amenaza (fuente_clave, amenaza_tipo, etiqueta, atributos, geom)
      select f -> 'properties' ->> 'sourceKey', ($2::jsonb) ->> (f -> 'properties' ->> 'sourceKey'),
             f -> 'properties' ->> 'label',
             case when f -> 'properties' ->> 'sourceKey' = 'liquefaction'
                  then '{"derivada_de":"maqueta3d/scripts/build-territory.mjs","filtro":"sucep_licu > 0 o corrim_lat > 0"}'::jsonb
                  else '{"derivada_de":"maqueta3d/scripts/build-territory.mjs"}'::jsonb end,
             extensions.st_multi(extensions.st_setsrid(extensions.st_geomfromgeojson(f ->> 'geometry'), 4326))
      from jsonb_array_elements($1::jsonb -> 'features') f`, [fc(capas.zonas), JSON.stringify(TIPO_AMENAZA)]);

    // JAC: organizaciones, no personas. El barrio se asigna solo si el código existe en la capa de barrios.
    await db.query(`
      insert into geo.organizaciones_comunitarias (tipo, nombre, comuna_codigo, barrio_codigo, direccion_publica,
                                                   fuente_clave, id_fuente, activa, es_simulado)
      select 'jac', p ->> 'oacnombre',
             (select c.codigo from geo.comunas c where c.codigo = lpad(p ->> 'oacidcomuna', 2, '0')),
             (select b.codigo from geo.barrios b where b.codigo = p ->> 'oacidbarrio'),
             nullif(btrim(p ->> 'oacdirecc'), ''), 'jac', p ->> 'oacid', true, false
      from jsonb_array_elements($1::jsonb -> 'features') f, lateral (select f -> 'properties' as p) x
      on conflict (fuente_clave, id_fuente) where id_fuente is not null do update set
        nombre = excluded.nombre, comuna_codigo = excluded.comuna_codigo, barrio_codigo = excluded.barrio_codigo,
        direccion_publica = excluded.direccion_publica`, [fc(capas.jac)]);

    // Conteos contra el manifiesto: si no cuadran, se deshace todo.
    const { rows: [c] } = await db.query(`
      select (select count(*) from geo.comunas)::int as communes,
             (select count(*) from geo.barrios)::int as neighborhoods,
             (select count(*) from geo.espacios where fuente_clave = 'publicSpaces')::int as "publicSpaces",
             (select count(*) from geo.espacios where fuente_clave = 'sports')::int as sports,
             (select count(*) from geo.zonas_amenaza where fuente_clave = 'fluvial')::int as fluvial,
             (select count(*) from geo.zonas_amenaza where fuente_clave = 'pluvial')::int as pluvial,
             (select count(*) from geo.zonas_amenaza where fuente_clave = 'nonMitigable')::int as "nonMitigable",
             (select count(*) from geo.zonas_amenaza where fuente_clave = 'liquefaction')::int as liquefaction,
             (select count(*) from geo.zonas_amenaza where fuente_clave = 'seismicEffects')::int as "seismicEffects",
             (select count(*) from geo.organizaciones_comunitarias where fuente_clave = 'jac')::int as jac,
             (select count(*) from geo.espacios where comuna_codigo is null)::int as espacios_sin_comuna,
             (select count(*) from geo.organizaciones_comunitarias where fuente_clave = 'jac' and barrio_codigo is null)::int as jac_sin_barrio,
             (select count(*) from geo.espacios where huella is not null and not extensions.st_isvalid(huella))::int as huellas_invalidas,
             (select count(*) from geo.zonas_amenaza where not extensions.st_isvalid(geom))::int as zonas_invalidas`);
    const descuadres = Object.entries(esperado).filter(([k, v]) => c[k] !== v);
    if (descuadres.length) {
      throw new Error('Conteos cargados distintos a las capas de la app: ' + descuadres.map(([k, v]) => `${k} esperado ${v}, cargado ${c[k]}`).join('; '));
    }
    await db.query('commit');
    registro(`Cargado: ${c.communes} comunas, ${c.neighborhoods} barrios, ${c.publicSpaces + c.sports} espacios ` +
      `(${c.publicSpaces} EPOU + ${c.sports} deportivos), ${c.fluvial + c.pluvial + c.nonMitigable + c.liquefaction + c.seismicEffects} ` +
      `zonas de amenaza y ${c.jac} JAC.`);
    registro(`Sin inventar: ${c.espacios_sin_comuna} espacios sin comuna y ${c.jac_sin_barrio} JAC sin barrio en la capa quedan NULL. ` +
      `Geometrías no válidas según GEOS: ${c.huellas_invalidas} huellas y ${c.zonas_invalidas} zonas (se cargan tal como vienen).`);
    return c;
  } catch (e) {
    await db.query('rollback');
    throw e;
  }
}

// Ejecución directa: node scripts/cargar_datos_reales.mjs (con DATABASE_URL en el entorno)
if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  if (!process.env.DATABASE_URL) {
    console.error('Falta DATABASE_URL (defínela solo en tu terminal; nunca la guardes en el repo).');
    process.exit(1);
  }
  const { default: pg } = await import('pg');
  // TLS según la URL (Supabase: añade ?sslmode=require). No se desactiva la verificación del certificado.
  const cliente = new pg.Client({ connectionString: process.env.DATABASE_URL });
  await cliente.connect();
  try {
    await cargarDatosReales(cliente);
  } catch (e) {
    console.error('Carga abortada; la base quedó como estaba.\n', e.message);
    process.exitCode = 1;
  } finally {
    await cliente.end();
  }
}
