import { useMemo, useState, useEffect, useRef, lazy, Suspense } from "react";
import type { Space, Territory } from "./types";
import { formatNumber as fmt } from "./types";
import {
  compareCandidates,
  eligibility,
  gaps,
  geometryArea,
  requirements,
  planningRules,
  type ScenarioThreat,
} from "./planning";
import { site, planningView } from "./data/site";
import GoogleMapsLinks from "./GoogleMapsLinks";
import AcopioNotice from "./AcopioNotice";
import AcopioCapacity from "./AcopioCapacity";
import { preparationReport } from "./preparationReport";
import {
  acopioCapacity,
  emptyAcopioInputs,
  type AcopioInputs,
} from "./calculateAcopioCapacity";
import { isFire, firePreparation, fireSources, fireLimitations } from "./fire";
const SelectedSpaceScene = lazy(() => import("./SelectedSpaceScene"));
type Followup = "Por medir" | "En revisión";
const fechaVerificacion = (value?: string | null) => {
  if (!value) return "fecha no disponible";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "fecha no disponible";
  return new Intl.DateTimeFormat("es-CO", {
    dateStyle: "medium",
    timeZone: "UTC",
  }).format(date);
};
const estadoAnimal = (value?: boolean | null, validadoEn?: string | null) =>
  value == null
    ? "Sin dato verificado"
    : `${value ? "Sí" : "No"} · verificado el ${fechaVerificacion(validadoEn)}`;
const capacidadAnimal = (value?: number | null, validadoEn?: string | null) =>
  value == null
    ? "Sin dato verificado"
    : `${fmt(value)} animales · verificado el ${fechaVerificacion(validadoEn)}`;
export default function Intervention({
  data,
  origin,
  scope,
  scopeLabel,
  onMap,
}: {
  data: Territory;
  origin: Space | null;
  scope: Space[];
  scopeLabel: string;
  onMap: () => void;
}) {
  const [threat, setThreat] = useState<ScenarioThreat>("flood");
  const [people, setPeople] = useState(String(site.scenario.people.value));
  const [targetId, setTargetId] = useState(origin?.properties.id ?? "");
  const [acopio, setAcopio] = useState<{
    key: string;
    inputs: AcopioInputs;
    included: boolean;
  }>({ key: "", inputs: emptyAcopioInputs, included: false });
  useEffect(() => {
    setAcopio({ key: "", inputs: emptyAcopioInputs, included: false });
  }, [targetId, threat]);
  const targetHeading = useRef<HTMLHeadingElement>(null);
  const [reviewRequest, setReviewRequest] = useState(0);
  const reviewSpace = (id: string) => {
    setTargetId(id);
    // Una nueva acción incluso cuando el espacio ya estaba seleccionado.
    setReviewRequest((n) => n + 1);
  };
  useEffect(() => {
    if (!reviewRequest) return;
    targetHeading.current?.focus({ preventScroll: true });
    targetHeading.current?.scrollIntoView({ block: "start", behavior: "auto" });
  }, [reviewRequest]);
  const [followup, setFollowup] = useState<Record<string, Followup>>(() => {
    try {
      const saved = JSON.parse(
        localStorage.getItem("cali-activa-followup-v1") ?? "{}",
      );
      return Object.fromEntries(
        Object.entries(saved).filter(
          ([key, value]) =>
            /^(epou|deporte)-[\w-]+:(toilets|water|shelter|(?:wildfire|building-fire)-(?:perimeter|access|vegetation|smoke|building|inspection))$/.test(
              key,
            ) &&
            (value === "Por medir" || value === "En revisión"),
        ),
      ) as Record<string, Followup>;
    } catch {
      return {};
    }
  });
  const [savedLocally, setSavedLocally] = useState(true);
  useEffect(() => {
    try {
      localStorage.setItem("cali-activa-followup-v1", JSON.stringify(followup));
      setSavedLocally(true);
    } catch {
      setSavedLocally(false);
    }
  }, [followup]);
  const target =
    data.spaces.features.find((s) => s.properties.id === targetId) ?? origin;
  const count = Number(people);
  let problem = "";
  try {
    requirements(count);
  } catch (e) {
    problem = (e as Error).message;
  }
  const result = useMemo(
    () => (origin ? compareCandidates(scope, origin, threat) : null),
    [scope, origin, threat],
  );
  if (!origin || !target || !result)
    return (
      <section className="notice">
        <h2>Preparar una intervención</h2>
        <p>
          Selecciona un espacio del mapa para usar su ubicación como referencia
          y comparar candidatos en el sector.
        </p>
        <button onClick={onMap}>Volver al mapa</button>
      </section>
    );
  const p = target.properties,
    decision = eligibility(target, threat),
    rows = problem ? [] : gaps(target, count),
    area = geometryArea(target);
  const acopioKey = p.id + ":" + threat;
  const acopioInputs =
    acopio.key === acopioKey ? acopio.inputs : emptyAcopioInputs;
  const acopioResult = acopioCapacity(area, acopioInputs);
  const acopioIncluded =
    acopio.key === acopioKey &&
    acopio.included &&
    acopioResult.status === "fits" &&
    !decision.excluded;
  const fireRows = isFire(threat) ? firePreparation(threat) : [];
  const fireReview = fireRows.map((r) => ({
    ...r,
    followup: followup[`${p.id}:${threat}-${r.id}`] ?? "Por medir",
  }));
  const exportPlan = (technical = false) => {
    if (problem) return;
    const payload = {
      kind: "Borrador de preparación; no autorización",
      scenario: { threat, people: count, status: "SIMULADO" },
      originId: origin.properties.id,
      targetId: p.id,
      scope: scopeLabel,
      candidates: result.candidates.map((c) => ({
        id: c.space.properties.id,
        distanceM: Math.round(c.distanceM),
        reason: c.reason,
      })),
      decision,
      acopio: {
        ...acopioResult,
        includedInDraft: acopioIncluded,
        activationAuthorized: false,
        areaSource:
          "Polígono público del espacio seleccionado; cálculo Turf en m²",
        rule: "Huella menos exclusiones, circulación, atención y otros usos; módulos enteros según huella por unidad",
        limitation:
          "Balance de área SIMULADO, no aforo ni encaje geométrico ni capacidad operacional verificada",
      },
      screening: {
        considered: result.considered,
        excludedByIntersection: result.excluded,
        pendingEvidence: result.pendingEvidence,
      },
      ...(isFire(threat)
        ? {
            fire: {
              subtype: threat,
              evidence: fireReview,
              limitations: fireLimitations,
              sources: fireSources,
              authorityValidation: "Fuera de esta etapa; no realizada",
            },
          }
        : {}),
      gaps: rows.map((r) => ({
        ...r,
        followup: followup[`${p.id}:${r.id}`] ?? "Por medir",
      })),
      sources: data.manifest.sources,
      planningRules,
      warning:
        "No se conoce disponibilidad, aforo, superficie útil ni evaluación estructural. Responsables propuestos, sin validación con entidades.",
    };
    const report = preparationReport({
      generatedAt: new Date().toISOString(),
      origin: origin.properties,
      target: p,
      scope: scopeLabel,
      threat,
      people: count,
      decision,
      comparison: result,
      gaps: payload.gaps,
      acopio: payload.acopio,
      fire: fireReview,
      fireLimitations: isFire(threat) ? fireLimitations : [],
      fireSources: isFire(threat) ? fireSources : [],
      manifest: data.manifest,
    });
    const url = URL.createObjectURL(
      new Blob([technical ? JSON.stringify(payload, null, 2) : report], {
        type: technical ? "application/json" : "text/html;charset=utf-8",
      }),
    );
    const a = document.createElement("a");
    a.href = url;
    a.download = `preparacion-${p.id}.${technical ? "json" : "html"}`;
    a.click();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  };
  return (
    <section className="intervention">
      <p className="eyebrow">DEL ESPACIO A LA PREPARACIÓN</p>
      <h2>Preparar una intervención</h2>
      <p>
        Referencia de cercanía: <strong>{origin.properties.name}</strong> ·{" "}
        {origin.properties.id}. Elige un candidato para adaptar su huella y
        revisar necesidades.
      </p>
      <p>
        <strong>Sector comparado:</strong> {scopeLabel}. La población modifica
        las necesidades; no cambia el orden porque no hay aforos confirmados.
      </p>
      <div className="planning-controls">
        <label>
          Amenaza del escenario
          <select
            value={threat}
            onChange={(e) => setThreat(e.target.value as ScenarioThreat)}
          >
            <option value="flood">Inundación</option>
            <option value="earthquake">Sismo</option>
            <option value="drought">Sequía (sin datos suficientes)</option>
            <option value="wildfire">Incendio forestal</option>
            <option value="building-fire">Incendio en edificación</option>
          </select>
        </label>
        <label>
          Personas del escenario SIMULADO
          <input
            type="number"
            min="1"
            max={planningView.maximumPeople}
            step="1"
            value={people}
            onChange={(e) => setPeople(e.target.value)}
          />
        </label>
      </div>
      {problem && <p role="alert">{problem}</p>}
      {isFire(threat) && (
        <section className="fire-panel" aria-label="Preparación ante incendio">
          <h3>
            {threat === "wildfire"
              ? "Incendio forestal"
              : "Incendio en edificación"}
            : preparación con evidencia pendiente
          </h3>
          <p>
            El mapa conserva el inventario real de Cali. No se muestran focos,
            perímetros ni zonas seguras inventados. El espacio seleccionado es
            una referencia para preparar la atención de la población, no una
            ubicación confirmada del incendio.
          </p>
          <h4>Información necesaria para evaluar este espacio</h4>
          <p>
            Lista propuesta por el equipo, no protocolo oficial. “En revisión”
            guarda una tarea local; no acredita evidencia ni habilita
            recomendaciones. La validación con entidades permanece fuera de esta
            etapa.
          </p>
          <ul className="fire-evidence">
            {fireReview.map((r) => (
              <li key={r.id}>
                <strong>{r.label}</strong>
                <p>{r.detail}</p>
                <p>{r.status}</p>
                <label>
                  Seguimiento de {r.label}
                  <select
                    value={r.followup}
                    onChange={(e) =>
                      setFollowup({
                        ...followup,
                        [`${p.id}:${threat}-${r.id}`]: e.target
                          .value as Followup,
                      })
                    }
                  >
                    <option>Por medir</option>
                    <option>En revisión</option>
                  </select>
                </label>
              </li>
            ))}
          </ul>
          <ul>
            {fireLimitations.map((text) => (
              <li key={text}>{text}</li>
            ))}
          </ul>
          <p>
            Fuentes de contexto institucional; no contienen una evaluación de
            este espacio:
          </p>
          <ul>
            {fireSources.map((source) => (
              <li key={source.url}>
                <a href={source.url} target="_blank" rel="noreferrer">
                  {source.title} ↗
                </a>
              </li>
            ))}
          </ul>
        </section>
      )}
      <div className="notice">
        <strong>Preselección para revisión, no espacios habilitados.</strong> Se
        consideran {result.considered} polígonos EPOU del sector;{" "}
        {result.excluded} quedan fuera por cruces de amenaza;{" "}
        {result.pendingEvidence} no pueden evaluarse por falta de evidencia. Los
        candidatos, cuando existen, se ordenan por distancia recta al punto de
        referencia; empate por ID. No se evalúa capacidad, tránsito, acceso ni
        disponibilidad. Los filtros de búsqueda, fuente y cruce del mapa no
        ocultan candidatos de esta comparación.
      </div>
      {result.candidates.length ? (
        <div className="candidate-grid">
          {result.candidates.map((c, i) => (
            <article key={c.space.properties.id}>
              <span>
                {i + 1} · {fmt(Math.round(c.distanceM))} m en línea recta
              </span>
              <h3>{c.space.properties.name}</h3>
              <p>{c.reason}</p>
              <p>Capacidad y servicios: sin confirmar.</p>
              <button
                aria-pressed={targetId === c.space.properties.id}
                aria-controls="planning-space-detail"
                onClick={() => reviewSpace(c.space.properties.id)}
              >
                Revisar {c.space.properties.id}
              </button>
            </article>
          ))}
        </div>
      ) : (
        <p role="status">
          No hay candidatos para esta amenaza en el sector. No se sustituyen por
          espacios descartados.{" "}
          {result.pendingEvidence > 0
            ? "Ampliar el sector no resuelve la falta de evidencia para esta amenaza."
            : "Puedes ampliar el sector en el mapa."}
        </p>
      )}
      <button
        className="text-button"
        aria-controls="planning-space-detail"
        onClick={() => reviewSpace(origin.properties.id)}
      >
        Revisar el espacio de referencia
      </button>
      <section
        className="planning-target"
        id="planning-space-detail"
        aria-labelledby="planning-space-title"
      >
        <h2 id="planning-space-title" ref={targetHeading} tabIndex={-1}>
          {p.name}
        </h2>
        <p>
          {p.id} · Comuna {p.commune ?? "sin asignar"} ·{" "}
          {p.neighborhood ?? "sector sin asignar"}
        </p>
        <p className="notice">{decision.reason}</p>
        <GoogleMapsLinks coordinates={p.coordinates} />
        <p>
          Huella cartográfica:{" "}
          {area === null ? "sin polígono" : `${fmt(Math.round(area))} m²`}. No
          equivale a área cubierta, libre ni aforo.
        </p>
        <div className="notice">
          <h3>Condiciones verificadas para animales de compañía</h3>
          <dl>
            <div>
              <dt>¿Admite animales de compañía?</dt>
              <dd>
                {estadoAnimal(
                  p.acepta_animales_compania,
                  p.acepta_animales_compania_validado_en,
                )}
              </dd>
            </div>
            <div>
              <dt>¿Tiene zona separada para animales?</dt>
              <dd>
                {estadoAnimal(
                  p.zona_animales,
                  p.zona_animales_validado_en,
                )}
              </dd>
            </div>
            <div>
              <dt>Capacidad para animales</dt>
              <dd>
                {capacidadAnimal(
                  p.capacidad_animales,
                  p.capacidad_animales_validado_en,
                )}
              </dd>
            </div>
          </dl>
          <p className="small-note">
            Estos datos informan la revisión del espacio; no determinan su
            aptitud ni modifican el orden de los candidatos.
          </p>
        </div>
        <Suspense fallback={<p>Cargando la huella seleccionada…</p>}>
          <SelectedSpaceScene space={target} />
        </Suspense>
      </section>
      <AcopioCapacity
        area={area}
        inputs={acopioInputs}
        included={acopioIncluded}
        blocked={decision.excluded}
        onChange={(inputs) =>
          setAcopio({ key: acopioKey, inputs, included: false })
        }
        onInclude={() => {
          if (acopioResult.status === "fits" && !decision.excluded)
            setAcopio({ key: acopioKey, inputs: acopioInputs, included: true });
        }}
      />
      <AcopioNotice key={p.id} space={target} />
      <h3>Necesidades y brechas por medir</h3>
      <p>
        Conteo SIMULADO. Los servicios desconocidos no se convierten en cero:
        aún no se pueden calcular faltantes reales. La asignación de
        responsables es la propuesta del equipo; validación con entidades fuera
        de esta etapa.
      </p>
      {!problem && (
        <div className="table-scroll">
          <table className="gap-table">
            <thead>
              <tr>
                <th>Servicio</th>
                <th>Necesidad de referencia</th>
                <th>Existencia</th>
                <th>Brecha</th>
                <th>Responsable propuesto</th>
                <th>Seguimiento local</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.id}>
                  <td>
                    <strong>{r.label}</strong>
                    <p>{r.rule}</p>
                  </td>
                  <td>
                    {fmt(r.required)} {r.unit}
                  </td>
                  <td>{r.existing === null ? "Sin dato" : fmt(r.existing)}</td>
                  <td>
                    {r.missing === null ? "No calculable" : fmt(r.missing)}
                  </td>
                  <td>{r.responsible}</td>
                  <td>
                    <select
                      aria-label={`Seguimiento de ${r.label}`}
                      value={followup[`${p.id}:${r.id}`] ?? "Por medir"}
                      onChange={(e) =>
                        setFollowup({
                          ...followup,
                          [`${p.id}:${r.id}`]: e.target.value as Followup,
                        })
                      }
                    >
                      <option>Por medir</option>
                      <option>En revisión</option>
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      <p>
        Evaluación estructural, accesibilidad y energía: sin evidencia
        suficiente. No se emiten conceptos ni se activa el espacio.
      </p>
      <p>
        <a href={planningRules.sphereSource} target="_blank" rel="noreferrer">
          Referencias Esfera 2018 ↗
        </a>
        : contextualizar agua, saneamiento y área cubierta; las cifras no
        certifican cumplimiento. El requisito de agua incluye necesidades
        básicas y no se interpreta íntegramente como uso no potable.
      </p>
      <p className="small-note">
        {data.manifest.attribution}. Consulta:{" "}
        <a
          href={
            data.manifest.sources.find(
              (s) =>
                s.key ===
                (p.sourceKey === "sports" ? "sports" : "publicSpaces"),
            )?.page
          }
          target="_blank"
          rel="noreferrer"
        >
          fuente primaria del espacio ↗
        </a>
        . Datos archivados el {data.manifest.snapshotDate}.
      </p>
      <button disabled={!!problem} onClick={() => exportPlan()}>
        Descargar informe de preparación
      </button>
      <p className="small-note">
        Documento legible con necesidades, kit, responsables y pendientes.
        Abre el archivo descargado en tu navegador y usa «Imprimir / guardar como PDF».
      </p>
      <details>
        <summary>Datos para integración técnica</summary>
        <button disabled={!!problem} onClick={() => exportPlan(true)}>
          Descargar datos técnicos (JSON)
        </button>
      </details>
      <p className="small-note">
        {savedLocally
          ? "Seguimiento guardado localmente en este navegador."
          : "No se pudo guardar localmente: descarga el borrador antes de salir."}{" "}
        No se guardan personas ni se envían comunicaciones.
      </p>
    </section>
  );
}
