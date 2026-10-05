// Aplica el shim de Supabase y las migraciones en PGlite y corre tests/*.test.sql.
// Uso: npm test   (desde db/)
import { readFileSync, readdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { baseDePrueba } from './pglite.mjs';

const aqui = dirname(fileURLToPath(import.meta.url));
let fallas = 0;
for (const f of readdirSync(aqui).filter((f) => f.endsWith('.test.sql')).sort()) {
  const db = await baseDePrueba({ silencioso: true });   // base limpia por archivo de pruebas
  try {
    const res = await db.exec(readFileSync(join(aqui, f), 'utf8'));
    for (const r of res) for (const row of r.rows ?? []) {
      if (!('prueba' in row)) continue;
      console.log(row.ok ? 'PASA ' : 'FALLA', row.prueba);
      if (!row.ok) fallas++;
    }
  } catch (e) {
    fallas++;
    console.error('FALLA', f, '\n', e.message, e.where ?? '');
  }
  await db.close();
}
console.log(fallas ? `\n${fallas} prueba(s) fallaron` : '\nTodas las pruebas pasan');
process.exit(fallas ? 1 : 0);
