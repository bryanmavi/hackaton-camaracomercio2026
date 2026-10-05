// Paridad app ↔ base: con los datos reales cargados en PGlite, lee las vistas de `api` como público (anon),
// arma el territorio con el MISMO código de la app (maqueta3d/src/territoryApi.ts) y lo compara, registro por
// registro y campo por campo, con los JSON estáticos que la app usa hoy. Uso: npm run test:paridad
import { readFileSync } from 'node:fs';
import { deepStrictEqual } from 'node:assert';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { baseDePrueba } from './pglite.mjs';
import { cargarDatosReales } from '../scripts/cargar_datos_reales.mjs';
import { buildTerritory } from '../../maqueta3d/src/territoryApi.ts';

const datos = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'maqueta3d', 'public', 'data');
const leer = (n) => JSON.parse(readFileSync(join(datos, `${n}.json`), 'utf8'));
let fallas = 0;
const anotar = (prueba, ok, detalle = '') => { console.log(ok ? 'PASA ' : 'FALLA', prueba, detalle); if (!ok) fallas++; };

const db = await baseDePrueba({ silencioso: true });
await cargarDatosReales(db, { registro: () => {} });
await db.query('set role anon');
const q = async (sql) => (await db.query(sql)).rows;
const filas = {
  espacios: await q(`select id,nombre,tipo,condicion,comuna_codigo,barrio_nombre,limite_ambiguo,lon,lat,area_m2,fuente_clave,
                            metodo_evaluacion,comuna_fuente,barrio_fuente from api.espacios order by orden_fuente`),
  huellas: await q('select id, geometria from api.espacio_huellas order by id'),
  exposicion: await q('select espacio_id, zona_id, amenaza_tipo, etiqueta from api.espacio_exposicion order by zona_id'),
  mediciones: await q('select espacio_id, atributo, valor_num, valor_texto from api.mediciones_verificadas order by espacio_id'),
  comunas: await q('select codigo, nombre, geometria from api.comunas order by orden_fuente'),
  barrios: await q('select codigo, nombre, comuna_codigo, geometria from api.barrios order by orden_fuente'),
  zonas: await q('select id, amenaza_tipo, etiqueta, fuente_clave, geometria from api.zonas_amenaza order by id'),
};
await db.query('reset role');

const manifiesto = leer('manifest');
const t = buildTerritory(filas, manifiesto);

for (const capa of ['spaces', 'communes', 'neighborhoods', 'flood', 'seismic']) {
  const estatico = leer(capa).features;
  const api = t[capa].features;
  let distintos = 0, primero = '';
  for (let i = 0; i < Math.max(estatico.length, api.length); i++) {
    try { deepStrictEqual(api[i], estatico[i]); }
    catch (e) {
      distintos++;
      if (!primero) primero = `primer distinto en la posición ${i}: ${(estatico[i]?.properties?.id ?? estatico[i]?.properties?.code ?? '')} ${e.message.split('\n').slice(0, 6).join(' ').slice(0, 300)}`;
    }
  }
  anotar(`${capa}: ${api.length} registros idénticos a los del JSON estático`, distintos === 0 && api.length === estatico.length,
    distintos ? `(${distintos} distintos; ${primero})` : '');
}
console.log(fallas ? `\n${fallas} prueba(s) de paridad fallaron` : '\nLa app recibe de la base exactamente los mismos datos que de los JSON');
process.exit(fallas ? 1 : 0);
