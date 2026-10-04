-- Hito 1 · Migración 6: auditoría append-only encadenada por hash (ADR-0006). Clase de dato: Restringido.
-- Guarda solo el UUID del actor (sin nombres ni correos). Cada fila incluye sha256(hash_previo || contenido).
-- UPDATE, DELETE y TRUNCATE están bloqueados. Quien administre la BD podría reescribir la tabla a mano:
-- por eso existe aud.verificar_cadena() y, opcionalmente, el ancla externa del hash de cabecera.

create table aud.eventos (
  id          bigint generated always as identity primary key,
  ocurrido_en timestamptz not null default clock_timestamp(),
  actor_uuid  uuid,                      -- NULL = el sistema
  actor_rol   text,
  tabla       text not null,
  operacion   text not null check (operacion in ('INSERT', 'UPDATE', 'DELETE')),
  fila_id     text,
  cambios     jsonb not null,
  hash_previo bytea,
  hash        bytea not null
);
create index eventos_tabla_ix on aud.eventos (tabla, id);
create index eventos_actor_ix on aud.eventos (actor_uuid, id);

create table aud.verificaciones (
  id                bigint generated always as identity primary key,
  ejecutada_en      timestamptz not null default now(),
  ejecutada_por     uuid,
  filas             bigint not null,
  ok                boolean not null,
  primera_invalida  bigint,
  hash_cabecera     bytea
);

create trigger eventos_inmutable
  before update or delete on aud.eventos
  for each row execute function aud.bloquear_modificacion();
create trigger eventos_sin_truncate
  before truncate on aud.eventos
  for each statement execute function aud.bloquear_modificacion();

-- Contenido canónico que entra al hash. Independiente de la zona horaria de la sesión.
create function aud.contenido_hash(
  p_ocurrido_en timestamptz, p_actor uuid, p_rol text, p_tabla text, p_operacion text, p_fila_id text, p_cambios jsonb
) returns bytea
language sql
immutable
set search_path = ''
as $$
  select convert_to(
    concat_ws('|',
      (extract(epoch from p_ocurrido_en) * 1000000)::bigint::text,
      coalesce(p_actor::text, ''), coalesce(p_rol, ''), p_tabla, p_operacion,
      coalesce(p_fila_id, ''), p_cambios::text),
    'UTF8');
$$;

-- Trigger genérico. Argumentos: [0] nombre de la columna llave; [1..] columnas que NO se auditan (sensibles).
create function aud.registrar()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_pk      text := tg_argv[0];
  v_excluir text[] := tg_argv[1:];
  v_nuevo   jsonb;
  v_viejo   jsonb;
  v_cambios jsonb;
  v_fila_id text;
  v_prev    bytea;
  v_ahora   timestamptz := clock_timestamp();
  v_actor   uuid := auth.uid();
  v_rol     text;
begin
  if tg_op = 'DELETE' then
    v_viejo := to_jsonb(old) - v_excluir;
    v_cambios := v_viejo;
    v_fila_id := to_jsonb(old) ->> v_pk;
  elsif tg_op = 'INSERT' then
    v_nuevo := to_jsonb(new) - v_excluir;
    v_cambios := v_nuevo;
    v_fila_id := to_jsonb(new) ->> v_pk;
  else
    v_nuevo := to_jsonb(new) - v_excluir;
    v_viejo := to_jsonb(old) - v_excluir;
    select coalesce(jsonb_object_agg(n.key, n.value), '{}'::jsonb) into v_cambios
      from jsonb_each(v_nuevo) n
      where v_viejo -> n.key is distinct from n.value;
    v_fila_id := to_jsonb(new) ->> v_pk;
    if v_cambios = '{}'::jsonb then
      return null;   -- UPDATE sin cambios auditables
    end if;
  end if;

  if v_actor is not null then
    select p.rol::text into v_rol from idn.perfiles p where p.user_id = v_actor;
  end if;

  -- Serializa las escrituras para que la cadena tenga un solo orden (aceptable en el MVP).
  perform pg_advisory_xact_lock(hashtextextended('aud.eventos', 0));
  select e.hash into v_prev from aud.eventos e order by e.id desc limit 1;

  insert into aud.eventos (ocurrido_en, actor_uuid, actor_rol, tabla, operacion, fila_id, cambios, hash_previo, hash)
  values (
    v_ahora, v_actor, v_rol, tg_table_schema || '.' || tg_table_name, tg_op, v_fila_id, v_cambios, v_prev,
    sha256(coalesce(v_prev, '\x00'::bytea)
           || aud.contenido_hash(v_ahora, v_actor, v_rol, tg_table_schema || '.' || tg_table_name, tg_op, v_fila_id, v_cambios))
  );
  return null;   -- AFTER trigger: el valor de retorno se ignora
end;
$$;

-- Recorre la cadena y comprueba cada hash. Deja constancia en aud.verificaciones.
create function aud.verificar_cadena()
returns table (ok boolean, filas bigint, primera_invalida bigint, hash_cabecera bytea)
language plpgsql
security definer
set search_path = ''
as $$
declare
  r record;
  v_prev bytea := null;
  v_filas bigint := 0;
  v_mala bigint := null;
  v_cabecera bytea := null;
begin
  perform pg_advisory_xact_lock(hashtextextended('aud.eventos', 0));
  for r in select * from aud.eventos order by id loop
    v_filas := v_filas + 1;
    if r.hash_previo is distinct from v_prev
       or r.hash <> sha256(coalesce(v_prev, '\x00'::bytea)
                           || aud.contenido_hash(r.ocurrido_en, r.actor_uuid, r.actor_rol, r.tabla, r.operacion, r.fila_id, r.cambios)) then
      v_mala := r.id;
      exit;
    end if;
    v_prev := r.hash;
    v_cabecera := r.hash;
  end loop;
  insert into aud.verificaciones (ejecutada_por, filas, ok, primera_invalida, hash_cabecera)
  values (auth.uid(), v_filas, v_mala is null, v_mala, v_cabecera);
  return query select v_mala is null, v_filas, v_mala, v_cabecera;
end;
$$;

-- Un trigger de auditoría por tabla de ops, idn y geo.mediciones_espacio.
-- Excepción deliberada: ops.lecturas_iot (simulada, de alto volumen y 30 días de retención).
create procedure aud.auditar(p_tabla regclass, p_pk text, p_excluir text[] default '{}')
language plpgsql
set search_path = ''
as $$
declare
  v_args text := quote_literal(p_pk);
  c text;
  v_nombre text := replace(p_tabla::text, '.', '_');
begin
  foreach c in array p_excluir loop
    v_args := v_args || ', ' || quote_literal(c);
  end loop;
  execute format(
    'create trigger %I after insert or update or delete on %s for each row execute function aud.registrar(%s)',
    'zz_auditoria_' || regexp_replace(v_nombre, '^.*\.', ''), p_tabla, v_args);
end;
$$;

call aud.auditar('geo.mediciones_espacio', 'id');
call aud.auditar('ops.recomendaciones', 'id');
call aud.auditar('ops.decisiones_activacion', 'id');
call aud.auditar('ops.brechas', 'id');
call aud.auditar('ops.seguimientos', 'id');
call aud.auditar('ops.tareas_protocolo', 'id');
call aud.auditar('ops.reportes_comunitarios', 'id');
call aud.auditar('ops.retornos', 'id');
call aud.auditar('ops.notificaciones', 'id');
call aud.auditar('idn.perfiles', 'user_id', array['alias_visible']);
call aud.auditar('idn.cargos', 'id');
call aud.auditar('idn.asignaciones_cargo', 'id');
call aud.auditar('idn.autorizaciones_tratamiento', 'user_id');
call aud.auditar('idn.rol_permisos', 'rol');
