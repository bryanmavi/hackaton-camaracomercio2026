// PGlite (PostgreSQL + PostGIS en WASM) con el shim de Supabase y todas las migraciones aplicadas. Solo pruebas.
import { PGlite } from '@electric-sql/pglite';
import { postgis } from '@electric-sql/pglite-postgis';
import { readFileSync, readdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const aqui = dirname(fileURLToPath(import.meta.url));
const migraciones = join(aqui, '..', 'supabase', 'migrations');

export async function baseDePrueba({ silencioso = false } = {}) {
  const db = new PGlite({ extensions: { postgis } });
  const archivos = [join(aqui, 'shim_supabase.sql'),
    ...readdirSync(migraciones).filter((f) => f.endsWith('.sql')).sort().map((f) => join(migraciones, f))];
  for (const ruta of archivos) {
    try {
      await db.exec(readFileSync(ruta, 'utf8'));
      if (!silencioso) console.log('ok   ', ruta.split('/').at(-1));
    } catch (e) {
      throw new Error(`Falla al aplicar ${ruta}: ${e.message} ${e.where ?? ''}`);
    }
  }
  return db;
}
