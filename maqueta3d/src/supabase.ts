import { createClient, type SupabaseClient } from "@supabase/supabase-js";

/**
 * Cliente de Supabase SOLO con la clave pública (publishable/anon): la seguridad la pone la base (RLS y funciones).
 * Si faltan las variables, la app funciona con los JSON estáticos (lo público sobrevive sin la base).
 * Variables en maqueta3d/.env.local (ignorado por git): VITE_SUPABASE_URL y VITE_SUPABASE_ANON_KEY.
 */
const url = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const key = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined;

export const supabase: SupabaseClient<any, "api"> | null =
  url && key ? createClient(url, key, { db: { schema: "api" } }) : null;
