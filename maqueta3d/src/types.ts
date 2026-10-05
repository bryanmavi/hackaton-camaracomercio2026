import type { Feature, FeatureCollection, Geometry } from "geojson";
export type Threat = "flood" | "seismic";
export interface SpaceProperties {
  id: string;
  name: string;
  sourceKey: "publicSpaces" | "sports";
  commune: string | null;
  neighborhood: string | null;
  coordinates: [number, number];
  areaM2: number | null;
  sourceCommune: string | null;
  sourceNeighborhood: string | null;
  boundaryAmbiguous: boolean;
  type: string;
  condition: string | null;
  flood: string[];
  seismic: string[];
  assessmentMethod: string;
  availability: string;
  structuralAssessment: null;
  /** null = desconocido (sin medición verificada), nunca cero */
  capacity: number | null;
  toilets: number | null;
  waterLitersPerDay: number | null;
}
export type Space = Feature<Geometry, SpaceProperties>;
export interface Source {
  key: string;
  name: string;
  page: string;
  license: string;
  download: string;
  snapshotDate: string;
  sha256: string;
  count: number;
}
export interface Manifest {
  snapshotDate: string;
  attribution: string;
  license: string;
  sources: Source[];
  recordCount: number;
  availabilityConfirmed: number;
  limitations: string[];
}
export interface Territory {
  spaces: FeatureCollection<Geometry, SpaceProperties>;
  communes: FeatureCollection;
  neighborhoods: FeatureCollection;
  flood: FeatureCollection;
  seismic: FeatureCollection;
  manifest: Manifest;
}
export const formatNumber = (n: number) =>
  new Intl.NumberFormat("es-CO").format(n);
