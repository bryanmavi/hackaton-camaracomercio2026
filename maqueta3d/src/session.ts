import { useCallback, useEffect, useState } from "react";
import type { Session } from "@supabase/supabase-js";
import { supabase } from "./supabase";

/** Lo que devuelve api.mi_perfil: el rol y los permisos los decide la base, no la app. */
export interface Perfil {
  user_id: string;
  rol: string;
  cargo: string | null;
  entidad_codigo: string | null;
  entidad_nombre: string | null;
  organizacion_id: number | null;
  zona_comunas: string[];
  zona_barrios: string[];
  alias_visible: string;
  mfa_requerido: boolean;
  aal2: boolean;
  permisos: string[];
}

export function useSession() {
  const [session, setSession] = useState<Session | null>(null);
  const [perfil, setPerfil] = useState<Perfil | null>(null);
  const [error, setError] = useState("");
  const [version, setVersion] = useState(0);

  useEffect(() => {
    if (!supabase) return;
    supabase.auth.getSession().then(({ data }) => setSession(data.session));
    // No llamar a supabase dentro del callback (recomendación de supabase-js): solo se guarda la sesión.
    const { data } = supabase.auth.onAuthStateChange((_evento, s) => setSession(s));
    return () => data.subscription.unsubscribe();
  }, []);

  useEffect(() => {
    if (!supabase || !session) {
      setPerfil(null);
      return;
    }
    let vigente = true;
    supabase
      .from("mi_perfil")
      .select("*")
      .maybeSingle()
      .then(({ data, error }) => {
        if (!vigente) return;
        setError(error ? error.message : data ? "" : "Tu cuenta no tiene un perfil activo en la plataforma.");
        setPerfil((data as Perfil) ?? null);
      });
    return () => {
      vigente = false;
    };
  }, [session, version]);

  const puede = useCallback((permiso: string) => !!perfil?.permisos.includes(permiso), [perfil]);
  const recargar = useCallback(() => setVersion((v) => v + 1), []);
  return { session, perfil, error, puede, recargar };
}
