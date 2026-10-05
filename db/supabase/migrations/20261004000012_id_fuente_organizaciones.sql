-- Hito 2 · Migración 12: identificador de origen de las organizaciones comunitarias.
-- Permite recargar el dataset abierto de JAC (campo `oacid`) sin duplicar filas. Las organizaciones creadas
-- por registro (sin fuente) quedan con id_fuente NULL.

alter table geo.organizaciones_comunitarias add column id_fuente text;
alter table geo.organizaciones_comunitarias
  add constraint organizaciones_id_fuente_con_fuente check (id_fuente is null or fuente_clave is not null);
create unique index organizaciones_fuente_unica on geo.organizaciones_comunitarias (fuente_clave, id_fuente)
  where id_fuente is not null;
