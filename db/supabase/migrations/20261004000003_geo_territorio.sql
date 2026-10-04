-- Hito 1 · Migración 3: territorio (esquema geo). Datos abiertos: clase Público.
-- Todas las geometrías en EPSG:4326, igual que los GeoJSON de maqueta3d/public/data.

create table geo.comunas (
  codigo       text primary key check (codigo ~ '^[0-9]{2}$'),
  nombre       text not null,
  geom         extensions.geometry(MultiPolygon, 4326) not null,
  fuente_clave text not null references ref.fuentes (clave)
);
create index comunas_geom_gix on geo.comunas using gist (geom);

create table geo.barrios (
  codigo        text primary key check (codigo ~ '^[0-9]{4}$'),
  nombre        text not null,
  comuna_codigo text not null references geo.comunas (codigo),
  geom          extensions.geometry(MultiPolygon, 4326) not null,
  fuente_clave  text not null references ref.fuentes (clave)
);
create index barrios_comuna_ix on geo.barrios (comuna_codigo);
create index barrios_geom_gix on geo.barrios using gist (geom);

create table geo.espacios (
  id                    text primary key check (id ~ '^(epou|deporte)-[0-9]+$'),
  fuente_clave          text not null references ref.fuentes (clave),
  nombre                text not null,
  tipo                  text not null,
  condicion             text,
  comuna_codigo         text references geo.comunas (codigo),   -- hay registros sin comuna: no se inventan
  barrio_nombre         text,
  comuna_fuente         text,
  barrio_fuente         text,
  limite_ambiguo        boolean not null default false,
  punto                 extensions.geometry(Point, 4326) not null,
  huella                extensions.geometry(MultiPolygon, 4326),  -- solo en EPOU
  area_m2               numeric check (area_m2 >= 0),             -- huella cartográfica, NO superficie útil ni aforo
  metodo_evaluacion     text not null,
  estado_proteccion_uso text not null default 'sin_dato'
                          check (estado_proteccion_uso in ('sin_dato', 'protegido', 'en_riesgo_de_cambio_de_uso')),
  es_simulado           boolean not null default false
);
create index espacios_comuna_ix on geo.espacios (comuna_codigo);
create index espacios_fuente_ix on geo.espacios (fuente_clave);
create index espacios_punto_gix on geo.espacios using gist (punto);
create index espacios_huella_gix on geo.espacios using gist (huella);
comment on table geo.espacios is
  'Inventario de espacios públicos. Los dos tipos de fuente pueden describir el mismo predio: no sumar aforos ni superficies entre fuentes.';
comment on column geo.espacios.area_m2 is 'Huella cartográfica. No es superficie útil, área cubierta ni aforo.';

create table geo.zonas_amenaza (
  id           bigint generated always as identity primary key,
  fuente_clave text not null references ref.fuentes (clave),
  amenaza_tipo text not null check (amenaza_tipo in
                 ('inundacion_fluvial', 'inundacion_pluvial', 'no_mitigable', 'licuacion', 'efectos_sismicos')),
  etiqueta     text,
  atributos    jsonb not null default '{}'::jsonb,
  geom         extensions.geometry(MultiPolygon, 4326) not null
);
create index zonas_amenaza_tipo_ix on geo.zonas_amenaza (amenaza_tipo);
create index zonas_amenaza_geom_gix on geo.zonas_amenaza using gist (geom);

-- Mismo método que `assessmentMethod` de la app: toda la huella si existe; si no, el punto.
-- "Sin cruce" NO significa "sin amenaza".
create view geo.espacio_exposicion
with (security_invoker = true) as
select e.id          as espacio_id,
       z.id          as zona_id,
       z.amenaza_tipo,
       z.etiqueta,
       z.fuente_clave
from geo.espacios e
join geo.zonas_amenaza z
  on extensions.st_intersects(coalesce(e.huella, e.punto), z.geom);
comment on view geo.espacio_exposicion is
  'Cruces espacio × zona de amenaza (ST_Intersects). Sin cruce no significa sin amenaza: faltan capas.';

create table geo.organizaciones_comunitarias (
  id               bigint generated always as identity primary key,
  tipo             text not null check (tipo in
                     ('jac', 'propiedad_horizontal', 'comite_barrial', 'albergue_autogestionado', 'otra')),
  nombre           text not null,
  comuna_codigo    text references geo.comunas (codigo),
  barrio_codigo    text references geo.barrios (codigo),
  direccion_publica text,    -- solo la que trae el dataset abierto de la JAC
  fuente_clave     text references ref.fuentes (clave),
  activa           boolean not null default true,
  es_simulado      boolean not null default false
);
create index organizaciones_comuna_ix on geo.organizaciones_comunitarias (comuna_codigo);
comment on table geo.organizaciones_comunitarias is 'Organizaciones, no personas (principio de exclusión por diseño).';
