// Aplica el shim de Supabase y las migraciones en PGlite (PostgreSQL + PostGIS en WASM) y corre las pruebas.
// Uso: node db/tests/ejecutar.mjs   (requiere: npm i @electric-sql/pglite @electric-sql/pglite-postgis)
import { PGlite } from '@electric-sql/pglite';
import { postgis } from '@electric-sql/pglite-postgis';
import { readFileSync, readdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const aqui = dirname(fileURLToPath(import.meta.url));
const migraciones = join(aqui, '..', 'supabase', 'migrations');
const db = new PGlite({ extensions: { postgis } });

async function aplicar(ruta) {
  try {
    await db.exec(readFileSync(ruta, 'utf8'));
    console.log('ok   ', ruta.split('/').slice(-1)[0]);
  } catch (e) {
    console.error('FALLA', ruta, '\n', e.message, e.position ? `(posición ${e.position})` : '', e.where ?? '');
    process.exit(1);
  }
}

await aplicar(join(aqui, 'shim_supabase.sql'));
for (const f of readdirSync(migraciones).filter((f) => f.endsWith('.sql')).sort()) await aplicar(join(migraciones, f));

const pruebas = readdirSync(aqui).filter((f) => f.endsWith('.test.sql')).sort();
let fallas = 0;
for (const f of pruebas) {
  const notas = [];
  db.onNotice?.((n) => notas.push(n.message));
  try {
    const res = await db.exec(readFileSync(join(aqui, f), 'utf8'));
    for (const r of res) for (const row of r.rows ?? []) if (row.prueba) console.log(row.ok ? 'PASA ' : 'FALLA', row.prueba), (fallas += row.ok ? 0 : 1);
  } catch (e) {
    fallas++;
    console.error('FALLA', f, '\n', e.message, e.where ?? '');
  }
}
console.log(fallas ? `\n${fallas} prueba(s) fallaron` : '\nTodas las pruebas pasan');
process.exit(fallas ? 1 : 0);
