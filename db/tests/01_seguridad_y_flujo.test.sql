-- Pruebas del Hito 1: permisos, reglas de integridad y flujo completo. Datos 100 % ficticios.
-- Se ejecuta con db/tests/ejecutar.mjs (PGlite). Cada prueba deja una fila (prueba, ok) en pruebas.resultados.

create schema pruebas;
create table pruebas.resultados (n serial, prueba text, ok boolean);
grant usage on schema pruebas to anon, authenticated, service_role;
grant insert, select on pruebas.resultados to anon, authenticated, service_role;
grant usage on sequence pruebas.resultados_n_seq to anon, authenticated, service_role;

-- Ejecuta SQL como el rol actual y devuelve el SQLSTATE del error (NULL si no falla).
create function pruebas.error_de(p_sql text) returns text language plpgsql as $$
begin
  execute p_sql;
  return null;
exception when others then
  return sqlstate;
end $$;
grant execute on function pruebas.error_de(text) to anon, authenticated, service_role;

create function pruebas.anotar(p_prueba text, p_ok boolean) returns void language sql as $$
  insert into pruebas.resultados (prueba, ok) values (p_prueba, coalesce(p_ok, false));
$$;
grant execute on function pruebas.anotar(text, boolean) to anon, authenticated, service_role;

-- Cambia de usuario simulando el JWT de Supabase
create function pruebas.como(p_sub text, p_aal text default 'aal1') returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p_sub, 'aal', p_aal, 'role', 'authenticated')::text, false);
$$;
grant execute on function pruebas.como(text, text) to anon, authenticated;

-- ───────────── Datos ficticios ─────────────
insert into ref.fuentes (clave, nombre, entidad, pagina_fuente, licencia, compartir_igual, atribucion, fecha_corte) values
  ('communes', 'comunas', 'DAPM', 'https://example.org', 'CC BY', false, 'demo', '2026-09-25'),
  ('neighborhoods', 'barrios', 'DAPM', 'https://example.org', 'CC BY', false, 'demo', '2026-09-25'),
  ('publicSpaces', 'epou', 'DAPM', 'https://example.org', 'CC BY-SA', true, 'demo', '2026-09-25'),
  ('sports', 'deporte', 'Deporte', 'https://example.org', 'CC BY-SA', true, 'demo', '2026-09-25'),
  ('fluvial', 'fluvial', 'DAPM', 'https://example.org', 'CC BY-SA', true, 'demo', '2026-09-25');

insert into geo.comunas values
  ('01', 'Comuna demo 1', extensions.st_multi(extensions.st_makeenvelope(-76.60, 3.40, -76.50, 3.50, 4326)), 'communes'),
  ('02', 'Comuna demo 2', extensions.st_multi(extensions.st_makeenvelope(-76.50, 3.40, -76.40, 3.50, 4326)), 'communes');
insert into geo.barrios values
  ('0101', 'Barrio demo', '01', extensions.st_multi(extensions.st_makeenvelope(-76.60, 3.40, -76.55, 3.45, 4326)), 'neighborhoods');

insert into geo.espacios (id, fuente_clave, nombre, tipo, comuna_codigo, punto, huella, metodo_evaluacion) values
  ('epou-1', 'publicSpaces', 'Parque seco', 'Parque', '01', extensions.st_setsrid(extensions.st_point(-76.58, 3.42), 4326),
     extensions.st_multi(extensions.st_makeenvelope(-76.581, 3.419, -76.579, 3.421, 4326)), 'Intersección con toda la huella'),
  ('epou-2', 'publicSpaces', 'Parque junto al río', 'Parque', '01', extensions.st_setsrid(extensions.st_point(-76.52, 3.48), 4326),
     extensions.st_multi(extensions.st_makeenvelope(-76.521, 3.479, -76.519, 3.481, 4326)), 'Intersección con toda la huella'),
  ('epou-3', 'publicSpaces', 'Parque otra comuna', 'Parque', '02', extensions.st_setsrid(extensions.st_point(-76.45, 3.45), 4326),
     extensions.st_multi(extensions.st_makeenvelope(-76.451, 3.449, -76.449, 3.451, 4326)), 'Intersección con toda la huella'),
  ('deporte-1', 'sports', 'Cancha', 'Escenario deportivo', '01', extensions.st_setsrid(extensions.st_point(-76.57, 3.43), 4326),
     null, 'Cruce en el punto');
insert into geo.zonas_amenaza (fuente_clave, amenaza_tipo, etiqueta, geom) values
  ('fluvial', 'inundacion_fluvial', 'Zona demo', extensions.st_multi(extensions.st_makeenvelope(-76.525, 3.475, -76.515, 3.485, 4326)));
insert into geo.organizaciones_comunitarias (tipo, nombre, comuna_codigo, es_simulado) values
  ('jac', 'JAC demo A', '01', true), ('jac', 'JAC demo B', '02', true);

insert into idn.cargos (entidad_id, nombre, rol_por_defecto)
  select id, 'Secretario(a) de Gestión del Riesgo (demo)', 'gestion_riesgo' from ref.entidades where codigo = 'SGRED';

-- UUID fijos para leer las pruebas: 1 su, 2 gr, 3 gr2, 4 UAESP, 5 EMCALI, 6 comunitario A, 7 comunitario B, 8 auditor, 9 consulta
select idn.provisionar_perfil('00000000-0000-0000-0000-000000000001', 'superusuario', 'Administración (demo)', p_simulado => true);
select idn.provisionar_perfil('00000000-0000-0000-0000-000000000002', 'gestion_riesgo', 'SGRED (demo)',
  (select id from ref.entidades where codigo = 'SGRED'), p_cargo => (select id from idn.cargos limit 1), p_simulado => true);
select idn.provisionar_perfil('00000000-0000-0000-0000-000000000003', 'consulta', 'Coordinación entrante (demo)', p_simulado => true);
select idn.provisionar_perfil('00000000-0000-0000-0000-000000000004', 'entidad_responsable', 'UAESP (demo)',
  (select id from ref.entidades where codigo = 'UAESP'), p_simulado => true);
select idn.provisionar_perfil('00000000-0000-0000-0000-000000000005', 'entidad_responsable', 'EMCALI (demo)',
  (select id from ref.entidades where codigo = 'EMCALI'), p_simulado => true);
select idn.provisionar_perfil('00000000-0000-0000-0000-000000000006', 'comunitario', 'JAC A (demo)', null,
  (select id from geo.organizaciones_comunitarias where nombre = 'JAC demo A'), array['01'], p_simulado => true);
select idn.provisionar_perfil('00000000-0000-0000-0000-000000000007', 'comunitario', 'JAC B (demo)', null,
  (select id from geo.organizaciones_comunitarias where nombre = 'JAC demo B'), array['02'], p_simulado => true);
select idn.provisionar_perfil('00000000-0000-0000-0000-000000000008', 'auditor', 'Auditoría (demo)', p_simulado => true);
select idn.provisionar_perfil('00000000-0000-0000-0000-000000000009', 'consulta', 'Jurado (demo)', p_simulado => true);

-- ───────────── Filtro de datos personales ─────────────
select pruebas.anotar('filtro: rechaza celular', not idn.texto_limpio('Llamar al 300 123 4567'));
select pruebas.anotar('filtro: rechaza correo', not idn.texto_limpio('escribir a vecina@example.org'));
select pruebas.anotar('filtro: rechaza prefijo internacional', not idn.texto_limpio('+57 1 234'));
select pruebas.anotar('filtro: admite texto operativo', idn.texto_limpio('Faltan 2 baños en la zona norte'));
select pruebas.anotar('referencia: admite número de decreto', idn.referencia_valida('4112.010.20.0391 de 2026'));
select pruebas.anotar('referencia: rechaza correo', not idn.referencia_valida('acta@example.org'));

-- ───────────── Público (anon) ─────────────
set role anon;
select pruebas.anotar('anon lee los 4 espacios', (select count(*) from api.espacios) = 4);
select pruebas.anotar('anon ve el cruce con inundación de epou-2',
  (select cruce_inundacion_fluvial from api.espacio_ficha where id = 'epou-2'));
select pruebas.anotar('anon: desconocido es NULL, no cero',
  (select banos is null and disponibilidad = 'Por confirmar con la entidad responsable' from api.espacio_ficha where id = 'epou-1'));
select pruebas.anotar('anon no lee decisiones', pruebas.error_de('select * from api.decisiones') = '42501');
select pruebas.anotar('anon no lee auditoría', pruebas.error_de('select * from api.auditoria') = '42501');
select pruebas.anotar('anon no ejecuta funciones de escritura',
  pruebas.error_de($q$select api.registrar_medicion('epou-1','banos','x',1)$q$) = '42501');
select pruebas.anotar('anon no escribe en tablas',
  pruebas.error_de($q$insert into geo.espacios (id) values ('epou-9')$q$) = '42501');
reset role;

-- ───────────── Decisión: solo gestion_riesgo con MFA ─────────────
set role authenticated;
select pruebas.como('00000000-0000-0000-0000-000000000002', 'aal1');
select pruebas.anotar('gestion_riesgo sin aal2 no decide',
  pruebas.error_de($q$select api.registrar_decision_activacion(null,'epou-1','flood','albergue','resolucion','4112.010.21.0001','2026-10-04','Prueba')$q$) = '42501');
select pruebas.anotar('nadie inserta decisiones directo',
  pruebas.error_de($q$insert into ops.decisiones_activacion (espacio_id) values ('epou-1')$q$) = '42501');

select pruebas.como('00000000-0000-0000-0000-000000000002', 'aal2');
select pruebas.anotar('sin recomendación exige justificación',
  pruebas.error_de($q$select api.registrar_decision_activacion(null,'epou-1','flood','albergue','resolucion','4112.010.21.0001','2026-10-04')$q$) = '23514');
select pruebas.anotar('la función debe aplicar a la amenaza',
  pruebas.error_de($q$select api.registrar_decision_activacion(null,'epou-1','wildfire','albergue','resolucion','1','2026-10-04','Prueba')$q$) = '23514');

-- recomendación y decisión que se aparta de ella (exige justificación)
create temp table ids (clave text primary key, valor text);
grant all on ids to authenticated;
insert into ids values ('rec', api.registrar_recomendacion('flood', 143, 'epou-2', 'Comuna demo 1', 'reglas-v1',
  '[{"id":"epou-1","distancia_m":1200,"razon":"Sin cruce de inundación detectado"}]', '{"considerados":3,"excluidos":1}')::text);
select pruebas.anotar('decidir un espacio no recomendado sin justificar falla',
  pruebas.error_de(format($q$select api.registrar_decision_activacion(%L,'epou-3','flood','albergue','resolucion','1','2026-10-04')$q$,
    (select valor from ids where clave = 'rec'))) = '23514');
insert into ids values ('dec', api.registrar_decision_activacion((select valor::uuid from ids where clave = 'rec'),
  'epou-1', 'flood', 'albergue', 'resolucion', '4112.010.21.0001', '2026-10-04', null, 143,
  '[{"servicio":"toilets","requerido":8},{"servicio":"water","requerido":2145},{"servicio":"shelter","requerido":500.5}]', 'reglas-v1')::text);
select pruebas.anotar('decisión recomendada sin justificación se registra',
  (select count(*) from api.decisiones) = 1);
select pruebas.anotar('se crean 3 brechas desde la matriz (baños, agua, superficie)',
  (select count(*) from api.brechas) = 3);
select pruebas.anotar('faltante NULL cuando no hay existente verificado',
  (select bool_and(faltante is null and existente is null) from api.brechas));
select pruebas.anotar('baños van a UAESP y bloquean', (select entidad_codigo = 'UAESP' and bloquea_activacion
  from api.brechas where servicio_codigo = 'toilets'));
select pruebas.anotar('se instancian las 11 tareas del protocolo', (select count(*) from api.mis_tareas) = 11);
select pruebas.anotar('lo creado por una cuenta demo queda simulado', (select bool_and(es_simulado) from api.brechas));
reset role;
select pruebas.anotar('recomendaciones son inmutables',
  pruebas.error_de('update ops.recomendaciones set ambito = $$x$$') = '23001');
select pruebas.anotar('decisiones no se borran', pruebas.error_de('delete from ops.decisiones_activacion') = '23001');

-- ───────────── Entidades: solo lo suyo ─────────────
set role authenticated;
select pruebas.como('00000000-0000-0000-0000-000000000004');   -- UAESP
select pruebas.anotar('UAESP ve solo su brecha', (select count(*) from api.brechas) = 1);
select pruebas.anotar('UAESP ve la decisión donde tiene brechas', (select count(*) from api.decisiones) = 1);
select pruebas.anotar('UAESP avanza su brecha',
  pruebas.error_de(format($q$select api.actualizar_brecha(%L,'en_revision',null,'Revisando baños')$q$,
    (select id from ops.brechas where servicio_codigo = 'toilets'))) is null);
select pruebas.anotar('una brecha no retrocede',
  pruebas.error_de(format($q$select api.actualizar_brecha(%L,'por_medir')$q$,
    (select id from ops.brechas where servicio_codigo = 'toilets'))) = '23514');
select pruebas.anotar('nota con teléfono se rechaza',
  pruebas.error_de(format($q$select api.actualizar_brecha(%L,null,null,'Llamar al 3001234567')$q$,
    (select id from ops.brechas where servicio_codigo = 'toilets'))) = '23514');
reset role;
insert into ids values ('brecha_toilets', (select id::text from ops.brechas where servicio_codigo = 'toilets')),
                       ('cargo', (select id::text from idn.cargos limit 1));
set role authenticated;
select pruebas.como('00000000-0000-0000-0000-000000000005');
select pruebas.anotar('EMCALI no actualiza brecha ajena (42501)',
  pruebas.error_de(format($q$select api.actualizar_brecha(%L,'asignada')$q$, (select valor from ids where clave = 'brecha_toilets'))) = '42501');

-- ───────────── Mediciones: zona y cuatro ojos ─────────────
select pruebas.como('00000000-0000-0000-0000-000000000006');   -- comunitario A (comuna 01)
insert into ids values ('med', api.registrar_medicion('epou-1', 'banos', 'Conteo de la JAC (demo)', 4)::text);
select pruebas.anotar('comunitario no declara fuera de su zona',
  pruebas.error_de($q$select api.registrar_medicion('epou-3','banos','x',2)$q$) = '42501');
select pruebas.anotar('comunitario no valida',
  pruebas.error_de(format('select api.validar_medicion(%s, true, %L)', (select valor from ids where clave = 'med'), 'Acta 1')) = '42501');
select pruebas.anotar('comunitario ve la decisión vigente de su zona', (select count(*) from api.decisiones) = 1);
select pruebas.anotar('el reporte exige que los grupos sumen el total',
  pruebas.error_de($q$select api.crear_reporte_comunitario('necesidad','epou-1',10,1,2,3,3)$q$) = '23514');
select pruebas.anotar('el reporte rechaza correos en la observación',
  pruebas.error_de($q$select api.crear_reporte_comunitario('necesidad','epou-1',p_observacion=>'avisar a x@example.org')$q$) = '23514');
select pruebas.anotar('estado_servicios solo con códigos válidos',
  pruebas.error_de($q$select api.crear_reporte_comunitario('estado_espacio','epou-1',p_estado_servicios=>'{"toilets":"roto"}')$q$) = '23514');
select api.crear_reporte_comunitario('estado_espacio', 'epou-1', 10, 1, 2, 4, 3, null, 2, '{"toilets":"falla","water":"ok"}');
select pruebas.anotar('comunitario A ve su reporte', (select count(*) from api.reportes_comunitarios) = 1);
select pruebas.como('00000000-0000-0000-0000-000000000007');   -- comunitario B (comuna 02)
select pruebas.anotar('comunitario B no ve reportes ni decisiones de otra zona',
  (select count(*) from api.reportes_comunitarios) = 0 and (select count(*) from api.decisiones) = 0);

select pruebas.como('00000000-0000-0000-0000-000000000005');   -- EMCALI no valida baños
select pruebas.anotar('EMCALI no valida un atributo que no es suyo',
  pruebas.error_de(format('select api.validar_medicion(%s, true, %L)', (select valor from ids where clave = 'med'), 'Acta 1')) = '42501');
select pruebas.como('00000000-0000-0000-0000-000000000004');   -- UAESP sí
select pruebas.anotar('verificar exige evidencia',
  pruebas.error_de(format('select api.validar_medicion(%s, true)', (select valor from ids where clave = 'med'))) = '23514');
select api.validar_medicion((select valor::bigint from ids where clave = 'med'), true, 'Acta UAESP 12 de 2026');
select pruebas.como('00000000-0000-0000-0000-000000000002', 'aal2');
insert into ids values ('med2', api.registrar_medicion('epou-1', 'capacidad_personas', 'Inspección (demo)', 150)::text);
select pruebas.anotar('quien reporta no valida (cuatro ojos)',
  pruebas.error_de(format('select api.validar_medicion(%s, true, %L)', (select valor from ids where clave = 'med2'), 'Acta 2')) = '42501');
select pruebas.anotar('evaluación estructural no admite texto (no hay concepto)',
  pruebas.error_de($q$select api.registrar_medicion('epou-1','evaluacion_estructural_vigente','x',p_valor_texto=>'APTO')$q$) = '23514');
reset role;
set role anon;
select pruebas.anotar('la ficha pública muestra lo verificado (4 baños)', (select banos = 4 from api.espacio_ficha where id = 'epou-1'));
select pruebas.anotar('la ficha pública no muestra lo solo declarado', (select capacidad_personas is null from api.espacio_ficha where id = 'epou-1'));
select pruebas.anotar('anon no ve los UUID de quien validó',
  pruebas.error_de('select validado_por from geo.mediciones_espacio') = '42501');
reset role;

-- ───────────── Consulta y supresión ─────────────
set role authenticated;
select pruebas.como('00000000-0000-0000-0000-000000000009');
select pruebas.anotar('consulta no lee filas operativas', (select count(*) from api.decisiones) = 0 and (select count(*) from api.brechas) = 0);
select pruebas.anotar('resumen suprime conteos menores al umbral',
  (select decisiones_vigentes is null and n_espacios = 3 from api.resumen_territorial where comuna_codigo = '01'));
select pruebas.anotar('consulta no ve la auditoría', (select count(*) from api.auditoria) = 0);

-- ───────────── Retorno ─────────────
select pruebas.como('00000000-0000-0000-0000-000000000002', 'aal2');
select api.cerrar_retorno((select valor::uuid from ids where clave = 'dec'), '{"limpieza":true}', 'Acta de entrega 7', '2026-10-20',
  array[(select valor::bigint from ids where clave = 'cargo')]);
select pruebas.anotar('el retorno cierra la decisión', (select estado = 'cerrada' from api.decisiones));
select pruebas.anotar('con la decisión cerrada no se tocan brechas',
  pruebas.error_de(format($q$select api.actualizar_brecha(%L,'cerrada')$q$, (select valor from ids where clave = 'brecha_toilets'))) = '23001');
select pruebas.como('00000000-0000-0000-0000-000000000006');
select pruebas.anotar('comunitario deja de ver la decisión cerrada', (select count(*) from api.decisiones) = 0);

-- ───────────── Administración de cuentas ─────────────
select pruebas.como('00000000-0000-0000-0000-000000000001', 'aal1');
select pruebas.anotar('superusuario sin aal2 no gestiona usuarios',
  pruebas.error_de($q$select api.suspender_usuario('00000000-0000-0000-0000-000000000004','x')$q$) = '42501');
select pruebas.como('00000000-0000-0000-0000-000000000001', 'aal2');
select pruebas.anotar('superusuario no lee datos operativos', (select count(*) from api.brechas) = 0);
select pruebas.anotar('superusuario no cambia su propio rol',
  pruebas.error_de($q$select api.cambiar_rol('00000000-0000-0000-0000-000000000001','auditor')$q$) = '42501');
select api.suspender_usuario('00000000-0000-0000-0000-000000000004', 'Fin de la demo');
select api.traspasar_cargo((select valor::bigint from ids where clave = 'cargo'), '00000000-0000-0000-0000-000000000003', 'Cambio de administración (demo)');
select pruebas.como('00000000-0000-0000-0000-000000000004');
select pruebas.anotar('la suspensión surte efecto de inmediato (sin esperar el token)', (select count(*) from api.brechas) = 0);
select pruebas.como('00000000-0000-0000-0000-000000000003', 'aal2');
select pruebas.anotar('el rol sigue al cargo: el entrante es gestion_riesgo', (select rol = 'gestion_riesgo' from api.mi_perfil));
select pruebas.como('00000000-0000-0000-0000-000000000002', 'aal2');
select pruebas.anotar('el saliente queda en consulta', (select rol = 'consulta' from api.mi_perfil));
select pruebas.anotar('el saliente ya no decide',
  pruebas.error_de($q$select api.registrar_decision_activacion(null,'epou-1','flood','albergue','resolucion','1','2026-10-04','x')$q$) = '42501');
reset role;
select pruebas.anotar('el historial de asignaciones se conserva', (select count(*) from idn.asignaciones_cargo) = 2);

-- ───────────── Hook del token ─────────────
select pruebas.anotar('el hook pone user_role en el JWT',
  (select idn.custom_access_token_hook('{"user_id":"00000000-0000-0000-0000-000000000008","claims":{"role":"authenticated"}}')
     -> 'claims' ->> 'user_role') = 'auditor');
select pruebas.anotar('el hook no da rol a un suspendido',
  (select idn.custom_access_token_hook('{"user_id":"00000000-0000-0000-0000-000000000004","claims":{}}') -> 'claims' -> 'user_role') = 'null'::jsonb);

-- ───────────── Auditoría ─────────────
set role authenticated;
select pruebas.como('00000000-0000-0000-0000-000000000008');
select pruebas.anotar('el auditor ve la auditoría', (select count(*) from api.auditoria) > 20);
select pruebas.anotar('la auditoría no guarda el alias de las personas',
  not exists (select 1 from api.auditoria where cambios ? 'alias_visible'));
select pruebas.anotar('la cadena de hash verifica', (select ok from api.verificar_auditoria()));
reset role;
select pruebas.anotar('ni el dueño borra la auditoría', pruebas.error_de('delete from aud.eventos') = '23001');
select pruebas.anotar('ni el dueño vacía la auditoría', pruebas.error_de('truncate aud.eventos') = '23001');
-- Manipulación deliberada: alguien desactiva el bloqueo y reescribe una fila
alter table aud.eventos disable trigger eventos_inmutable;
update aud.eventos set cambios = cambios || '{"estado":"falsificado"}' where id = 5;
alter table aud.eventos enable trigger eventos_inmutable;
select pruebas.anotar('la verificación detecta la fila manipulada', (select not ok and primera_invalida = 5 from aud.verificar_cadena()));

-- ───────────── Provisión desde el servidor (migración 13) ─────────────
set role authenticated;
select pruebas.como('00000000-0000-0000-0000-000000000001', 'aal2');
select pruebas.anotar('ni el superusuario provisiona por la API (solo service_role)',
  pruebas.error_de($q$select api.provisionar_perfil('00000000-0000-0000-0000-0000000000aa','auditor','x')$q$) = '42501');
reset role;
set role anon;
select pruebas.anotar('anon no crea organizaciones',
  pruebas.error_de($q$select api.asegurar_organizacion('jac','X')$q$) = '42501');
reset role;
set role service_role;
select pruebas.anotar('service_role crea una organización ficticia',
  api.asegurar_organizacion('jac', 'JAC demo C (simulada)', '01', null, true) is not null);
select pruebas.anotar('asegurar_organizacion es idempotente',
  api.asegurar_organizacion('jac', 'JAC demo C (simulada)', '01', null, true)
  = api.asegurar_organizacion('jac', 'JAC demo C (simulada)', '01', null, true));
select pruebas.anotar('service_role provisiona un perfil con cargo nuevo',
  api.provisionar_perfil('00000000-0000-0000-0000-0000000000aa', 'entidad_responsable', 'Salud Pública (demo)',
    'SALUD_PUBLICA', p_cargo_nombre => 'Enlace de Salud Pública (demo)', p_simulado => true) = 'creado');
select pruebas.anotar('provisionar de nuevo no duplica',
  api.provisionar_perfil('00000000-0000-0000-0000-0000000000aa', 'entidad_responsable', 'Salud Pública (demo)',
    'SALUD_PUBLICA', p_cargo_nombre => 'Enlace de Salud Pública (demo)', p_simulado => true) = 'existente');
reset role;
select pruebas.anotar('el perfil quedó con su cargo y asignación vigente',
  exists (select 1 from idn.perfiles p join idn.cargos c on c.id = p.cargo_id
          join idn.asignaciones_cargo a on a.cargo_id = c.id and a.user_id = p.user_id and a.hasta is null
          where p.user_id = '00000000-0000-0000-0000-0000000000aa' and p.es_simulado));
select pruebas.anotar('entidad inexistente se rechaza',
  pruebas.error_de($q$select api.provisionar_perfil('00000000-0000-0000-0000-0000000000bb','entidad_responsable','x','NO_EXISTE')$q$) = '23503');

select prueba, ok from pruebas.resultados order by n;
