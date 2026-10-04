// Prueba de la carga de datos reales (Hito 2) en PGlite: conteos, idempotencia, atomicidad,
// paridad de los cruces de amenaza con los que precalculó la app, y lectura pública.
// Uso: npm run test:carga   (desde db/)
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { baseDePrueba } from './pglite.mjs';
import { cargarDatosReales } from '../scripts/cargar_datos_reales.mjs';

const datosApp = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'maqueta3d', 'public', 'data');
let fallas = 0;
const anotar = (prueba, ok, detalle = '') => {
  console.log(ok ? 'PASA ' : 'FALLA', prueba, detalle);
  if (!ok) fallas++;
};
const uno = async (db, sql) => (await db.query(sql)).rows[0];

const db = await baseDePrueba({ silencioso: true });
let t = Date.now();
const c1 = await cargarDatosReales(db);
console.log(`(primera carga: ${((Date.now() - t) / 1000).toFixed(1)} s)`);
anotar('2.991 espacios: 1.970 EPOU + 1.021 deportivos', c1.publicSpaces === 1970 && c1.sports === 1021);
anotar('22 comunas y 342 barrios', c1.communes === 22 && c1.neighborhoods === 342);
anotar('660 zonas de amenaza (653 de inundación + 7 sísmicas, como la app)',
  c1.fluvial + c1.pluvial + c1.nonMitigable === 653 && c1.liquefaction + c1.seismicEffects === 7);
anotar('182 JAC', c1.jac === 182);
anotar('52 espacios sin comuna quedan NULL', c1.espacios_sin_comuna === 52);
anotar('23 JAC sin barrio en la capa quedan NULL', c1.jac_sin_barrio === 23);

// Idempotencia: repetir no duplica nada
const c2 = await cargarDatosReales(db, { registro: () => {} });
anotar('la recarga no duplica', JSON.stringify(c1) === JSON.stringify(c2));
anotar('ref.fuentes tiene 10 conjuntos con sha256', (await uno(db, `select count(*)::int n from ref.fuentes where sha256 is not null`)).n === 10);

// Atomicidad: si algo falla a mitad de camino, la base queda como estaba
const zonasAntes = (await uno(db, 'select count(*)::int n from geo.zonas_amenaza')).n;
const saboteada = { query: (sql, p) => (sql.includes('geo.organizaciones_comunitarias (tipo') ? Promise.reject(new Error('falla simulada')) : db.query(sql, p)) };
let abortada = false;
try { await cargarDatosReales(saboteada, { registro: () => {} }); } catch { abortada = true; }
anotar('una falla a mitad de la carga deshace todo (no borra las zonas)',
  abortada && (await uno(db, 'select count(*)::int n from geo.zonas_amenaza')).n === zonasAntes);

// Paridad: los cruces de PostGIS (ST_Intersects) frente a los arreglos flood/seismic que precalculó la app (Turf)
const espacios = JSON.parse(readFileSync(join(datosApp, 'spaces.json'), 'utf8')).features.map((f) => f.properties);
t = Date.now();
const { rows: cruces } = await db.query(`
  select espacio_id,
         bool_or(amenaza_tipo in ('inundacion_fluvial', 'inundacion_pluvial', 'no_mitigable')) as inundacion,
         bool_or(amenaza_tipo in ('licuacion', 'efectos_sismicos')) as sismo
  from geo.espacio_exposicion group by espacio_id`);
console.log(`(exposición de toda la ciudad: ${((Date.now() - t) / 1000).toFixed(1)} s)`);
const bd = new Map(cruces.map((r) => [r.espacio_id, r]));
const difInund = espacios.filter((e) => (e.flood.length > 0) !== Boolean(bd.get(e.id)?.inundacion)).map((e) => e.id);
const difSismo = espacios.filter((e) => (e.seismic.length > 0) !== Boolean(bd.get(e.id)?.sismo)).map((e) => e.id);
anotar('cruces de inundación iguales a los de la app', difInund.length === 0,
  `(app: ${espacios.filter((e) => e.flood.length).length}; distintos: ${difInund.length} ${difInund.slice(0, 5).join(' ')})`);
anotar('cruces sísmicos iguales a los de la app', difSismo.length === 0,
  `(app: ${espacios.filter((e) => e.seismic.length).length}; distintos: ${difSismo.length} ${difSismo.slice(0, 5).join(' ')})`);

// Lectura pública como anon, por la API
await db.query('set role anon');
const ficha = await uno(db, `select * from api.espacio_ficha where id = 'epou-8413'`);
anotar('ficha pública: lo desconocido sigue NULL y "Por confirmar"',
  ficha.capacidad_personas === null && ficha.banos === null && ficha.disponibilidad === 'Por confirmar con la entidad responsable');
anotar('la ficha conserva nombre, comuna y área de la fuente',
  ficha.nombre === 'Parque · Vipasa · EPE_02' && ficha.comuna_codigo === '02' && Number(ficha.area_m2) === 5292);
t = Date.now();
const nFichas = (await uno(db, 'select count(*)::int n from api.espacio_ficha')).n;
anotar('anon lee las 2.991 fichas', nFichas === 2991, `(${((Date.now() - t) / 1000).toFixed(1)} s)`);
anotar('anon lee las 182 JAC sin datos de personas',
  (await uno(db, `select count(*)::int n from geo.organizaciones_comunitarias where fuente_clave = 'jac'`)).n === 182);
await db.query('reset role');
await db.query('set role authenticated');
const resumen = await uno(db, `select count(*)::int comunas, sum(n_espacios)::int espacios, bool_and(decisiones_vigentes is null) suprimido
                               from api.resumen_territorial`);
anotar('resumen territorial: 22 comunas, 2.939 espacios con comuna, operativos suprimidos',
  resumen.comunas === 22 && resumen.espacios === 2939 && resumen.suprimido);
await db.query('reset role');

console.log(fallas ? `\n${fallas} prueba(s) fallaron` : '\nTodas las pruebas de carga pasan');
process.exit(fallas ? 1 : 0);
