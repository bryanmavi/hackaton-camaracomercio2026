// Crea las 13 cuentas de demostración (Hito 5), una por rol, y verifica que cada una inicia sesión con el rol correcto.
//
// - Correos @example.org (dominio reservado: nadie lo recibe) y alias institucionales: ningún dato de personas.
// - Organizaciones comunitarias FICTICIAS (es_simulado), ubicadas en comunas y barrios reales.
// - Idempotente: si la cuenta o el perfil ya existen, no los duplica.
// - Las contraseñas se generan al azar y se guardan SOLO en este equipo:
//   ~/.config/territorio-preparado/cuentas_demo_<ref>.csv (permisos 600). Nunca en el repo ni en la consola.
//
// Uso (las claves solo en la terminal; nunca en el repo ni en el chat):
//   cd db
//   export SUPABASE_URL=https://<ref>.supabase.co
//   read -rs SUPABASE_SERVICE_ROLE_KEY && export SUPABASE_SERVICE_ROLE_KEY
//   read -rs SUPABASE_ANON_KEY && export SUPABASE_ANON_KEY
//   npm run cuentas-demo                 # crea lo que falte y verifica
//   npm run cuentas-demo -- --rotar      # además cambia la contraseña de todas
//   unset SUPABASE_SERVICE_ROLE_KEY SUPABASE_ANON_KEY

import { randomBytes } from 'node:crypto';
import { mkdirSync, readFileSync, writeFileSync, existsSync, chmodSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';

// Organizaciones ficticias para las cuentas comunitarias (comunas con más espacios en zona inundable).
const ORGANIZACIONES = {
  jac_a:    { tipo: 'jac', nombre: 'JAC demo A (simulada)', comuna: '06', barrio: null },
  jac_b:    { tipo: 'jac', nombre: 'JAC demo B (simulada)', comuna: '05', barrio: null },
  conjunto: { tipo: 'propiedad_horizontal', nombre: 'Conjunto residencial demo (simulado)', comuna: '06', barrio: '0610' },
};

// Las 13 cuentas de db/docs/ROLES_Y_PERMISOS.md §3
export const CUENTAS = [
  { correo: 'plataforma.demo@example.org',   alias: 'Administración de plataforma (demo)', rol: 'superusuario' },
  { correo: 'sgred.demo@example.org',        alias: 'Secretaría de Gestión del Riesgo (demo)', rol: 'gestion_riesgo', entidad: 'SGRED', cargo: 'Secretario(a) de Gestión del Riesgo (demo)' },
  { correo: 'coordinacion.demo@example.org', alias: 'Coordinación de respuesta (demo)', rol: 'gestion_riesgo', entidad: 'SGRED', cargo: 'Coordinación de respuesta (demo)' },
  { correo: 'uaesp.demo@example.org',        alias: 'UAESP, saneamiento (demo)', rol: 'entidad_responsable', entidad: 'UAESP', cargo: 'Enlace de saneamiento UAESP (demo)' },
  { correo: 'emcali.demo@example.org',       alias: 'EMCALI, agua y energía (demo)', rol: 'entidad_responsable', entidad: 'EMCALI', cargo: 'Enlace de agua y energía EMCALI (demo)' },
  { correo: 'salud.demo@example.org',        alias: 'Salud Pública (demo)', rol: 'entidad_responsable', entidad: 'SALUD_PUBLICA', cargo: 'Enlace de Salud Pública (demo)' },
  { correo: 'bienestar.demo@example.org',    alias: 'Bienestar Social (demo)', rol: 'entidad_responsable', entidad: 'BIENESTAR_SOCIAL', cargo: 'Enlace de Bienestar Social (demo)' },
  { correo: 'datic.demo@example.org',        alias: 'DATIC soporte técnico (demo)', rol: 'datic_tecnico', entidad: 'DATIC', cargo: 'Soporte técnico DATIC (demo)' },
  { correo: 'jac-a.demo@example.org',        alias: 'Junta de acción comunal A (demo)', rol: 'comunitario', org: 'jac_a', zonaComunas: ['06'], cargo: 'Presidencia JAC A (demo)' },
  { correo: 'jac-b.demo@example.org',        alias: 'Junta de acción comunal B (demo)', rol: 'comunitario', org: 'jac_b', zonaComunas: ['05'], cargo: 'Presidencia JAC B (demo)' },
  { correo: 'conjunto.demo@example.org',     alias: 'Administración de conjunto residencial (demo)', rol: 'comunitario', org: 'conjunto', zonaBarrios: ['0610'], cargo: 'Administración del conjunto (demo)' },
  { correo: 'auditoria.demo@example.org',    alias: 'Control y auditoría (demo)', rol: 'auditor' },
  { correo: 'jurado.demo@example.org',       alias: 'Jurado y aliados (demo)', rol: 'consulta' },
];

const url = process.env.SUPABASE_URL?.replace(/\/$/, '');
const servicio = process.env.SUPABASE_SERVICE_ROLE_KEY;
const anon = process.env.SUPABASE_ANON_KEY;
if (!url || !servicio || !anon) {
  console.error('Faltan SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY o SUPABASE_ANON_KEY (defínelas solo en tu terminal).');
  process.exit(1);
}
const rotar = process.argv.includes('--rotar');
const ref = new URL(url).hostname.split('.')[0];
const carpeta = join(homedir(), '.config', 'territorio-preparado');
const archivo = join(carpeta, `cuentas_demo_${ref}.csv`);

async function pedir(ruta, { metodo = 'GET', clave = servicio, token = clave, cuerpo, perfil } = {}) {
  const r = await fetch(url + ruta, {
    method: metodo,
    headers: {
      apikey: clave, Authorization: `Bearer ${token}`, 'Content-Type': 'application/json',
      ...(perfil ? { 'Accept-Profile': perfil, 'Content-Profile': perfil } : {}),
    },
    body: cuerpo ? JSON.stringify(cuerpo) : undefined,
  });
  const texto = await r.text();
  const datos = texto ? JSON.parse(texto) : null;
  if (!r.ok) throw new Error(`${metodo} ${ruta.split('?')[0]} → ${r.status} ${datos?.msg ?? datos?.message ?? datos?.error_description ?? texto}`);
  return datos;
}
const rpc = (fn, args) => pedir(`/rest/v1/rpc/${fn}`, { metodo: 'POST', cuerpo: args, perfil: 'api' });
const contrasena = () => randomBytes(18).toString('base64url');   // 24 caracteres

// Contraseñas guardadas de corridas anteriores (para poder verificar sin rotarlas)
const guardadas = new Map();
if (existsSync(archivo)) {
  for (const linea of readFileSync(archivo, 'utf8').trim().split('\n').slice(1)) {
    const [correo, , , clave] = linea.split(',');
    guardadas.set(correo, clave);
  }
}

// 1. Usuarios existentes en Auth
const existentes = new Map();
for (let pagina = 1; ; pagina++) {
  const { users } = await pedir(`/auth/v1/admin/users?page=${pagina}&per_page=200`);
  for (const u of users) existentes.set(u.email, u);
  if (users.length < 200) break;
}

// 2. Organizaciones ficticias
const orgId = {};
for (const [k, o] of Object.entries(ORGANIZACIONES)) {
  orgId[k] = await rpc('asegurar_organizacion', {
    p_tipo: o.tipo, p_nombre: o.nombre, p_comuna: o.comuna, p_barrio: o.barrio, p_simulado: true,
  });
}

// 3. Cuentas y perfiles
const filas = [];
for (const c of CUENTAS) {
  let usuario = existentes.get(c.correo);
  let clave = guardadas.get(c.correo);
  let accion;
  if (!usuario) {
    clave = contrasena();
    usuario = await pedir('/auth/v1/admin/users', {
      metodo: 'POST',
      cuerpo: { email: c.correo, password: clave, email_confirm: true, app_metadata: { es_simulado: true } },
    });
    accion = 'creada';
  } else if (rotar || !clave) {
    clave = contrasena();
    await pedir(`/auth/v1/admin/users/${usuario.id}`, { metodo: 'PUT', cuerpo: { password: clave } });
    accion = 'contraseña nueva';
  } else {
    accion = 'ya existía';
  }
  const perfil = await rpc('provisionar_perfil', {
    p_user: usuario.id, p_rol: c.rol, p_alias: c.alias, p_entidad_codigo: c.entidad ?? null,
    p_organizacion_id: c.org ? orgId[c.org] : null, p_zona_comunas: c.zonaComunas ?? [],
    p_zona_barrios: c.zonaBarrios ?? [], p_cargo_nombre: c.cargo ?? null, p_simulado: true,
  });
  filas.push({ ...c, id: usuario.id, clave, accion, perfil });
}

// 4. Guardar las credenciales SOLO en este equipo
mkdirSync(carpeta, { recursive: true, mode: 0o700 });
writeFileSync(archivo, 'correo,rol,alias,contrasena\n' +
  filas.map((f) => [f.correo, f.rol, f.alias.replace(/,/g, ' '), f.clave].join(',')).join('\n') + '\n', { mode: 0o600 });
chmodSync(archivo, 0o600);

// 5. Verificar: iniciar sesión con cada cuenta y leer api.mi_perfil con su propio token
const decodificar = (jwt) => JSON.parse(Buffer.from(jwt.split('.')[1], 'base64url').toString());
console.log('\nCuenta                                         Rol                  Auth              Perfil     Sesión  Claim user_role');
let fallas = 0;
for (const f of filas) {
  let sesion = 'no', claim = '—';
  try {
    const t = await pedir('/auth/v1/token?grant_type=password', {
      metodo: 'POST', clave: anon, cuerpo: { email: f.correo, password: f.clave },
    });
    const [yo] = await pedir('/rest/v1/mi_perfil?select=rol,alias_visible,permisos', {
      clave: anon, token: t.access_token, perfil: 'api',
    });
    sesion = yo?.rol === f.rol ? 'ok' : `rol ${yo?.rol ?? 'ninguno'}`;
    claim = decodificar(t.access_token).user_role ?? 'sin hook';
  } catch (e) {
    sesion = 'error';
    claim = e.message.slice(0, 60);
  }
  if (sesion !== 'ok') fallas++;
  console.log(`${f.correo.padEnd(46)} ${f.rol.padEnd(20)} ${f.accion.padEnd(17)} ${f.perfil.padEnd(10)} ${sesion.padEnd(7)} ${claim}`);
}
console.log(`\nContraseñas guardadas en ${archivo} (solo lectura para tu usuario).`);
console.log(fallas ? `${fallas} cuenta(s) no verificaron.` : 'Las 13 cuentas inician sesión con su rol.');
console.log('MFA: superusuario y gestion_riesgo deben inscribir un factor TOTP al entrar para registrar decisiones o gestionar usuarios.');
process.exit(fallas ? 1 : 0);
