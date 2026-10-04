// Paridad contra Supabase REAL: carga el territorio con el mismo código de la app (src/territoryApi.ts) usando la
// clave PÚBLICA y lo compara campo por campo con los JSON estáticos.
// Tolerancia única y documentada: la API de Supabase serializa los float8 con 15 cifras significativas, así que las
// coordenadas del punto representativo pueden diferir en menos de 1e-9 grados (fracciones de milímetro).
// Uso: SUPABASE_URL=https://<ref>.supabase.co SUPABASE_ANON_KEY=<clave pública> node scripts/paridad-supabase.mjs
import { createClient } from "@supabase/supabase-js";
import { readFileSync } from "node:fs";
import { deepStrictEqual } from "node:assert";
import { loadTerritoryFromApi } from "../src/territoryApi.ts";

const { SUPABASE_URL: url, SUPABASE_ANON_KEY: clave } = process.env;
if (!url || !clave) {
  console.error("Faltan SUPABASE_URL y SUPABASE_ANON_KEY (la clave pública).");
  process.exit(1);
}
const leer = (n) => JSON.parse(readFileSync(new URL(`../public/data/${n}.json`, import.meta.url), "utf8"));
const inicio = Date.now();
const t = await loadTerritoryFromApi(createClient(url, clave, { db: { schema: "api" } }), leer("manifest"));
console.log(`Territorio leído de la API en ${((Date.now() - inicio) / 1000).toFixed(1)} s`);

let fallas = 0, maxDelta = 0;
for (const capa of ["spaces", "communes", "neighborhoods", "flood", "seismic"]) {
  const estatico = leer(capa).features, api = t[capa].features;
  let distintos = 0;
  for (let i = 0; i < Math.max(estatico.length, api.length); i++) {
    const a = structuredClone(api[i]), e = structuredClone(estatico[i]);
    if (capa === "spaces" && a && e) {
      const d = Math.max(...a.properties.coordinates.map((v, k) => Math.abs(v - e.properties.coordinates[k])));
      maxDelta = Math.max(maxDelta, d);
      if (d < 1e-9) a.properties.coordinates = e.properties.coordinates;
    }
    try { deepStrictEqual(a, e); } catch { distintos++; }
  }
  const ok = distintos === 0 && api.length === estatico.length;
  if (!ok) fallas++;
  console.log(`${ok ? "PASA " : "FALLA"} ${capa}: ${api.length} registros${distintos ? `, ${distintos} distintos` : " idénticos"}`);
}
console.log(`Diferencia máxima en coordenadas: ${maxDelta.toExponential(1)} grados`);
process.exit(fallas ? 1 : 0);
