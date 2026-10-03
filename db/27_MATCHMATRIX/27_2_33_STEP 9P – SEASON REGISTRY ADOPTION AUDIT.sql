/*
CO:
STEP 9P – CANONICAL SEASON REGISTRY ADOPTION AUDIT

K ČEMU:
Zjistit, zda a jak je public.seasons skutečně používána
napříč MatchMatrix.

CÍL:
Před vytvořením HB season recordu zjistit:
- kolik sezon již existuje,
- pro které sporty / ligy,
- jaké jsou season_code / season_label konvence,
- zda existují duplicity,
- zda DB objekty nebo funkce public.seasons aktivně používají.

KDE:
Databáze matchmatrix.

JAK:
Pouze SELECT.
*/


/* =========================================================
   1. CELKOVÝ STAV PUBLIC.SEASONS
   ========================================================= */

SELECT
    COUNT(*) AS total_seasons,
    COUNT(DISTINCT league_id) AS distinct_leagues,
    MIN(start_date) AS oldest_start_date,
    MAX(end_date) AS newest_end_date,
    COUNT(*) FILTER (WHERE is_current = true) AS current_seasons
FROM public.seasons;


/* =========================================================
   2. UKÁZKA EXISTUJÍCÍCH SEZON
   ========================================================= */

SELECT
    id,
    league_id,
    season_code,
    season_label,
    start_date,
    end_date,
    is_current
FROM public.seasons
ORDER BY id
LIMIT 50;


/* =========================================================
   3. KONVENCE SEASON_CODE / SEASON_LABEL
   ========================================================= */

SELECT
    season_code,
    season_label,
    COUNT(*) AS rows_count
FROM public.seasons
GROUP BY
    season_code,
    season_label
ORDER BY
    rows_count DESC,
    season_code,
    season_label
LIMIT 100;


/* =========================================================
   4. DUPLICITY LEAGUE × SEASON_CODE
   ========================================================= */

SELECT
    league_id,
    season_code,
    COUNT(*) AS rows_count
FROM public.seasons
GROUP BY
    league_id,
    season_code
HAVING COUNT(*) > 1
ORDER BY
    rows_count DESC,
    league_id,
    season_code;


/* =========================================================
   5. LIGY SE SEZONAMI + SPORT_ID
   ========================================================= */

SELECT
    l.sport_id,
    s.league_id,
    COUNT(*) AS season_rows,
    MIN(s.season_code) AS min_season_code,
    MAX(s.season_code) AS max_season_code
FROM public.seasons s
JOIN public.leagues l
  ON l.id = s.league_id
GROUP BY
    l.sport_id,
    s.league_id
ORDER BY
    l.sport_id,
    s.league_id;


/* =========================================================
   6. SOUHRN PODLE SPORT_ID
   ========================================================= */

SELECT
    l.sport_id,
    COUNT(*) AS season_rows,
    COUNT(DISTINCT s.league_id) AS leagues_with_seasons
FROM public.seasons s
JOIN public.leagues l
  ON l.id = s.league_id
GROUP BY
    l.sport_id
ORDER BY
    l.sport_id;


/* =========================================================
   7. DB VIEWS, KTERÉ PUBLIC.SEASONS POUŽÍVAJÍ
   ========================================================= */

SELECT
    schemaname,
    viewname,
    definition
FROM pg_views
WHERE definition ILIKE '%public.seasons%'
   OR definition ILIKE '% seasons %'
ORDER BY
    schemaname,
    viewname;


/* =========================================================
   8. FUNKCE / PROCEDURY S ODKAZEM NA PUBLIC.SEASONS
   ========================================================= */

SELECT
    n.nspname AS schema_name,
    p.proname AS routine_name,
    p.prokind AS routine_kind
FROM pg_proc p
JOIN pg_namespace n
  ON n.oid = p.pronamespace
WHERE p.prokind IN ('f', 'p')
  AND pg_get_functiondef(p.oid) ILIKE '%public.seasons%'
ORDER BY
    n.nspname,
    p.proname;


/* =========================================================
   9. FK, KTERÉ ODKAZUJÍ NA PUBLIC.SEASONS
   ========================================================= */

SELECT
    n.nspname AS referencing_schema,
    c.relname AS referencing_table,
    con.conname AS constraint_name,
    pg_get_constraintdef(con.oid, true) AS definition
FROM pg_constraint con
JOIN pg_class c
  ON c.oid = con.conrelid
JOIN pg_namespace n
  ON n.oid = c.relnamespace
WHERE con.contype = 'f'
  AND con.confrelid = 'public.seasons'::regclass
ORDER BY
    n.nspname,
    c.relname,
    con.conname;