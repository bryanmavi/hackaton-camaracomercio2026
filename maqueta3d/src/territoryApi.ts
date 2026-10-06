/**
 * Arma el mismo `Territory` que la app lee de los JSON estáticos, pero desde el esquema `api` de la base.
 * `buildTerritory` es pura (sin red) para poder probar la paridad con los datos reales (db/tests/paridad_app.mjs).
 * Las filas deben venir en el orden de la fuente (`orden_fuente`; zonas por `id`), como los JSON.
 */
import type { Feature, FeatureCollection, Geometry, MultiPolygon, Point } from "geojson";
import type { Manifest, SpaceProperties, Territory } from "./types";

export interface ApiRows {
  espacios: {
    id: string; nombre: string; tipo: string; condicion: string | null; comuna_codigo: string | null;
    barrio_nombre: string | null; limite_ambiguo: boolean; lon: number; lat: number; area_m2: number | null;
    fuente_clave: string; metodo_evaluacion: string;
    comuna_fuente: string | null; barrio_fuente: string | null;
  }[];
  huellas: { id: string; geometria: MultiPolygon }[];
  exposicion: { espacio_id: string; zona_id: number; amenaza_tipo: string; etiqueta: string | null }[];
  mediciones: {
    espacio_id: string;
    atributo: string;
    valor_num: number | null;
    valor_bool?: boolean | null;
    valor_texto: string | null;
    validado_en?: string | null;
    es_simulado?: boolean;
  }[];
  comunas: { codigo: string; nombre: string; geometria: MultiPolygon }[];
  barrios: { codigo: string; nombre: string; comuna_codigo: string; geometria: MultiPolygon }[];
  zonas: { id: number; amenaza_tipo: string; etiqueta: string | null; fuente_clave: string; geometria: MultiPolygon }[];
}

const FLOOD = new Set(["inundacion_fluvial", "inundacion_pluvial", "no_mitigable"]);
const SEISMIC = new Set(["licuacion", "efectos_sismicos"]);
const DISPONIBILIDAD_DESCONOCIDA = "Por confirmar con la entidad responsable";

const collection = <P,>(features: Feature<Geometry, P>[]): FeatureCollection<Geometry, P> => ({
  type: "FeatureCollection",
  features,
});
const feature = <P,>(geometry: Geometry, properties: P): Feature<Geometry, P> => ({
  type: "Feature",
  geometry,
  properties,
});

export function buildTerritory(rows: ApiRows, manifest: Manifest): Territory {
  const huella = new Map(rows.huellas.map((h) => [h.id, h.geometria]));
  // Etiquetas de cruce en el orden de las zonas (mismo orden que flood.json/seismic.json) y sin repetir
  const cruces = new Map<string, { flood: string[]; seismic: string[] }>();
  for (const x of [...rows.exposicion].sort((a, b) => a.zona_id - b.zona_id)) {
    const c = cruces.get(x.espacio_id) ?? { flood: [], seismic: [] };
    const lista = FLOOD.has(x.amenaza_tipo) ? c.flood : SEISMIC.has(x.amenaza_tipo) ? c.seismic : null;
    if (lista && x.etiqueta && !lista.includes(x.etiqueta)) lista.push(x.etiqueta);
    cruces.set(x.espacio_id, c);
  }
  const medida = new Map<string, Map<string, ApiRows["mediciones"][number]>>();
  // El mapa público solo muestra mediciones reales; las simuladas (cuentas demo) se ven en Operación.
  for (const m of rows.mediciones.filter((x) => !x.es_simulado)) {
    const porEspacio = medida.get(m.espacio_id) ?? new Map();
    porEspacio.set(m.atributo, m);
    medida.set(m.espacio_id, porEspacio);
  }
  const numero = (id: string, atributo: string) => {
    const v = medida.get(id)?.get(atributo)?.valor_num;
    return v === null || v === undefined ? null : Number(v);
  };

  const spaces = rows.espacios.map((e) => {
    const c = cruces.get(e.id) ?? { flood: [], seismic: [] };
    const aceptaAnimales = medida.get(e.id)?.get("acepta_animales_compania");
    const zonaAnimales = medida.get(e.id)?.get("zona_animales");
    const capacidadAnimales = medida.get(e.id)?.get("capacidad_animales");
    const properties: SpaceProperties = {
      id: e.id,
      sourceKey: e.fuente_clave as SpaceProperties["sourceKey"],
      name: e.nombre,
      commune: e.comuna_codigo,
      neighborhood: e.barrio_nombre,
      coordinates: [Number(e.lon), Number(e.lat)],
      sourceCommune: e.comuna_fuente,
      sourceNeighborhood: e.barrio_fuente,
      boundaryAmbiguous: e.limite_ambiguo,
      areaM2: e.area_m2 === null ? null : Number(e.area_m2),
      type: e.tipo,
      condition: e.condicion,
      flood: c.flood,
      seismic: c.seismic,
      assessmentMethod: e.metodo_evaluacion,
      availability: medida.get(e.id)?.get("disponibilidad")?.valor_texto ?? DISPONIBILIDAD_DESCONOCIDA,
      structuralAssessment: null,
      capacity: numero(e.id, "capacidad_personas"),
      toilets: numero(e.id, "banos"),
      waterLitersPerDay: numero(e.id, "agua_l_dia"),
      ...(aceptaAnimales && {
        acepta_animales_compania: aceptaAnimales.valor_bool ?? null,
        acepta_animales_compania_validado_en: aceptaAnimales.validado_en ?? null,
      }),
      ...(zonaAnimales && {
        zona_animales: zonaAnimales.valor_bool ?? null,
        zona_animales_validado_en: zonaAnimales.validado_en ?? null,
      }),
      ...(capacidadAnimales && {
        capacidad_animales:
          capacidadAnimales.valor_num === null ? null : Number(capacidadAnimales.valor_num),
        capacidad_animales_validado_en: capacidadAnimales.validado_en ?? null,
      }),
    };
    const geometry: Geometry =
      huella.get(e.id) ?? ({ type: "Point", coordinates: [Number(e.lon), Number(e.lat)] } as Point);
    return feature(geometry, properties);
  });

  return {
    spaces: collection(spaces),
    communes: collection(rows.comunas.map((c) => feature(c.geometria, { code: c.codigo, name: c.nombre }))),
    neighborhoods: collection(
      rows.barrios.map((b) => feature(b.geometria, { code: b.codigo, name: b.nombre, commune: b.comuna_codigo })),
    ),
    flood: collection(
      rows.zonas.filter((z) => FLOOD.has(z.amenaza_tipo))
        .map((z) => feature(z.geometria, { sourceKey: z.fuente_clave, label: z.etiqueta })),
    ),
    seismic: collection(
      rows.zonas.filter((z) => SEISMIC.has(z.amenaza_tipo))
        .map((z) => feature(z.geometria, { sourceKey: z.fuente_clave, label: z.etiqueta })),
    ),
    manifest,
  };
}

/**
 * Pide todas las filas de una vista de `api` (Supabase devuelve como máximo 1.000 por respuesta).
 * La primera página trae el total (count=exact); las demás se piden EN PARALELO.
 * El orden DEBE ser único: si no, las páginas pueden duplicar o saltarse filas con el mismo valor.
 */
const PAGINA = 1000;
type Pagina = PromiseLike<{ data: unknown[] | null; error: { message: string } | null; count?: number | null }>;
type Ordenable = { order: (columna: string) => Ordenable; range: (desde: number, hasta: number) => Pagina };
type Consultable = { from: (vista: string) => { select: (columnas: string, opciones?: { count?: "exact" }) => Ordenable } };
async function todas<T>(cliente: Consultable, vista: string, columnas: string, orden: string): Promise<T[]> {
  const pedir = (desde: number, contar = false) => {
    let consulta = cliente.from(vista).select(columnas, contar ? { count: "exact" } : undefined);
    for (const columna of orden.split(",")) consulta = consulta.order(columna);
    return consulta.range(desde, desde + PAGINA - 1);
  };
  const primera = await pedir(0, true);
  if (primera.error) throw new Error(`${vista}: ${primera.error.message}`);
  const total = primera.count ?? primera.data?.length ?? 0;
  const resto = await Promise.all(
    Array.from({ length: Math.max(0, Math.ceil(total / PAGINA) - 1) }, (_, i) => pedir((i + 1) * PAGINA)),
  );
  const filas = [...(primera.data ?? [])];
  for (const r of resto) {
    if (r.error) throw new Error(`${vista}: ${r.error.message}`);
    filas.push(...(r.data ?? []));
  }
  if (filas.length !== total) throw new Error(`${vista}: llegaron ${filas.length} filas de ${total}`);
  return filas as T[];
}

export async function loadTerritoryFromApi(cliente: Consultable, manifest: Manifest): Promise<Territory> {
  const [espacios, huellas, exposicion, mediciones, comunas, barrios, zonas] = await Promise.all([
    todas<ApiRows["espacios"][number]>(cliente, "espacios",
      "id,nombre,tipo,condicion,comuna_codigo,barrio_nombre,limite_ambiguo,lon,lat,area_m2,fuente_clave,metodo_evaluacion,comuna_fuente,barrio_fuente", "orden_fuente"),
    todas<ApiRows["huellas"][number]>(cliente, "espacio_huellas", "id,geometria", "id"),
    todas<ApiRows["exposicion"][number]>(cliente, "espacio_exposicion", "espacio_id,zona_id,amenaza_tipo,etiqueta", "zona_id,espacio_id"),
    todas<ApiRows["mediciones"][number]>(cliente, "mediciones_verificadas", "espacio_id,atributo,valor_num,valor_bool,valor_texto,validado_en,es_simulado", "espacio_id,atributo"),
    todas<ApiRows["comunas"][number]>(cliente, "comunas", "codigo,nombre,geometria", "orden_fuente"),
    todas<ApiRows["barrios"][number]>(cliente, "barrios", "codigo,nombre,comuna_codigo,geometria", "orden_fuente"),
    todas<ApiRows["zonas"][number]>(cliente, "zonas_amenaza", "id,amenaza_tipo,etiqueta,fuente_clave,geometria", "id"),
  ]);
  return buildTerritory({ espacios, huellas, exposicion, mediciones, comunas, barrios, zonas }, manifest);
}
