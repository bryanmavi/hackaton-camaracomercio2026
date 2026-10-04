import { useCallback, useEffect, useState, type FormEvent } from "react";
import { supabase } from "./supabase";
import { useSession, type Perfil } from "./session";
import { requirements } from "./planning";
import type { Space } from "./types";

/**
 * Operación con la base de datos. La app solo muestra u oculta botones según los permisos que devuelve
 * api.mi_perfil; quien decide si algo se puede hacer es la base (RLS, funciones de `api` y MFA).
 */

const ROLES: Record<string, string> = {
  superusuario: "Administración de la plataforma",
  gestion_riesgo: "Gestión del riesgo",
  entidad_responsable: "Entidad responsable",
  datic_tecnico: "Soporte técnico DATIC",
  comunitario: "Red comunitaria",
  auditor: "Auditoría",
  consulta: "Consulta",
};
const ESTADOS_BRECHA = ["por_medir", "en_revision", "asignada", "en_ejecucion", "cerrada"];
const texto = (s: string) => s.replaceAll("_", " ");
const hoy = () => new Date().toISOString().slice(0, 10);
const num = (n: number | null | undefined, unidad = "") =>
  n === null || n === undefined ? "Sin dato" : `${new Intl.NumberFormat("es-CO").format(Number(n))}${unidad ? " " + unidad : ""}`;

interface Decision {
  id: string; espacio_id: string; espacio_nombre: string; amenaza_codigo: string; funcion: string;
  acto_tipo: string; acto_numero: string; acto_fecha: string; estado: string; personas_estimadas: number | null;
  cargo_nombre: string | null; es_simulado: boolean;
}
interface Brecha {
  id: string; decision_id: string; servicio_codigo: string; servicio_nombre: string; requerido: number | null;
  unidad: string | null; existente: number | null; faltante: number | null; entidad_codigo: string | null;
  estado: string; bloquea_activacion: boolean;
}
interface Tarea {
  id: number; decision_id: string; orden: number; titulo: string; entidad_codigo: string | null; estado: string;
  bloquea_activacion: boolean;
}

function useMensaje() {
  const [mensaje, setMensaje] = useState<{ tipo: "ok" | "error"; texto: string } | null>(null);
  const ejecutar = useCallback(async (accion: () => PromiseLike<{ error: { message: string } | null }>, exito: string) => {
    setMensaje(null);
    const { error } = await accion();
    setMensaje(error ? { tipo: "error", texto: error.message } : { tipo: "ok", texto: exito });
    return !error;
  }, []);
  return { mensaje, ejecutar, setMensaje };
}

function Aviso({ mensaje }: { mensaje: { tipo: "ok" | "error"; texto: string } | null }) {
  if (!mensaje) return null;
  return (
    <p role={mensaje.tipo === "error" ? "alert" : "status"} className={`op-aviso ${mensaje.tipo}`}>
      {mensaje.texto}
    </p>
  );
}

function IniciarSesion() {
  const [correo, setCorreo] = useState(""), [clave, setClave] = useState(""), [error, setError] = useState("");
  const [enviando, setEnviando] = useState(false);
  const entrar = async (e: FormEvent) => {
    e.preventDefault();
    setEnviando(true);
    const { error } = await supabase!.auth.signInWithPassword({ email: correo.trim(), password: clave });
    setEnviando(false);
    setError(error ? "No se pudo iniciar sesión: revisa el correo y la contraseña." : "");
  };
  return (
    <form className="op-card op-login" onSubmit={entrar}>
      <h3>Iniciar sesión</h3>
      <p className="small-note">
        Para entidades, red comunitaria y equipo técnico. Las cuentas de demostración son ficticias
        (<code>…demo@example.org</code>); pide la contraseña al responsable de la base de datos.
      </p>
      <label>
        Correo
        <input type="email" autoComplete="username" value={correo} onChange={(e) => setCorreo(e.target.value)} required />
      </label>
      <label>
        Contraseña
        <input type="password" autoComplete="current-password" value={clave} onChange={(e) => setClave(e.target.value)} required />
      </label>
      <button type="submit" disabled={enviando}>{enviando ? "Entrando…" : "Entrar"}</button>
      {error && <p role="alert" className="op-aviso error">{error}</p>}
    </form>
  );
}

/** Verificación en dos pasos (TOTP): inscribir el factor o subir la sesión a aal2 con un código. */
function DosPasos({ perfil, onListo }: { perfil: Perfil; onListo: () => void }) {
  const [factorId, setFactorId] = useState<string | null>(null);
  const [inscripcion, setInscripcion] = useState<{ id: string; qr: string; secreto: string } | null>(null);
  const [codigo, setCodigo] = useState("");
  const { mensaje, setMensaje } = useMensaje();

  useEffect(() => {
    supabase!.auth.mfa.listFactors().then(({ data }) => setFactorId(data?.totp[0]?.id ?? null));
  }, []);

  if (perfil.aal2)
    return <p className="op-aviso ok">Verificación en dos pasos activa en esta sesión.</p>;

  const inscribir = async () => {
    setMensaje(null);
    const { data: lista } = await supabase!.auth.mfa.listFactors();
    for (const f of lista?.all ?? []) if (f.status === "unverified") await supabase!.auth.mfa.unenroll({ factorId: f.id });
    const { data, error } = await supabase!.auth.mfa.enroll({ factorType: "totp", friendlyName: `Territorio Preparado ${Date.now()}` });
    if (error) return setMensaje({ tipo: "error", texto: `No se pudo iniciar la inscripción: ${error.message}. ¿Está activado el MFA TOTP en el proyecto?` });
    setInscripcion({ id: data.id, qr: data.totp.qr_code, secreto: data.totp.secret });
  };
  const verificar = async (e: FormEvent) => {
    e.preventDefault();
    const id = inscripcion?.id ?? factorId;
    if (!id) return;
    const { error } = await supabase!.auth.mfa.challengeAndVerify({ factorId: id, code: codigo.trim() });
    if (error) return setMensaje({ tipo: "error", texto: "Código no válido o vencido. Usa el código actual de tu aplicación." });
    setInscripcion(null);
    setCodigo("");
    setMensaje({ tipo: "ok", texto: "Verificación en dos pasos completada." });
    onListo();
  };

  return (
    <div className="op-card op-mfa">
      <h3>Verificación en dos pasos</h3>
      <p className="small-note">
        Tu rol exige un segundo factor para registrar decisiones o gestionar cuentas. Usa una aplicación de
        autenticación (Google Authenticator, Microsoft Authenticator, Aegis…).
      </p>
      {inscripcion ? (
        <div className="op-qr">
          <img src={inscripcion.qr} alt="Código QR para la aplicación de autenticación" width={180} height={180} />
          <p className="small-note">¿No puedes escanear? Escribe esta clave: <code>{inscripcion.secreto}</code></p>
        </div>
      ) : !factorId ? (
        <button onClick={inscribir}>Inscribir mi aplicación de autenticación</button>
      ) : null}
      {(inscripcion || factorId) && (
        <form onSubmit={verificar} className="op-inline">
          <label>
            Código de 6 dígitos
            <input inputMode="numeric" pattern="[0-9]{6}" maxLength={6} value={codigo} onChange={(e) => setCodigo(e.target.value)} required />
          </label>
          <button type="submit">Verificar</button>
        </form>
      )}
      <Aviso mensaje={mensaje} />
    </div>
  );
}

function RegistrarDecision({ espacio, onHecho }: { espacio: Space | null; onHecho: () => void }) {
  const [amenaza, setAmenaza] = useState("flood"), [funcion, setFuncion] = useState("albergue");
  const [funciones, setFunciones] = useState<{ codigo: string; nombre_es: string; amenazas_aplicables: string[] }[]>([]);
  const [personas, setPersonas] = useState(100), [actoTipo, setActoTipo] = useState("resolucion");
  const [actoNumero, setActoNumero] = useState(""), [actoFecha, setActoFecha] = useState(hoy());
  const [justificacion, setJustificacion] = useState("");
  const { mensaje, ejecutar } = useMensaje();

  useEffect(() => {
    supabase!.from("funciones_espacio").select("codigo,nombre_es,amenazas_aplicables").then(({ data }) => setFunciones(data ?? []));
  }, []);
  const aplicables = funciones.filter((f) => f.amenazas_aplicables.includes(amenaza));
  useEffect(() => {
    if (aplicables.length && !aplicables.some((f) => f.codigo === funcion)) setFuncion(aplicables[0].codigo);
  }, [amenaza, funciones]);

  if (!espacio)
    return <p className="small-note">Selecciona un espacio en el mapa para registrar una decisión de activación sobre él.</p>;

  const enviar = async (e: FormEvent) => {
    e.preventDefault();
    let necesidades;
    try {
      necesidades = requirements(personas);
    } catch (err) {
      return ejecutar(async () => ({ error: { message: (err as Error).message } }), "");
    }
    const ok = await ejecutar(
      () => supabase!.rpc("registrar_decision_activacion", {
        p_recomendacion: null, p_espacio: espacio.properties.id, p_amenaza: amenaza, p_funcion: funcion,
        p_acto_tipo: actoTipo, p_acto_numero: actoNumero.trim(), p_acto_fecha: actoFecha,
        p_justificacion: justificacion.trim(), p_personas_estimadas: personas,
        p_requerimientos: [
          { servicio: "toilets", requerido: necesidades.toilets },
          { servicio: "water", requerido: necesidades.water },
          { servicio: "shelter", requerido: necesidades.coveredArea },
        ],
        p_version_reglas: "maqueta3d planning.ts · Esfera 2018",
      }),
      "Decisión registrada. Se crearon sus brechas y las tareas del protocolo para cada entidad.",
    );
    if (ok) onHecho();
  };

  return (
    <form className="op-card" onSubmit={enviar}>
      <h3>Registrar decisión de activación</h3>
      <p className="small-note">
        Espacio: <strong>{espacio.properties.name}</strong> ({espacio.properties.id}). La recomendación no reemplaza a la
        autoridad: aquí se registra el acto administrativo que respalda la decisión.
      </p>
      <div className="planning-controls">
        <label>Amenaza
          <select value={amenaza} onChange={(e) => setAmenaza(e.target.value)}>
            <option value="flood">Inundación</option>
            <option value="earthquake">Sismo</option>
            <option value="drought">Sequía / El Niño</option>
            <option value="wildfire">Incendio forestal</option>
            <option value="building-fire">Incendio en edificación</option>
          </select>
        </label>
        <label>Función del espacio
          <select value={funcion} onChange={(e) => setFuncion(e.target.value)}>
            {aplicables.map((f) => <option key={f.codigo} value={f.codigo}>{f.nombre_es}</option>)}
          </select>
        </label>
        <label>Personas estimadas
          <input type="number" min={1} max={100000} value={personas} onChange={(e) => setPersonas(Number(e.target.value))} required />
        </label>
      </div>
      <div className="planning-controls">
        <label>Tipo de acto
          <select value={actoTipo} onChange={(e) => setActoTipo(e.target.value)}>
            <option value="resolucion">Resolución</option>
            <option value="decreto">Decreto</option>
            <option value="acta_cmgrd">Acta del Consejo Municipal</option>
            <option value="instruccion_secretaria">Instrucción de la Secretaría</option>
          </select>
        </label>
        <label>Número del acto
          <input value={actoNumero} onChange={(e) => setActoNumero(e.target.value)} placeholder="Ej. 4112.010.21.0001" required />
        </label>
        <label>Fecha del acto
          <input type="date" value={actoFecha} onChange={(e) => setActoFecha(e.target.value)} required />
        </label>
      </div>
      <label className="op-bloque">Justificación (obligatoria si no sale de una recomendación)
        <textarea value={justificacion} onChange={(e) => setJustificacion(e.target.value)} maxLength={500} rows={3}
          placeholder="Por qué se activa este espacio. Sin nombres, teléfonos ni datos de personas." />
      </label>
      <button type="submit">Registrar decisión</button>
      <Aviso mensaje={mensaje} />
    </form>
  );
}

function ReporteComunitario({ espacio, onHecho }: { espacio: Space | null; onHecho: () => void }) {
  const [tipo, setTipo] = useState("estado_espacio");
  const [g, setG] = useState({ n_0_5: 0, n_6_17: 0, n_18_59: 0, n_60_mas: 0 });
  const [servicios, setServicios] = useState<Record<string, string>>({ toilets: "sin_dato", water: "sin_dato" });
  const [animales, setAnimales] = useState(0), [observacion, setObservacion] = useState("");
  const { mensaje, ejecutar } = useMensaje();
  const total = g.n_0_5 + g.n_6_17 + g.n_18_59 + g.n_60_mas;
  const enviar = async (e: FormEvent) => {
    e.preventDefault();
    const ok = await ejecutar(
      () => supabase!.rpc("crear_reporte_comunitario", {
        p_tipo: tipo, p_espacio_id: espacio?.properties.id ?? null, p_n_total: total, ...Object.fromEntries(
          Object.entries(g).map(([k, v]) => [`p_${k}`, v])),
        p_n_animales_compania: animales, p_estado_servicios: servicios, p_observacion: observacion.trim() || null,
      }),
      "Reporte enviado. Solo se guardan conteos agregados.",
    );
    if (ok) onHecho();
  };
  return (
    <form className="op-card" onSubmit={enviar}>
      <h3>Reporte comunitario</h3>
      <p className="small-note">
        Solo conteos agregados: nunca nombres, documentos ni datos de menores.
        {espacio ? <> Espacio: <strong>{espacio.properties.name}</strong>.</> : " Selecciona un espacio en el mapa para reportar su estado."}
      </p>
      <div className="planning-controls">
        <label>Tipo
          <select value={tipo} onChange={(e) => setTipo(e.target.value)}>
            <option value="estado_espacio">Estado del espacio</option>
            <option value="necesidad">Necesidad</option>
            <option value="alerta_barrial">Alerta barrial</option>
          </select>
        </label>
        {(["n_0_5", "n_6_17", "n_18_59", "n_60_mas"] as const).map((k) => (
          <label key={k}>{{ n_0_5: "0 a 5 años", n_6_17: "6 a 17", n_18_59: "18 a 59", n_60_mas: "60 o más" }[k]}
            <input type="number" min={0} value={g[k]} onChange={(e) => setG({ ...g, [k]: Math.max(0, Number(e.target.value)) })} />
          </label>
        ))}
        <label>Animales de compañía
          <input type="number" min={0} value={animales} onChange={(e) => setAnimales(Math.max(0, Number(e.target.value)))} />
        </label>
      </div>
      <p className="small-note">Total de personas: <strong>{total}</strong> (la suma de los grupos).</p>
      <div className="planning-controls">
        {[["toilets", "Baños"], ["water", "Agua"]].map(([k, nombre]) => (
          <label key={k}>{nombre}
            <select value={servicios[k]} onChange={(e) => setServicios({ ...servicios, [k]: e.target.value })}>
              <option value="sin_dato">Sin dato</option>
              <option value="ok">Funciona</option>
              <option value="falla">Falla</option>
            </select>
          </label>
        ))}
      </div>
      <label className="op-bloque">Observación (opcional, máximo 280 caracteres)
        <textarea value={observacion} onChange={(e) => setObservacion(e.target.value)} maxLength={280} rows={2}
          placeholder="Sin nombres, teléfonos ni correos." />
      </label>
      <button type="submit" disabled={tipo === "estado_espacio" && !espacio}>Enviar reporte</button>
      <Aviso mensaje={mensaje} />
    </form>
  );
}

function CerrarRetorno({ decision, onHecho }: { decision: Decision; onHecho: () => void }) {
  const [abierto, setAbierto] = useState(false), [acta, setActa] = useState(""), [fecha, setFecha] = useState(hoy());
  const [lista, setLista] = useState({ espacio_limpio: false, kits_retirados: false, servicios_desconectados: false, entrega_firmada: false });
  const { mensaje, ejecutar } = useMensaje();
  if (!abierto) return <button className="text-button" onClick={() => setAbierto(true)}>Cerrar retorno</button>;
  return (
    <form className="op-retorno" onSubmit={async (e) => {
      e.preventDefault();
      if (await ejecutar(() => supabase!.rpc("cerrar_retorno", {
        p_decision: decision.id, p_checklist: lista, p_acta_ref: acta.trim(), p_fecha_retorno: fecha,
      }), "Retorno cerrado: el espacio vuelve a su uso cotidiano.")) onHecho();
    }}>
      {Object.entries(lista).map(([k, v]) => (
        <label key={k} className="op-check">
          <input type="checkbox" checked={v} onChange={(e) => setLista({ ...lista, [k]: e.target.checked })} /> {texto(k)}
        </label>
      ))}
      <label>Acta de entrega <input value={acta} onChange={(e) => setActa(e.target.value)} required /></label>
      <label>Fecha <input type="date" value={fecha} onChange={(e) => setFecha(e.target.value)} required /></label>
      <button type="submit">Confirmar retorno</button>
      <Aviso mensaje={mensaje} />
    </form>
  );
}

export default function Operacion({ espacio, onMap }: { espacio: Space | null; onMap: () => void }) {
  const { session, perfil, error, puede, recargar } = useSession();
  const [decisiones, setDecisiones] = useState<Decision[]>([]);
  const [brechas, setBrechas] = useState<Brecha[]>([]);
  const [tareas, setTareas] = useState<Tarea[]>([]);
  const [version, setVersion] = useState(0);
  const { mensaje, ejecutar } = useMensaje();
  const refrescar = () => setVersion((v) => v + 1);

  useEffect(() => {
    if (!perfil) return;
    Promise.all([
      supabase!.from("decisiones").select("*").order("decidida_en", { ascending: false }).limit(50),
      supabase!.from("brechas").select("*").limit(200),
      supabase!.from("mis_tareas").select("*").order("orden").limit(300),
    ]).then(([d, b, t]) => {
      setDecisiones((d.data as Decision[]) ?? []);
      setBrechas((b.data as Brecha[]) ?? []);
      setTareas((t.data as Tarea[]) ?? []);
    });
  }, [perfil, version]);

  if (!supabase)
    return <p className="notice">La operación necesita la base de datos; esta versión funciona solo con datos abiertos.</p>;
  if (!session)
    return (
      <section className="operacion">
        <IniciarSesion />
      </section>
    );

  return (
    <section className="operacion">
      <div className="op-card op-perfil">
        <div>
          <p className="eyebrow">SESIÓN</p>
          <h3>{perfil?.alias_visible ?? "Cargando perfil…"}</h3>
          {perfil && (
            <p className="small-note">
              {ROLES[perfil.rol] ?? perfil.rol}
              {perfil.entidad_nombre ? ` · ${perfil.entidad_nombre}` : ""}
              {perfil.zona_comunas.length ? ` · Comunas ${perfil.zona_comunas.join(", ")}` : ""}
              {perfil.zona_barrios.length ? ` · Barrios ${perfil.zona_barrios.join(", ")}` : ""}
            </p>
          )}
          {error && <p role="alert" className="op-aviso error">{error}</p>}
        </div>
        <button className="text-button" onClick={() => supabase!.auth.signOut()}>Cerrar sesión</button>
      </div>

      {perfil?.mfa_requerido && <DosPasos perfil={perfil} onListo={recargar} />}

      {perfil && puede("decision.activar") && (
        perfil.aal2 ? <RegistrarDecision espacio={espacio} onHecho={refrescar} />
          : <p className="small-note">Completa la verificación en dos pasos para registrar decisiones.</p>
      )}
      {perfil && puede("reporte.crear") && <ReporteComunitario espacio={espacio} onHecho={refrescar} />}
      {perfil && !espacio && (puede("decision.activar") || puede("reporte.crear")) && (
        <button className="text-button" onClick={onMap}>Ir al mapa para elegir un espacio</button>
      )}

      {perfil && puede("operativo.leer") && (
        <>
          <Aviso mensaje={mensaje} />
          <div className="op-card">
            <h3>Decisiones de activación ({decisiones.length})</h3>
            {decisiones.length === 0 ? <p className="small-note">No hay decisiones visibles para tu rol.</p> : (
              <div className="table-scroll"><table className="gap-table">
                <thead><tr><th>Espacio</th><th>Amenaza y función</th><th>Acto</th><th>Estado</th><th></th></tr></thead>
                <tbody>{decisiones.map((d) => (
                  <tr key={d.id}>
                    <td>{d.espacio_nombre}<br /><small>{d.espacio_id}{d.es_simulado ? " · SIMULADO" : ""}</small></td>
                    <td>{d.amenaza_codigo} · {texto(d.funcion)}<br /><small>{num(d.personas_estimadas, "personas")}</small></td>
                    <td>{texto(d.acto_tipo)} {d.acto_numero}<br /><small>{d.acto_fecha}</small></td>
                    <td>{texto(d.estado)}</td>
                    <td>{puede("retorno.cerrar") && d.estado !== "cerrada" && <CerrarRetorno decision={d} onHecho={refrescar} />}</td>
                  </tr>))}
                </tbody>
              </table></div>
            )}
          </div>
          {brechas.length > 0 && (
            <div className="op-card">
              <h3>Brechas ({brechas.length})</h3>
              <div className="table-scroll"><table className="gap-table">
                <thead><tr><th>Servicio</th><th>Requerido</th><th>Existente</th><th>Faltante</th><th>Responsable</th><th>Estado</th></tr></thead>
                <tbody>{brechas.map((b) => {
                  const siguiente = ESTADOS_BRECHA[ESTADOS_BRECHA.indexOf(b.estado) + 1];
                  return (
                    <tr key={b.id}>
                      <td>{b.servicio_nombre}{b.bloquea_activacion && <><br /><small>Bloquea la activación</small></>}</td>
                      <td>{num(b.requerido, b.unidad ?? "")}</td>
                      <td>{num(b.existente)}</td>
                      <td>{num(b.faltante)}</td>
                      <td>{b.entidad_codigo ?? "Sin asignar"}</td>
                      <td>{texto(b.estado)}{puede("brecha.actualizar") && siguiente && (
                        <><br /><button className="text-button" onClick={async () => {
                          if (await ejecutar(() => supabase!.rpc("actualizar_brecha", { p_brecha: b.id, p_estado: siguiente }),
                            `Brecha "${b.servicio_nombre}" pasó a ${texto(siguiente)}.`)) refrescar();
                        }}>Avanzar a {texto(siguiente)}</button></>)}
                      </td>
                    </tr>);
                })}</tbody>
              </table></div>
            </div>
          )}
          {tareas.length > 0 && (
            <div className="op-card">
              <h3>Tareas del protocolo ({tareas.length})</h3>
              <ol className="op-tareas">{tareas.map((t) => (
                <li key={t.id}>
                  <span><strong>{t.titulo}</strong> · {t.entidad_codigo ?? "Entidad por definir"}{t.bloquea_activacion ? " · bloquea" : ""}</span>
                  <span>{texto(t.estado)}{puede("tarea.completar") && ["pendiente", "en_curso"].includes(t.estado) && (
                    <> · <button className="text-button" onClick={async () => {
                      if (await ejecutar(() => supabase!.rpc("completar_tarea", { p_tarea: t.id, p_estado: "completada" }),
                        `Tarea "${t.titulo}" completada.`)) refrescar();
                    }}>Completar</button></>)}
                  </span>
                </li>))}
              </ol>
            </div>
          )}
        </>
      )}
      {perfil && puede("operativo.leer_agregado") && (
        <p className="small-note">Tu rol consulta solo agregados por comuna; no ves decisiones ni brechas individuales.</p>
      )}
    </section>
  );
}
