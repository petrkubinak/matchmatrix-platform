-- 002_find_hb_leagues_merge_logic_fixed.sql
-- Opravená verze: filtrujeme jen běžné funkce/procedury, ne agregace

-- 1) kandidátní funkce/procedury obsahující public.leagues
SELECT
    n.nspname AS schema_name,
    p.proname AS object_name,
    p.prokind,
    pg_get_functiondef(p.oid) AS definition
FROM pg_proc p
JOIN pg_namespace n
  ON n.oid = p.pronamespace
WHERE p.prokind IN ('f', 'p')
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
  AND pg_get_functiondef(p.oid) ILIKE '%public.leagues%'
ORDER BY 1, 2;

-- 2) kandidátní funkce/procedury obsahující league_provider_map
SELECT
    n.nspname AS schema_name,
    p.proname AS object_name,
    p.prokind,
    pg_get_functiondef(p.oid) AS definition
FROM pg_proc p
JOIN pg_namespace n
  ON n.oid = p.pronamespace
WHERE p.prokind IN ('f', 'p')
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
  AND pg_get_functiondef(p.oid) ILIKE '%league_provider_map%'
ORDER BY 1, 2;

-- 3) kandidátní funkce/procedury obsahující is_active + league merge logiku
SELECT
    n.nspname AS schema_name,
    p.proname AS object_name,
    p.prokind,
    pg_get_functiondef(p.oid) AS definition
FROM pg_proc p
JOIN pg_namespace n
  ON n.oid = p.pronamespace
WHERE p.prokind IN ('f', 'p')
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
  AND pg_get_functiondef(p.oid) ILIKE '%is_active%'
  AND (
      pg_get_functiondef(p.oid) ILIKE '%stg_provider_leagues%'
      OR pg_get_functiondef(p.oid) ILIKE '%public.leagues%'
      OR pg_get_functiondef(p.oid) ILIKE '%league_provider_map%'
  )
ORDER BY 1, 2;

-- 4) triggery nad public.leagues
SELECT
    event_object_schema,
    event_object_table,
    trigger_name,
    action_timing,
    event_manipulation,
    action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'public'
  AND event_object_table = 'leagues'
ORDER BY trigger_name;

-- 5) triggery nad public.league_provider_map
SELECT
    event_object_schema,
    event_object_table,
    trigger_name,
    action_timing,
    event_manipulation,
    action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'public'
  AND event_object_table = 'league_provider_map'
ORDER BY trigger_name;