/*
CO:
STEP 9Q – HB CANONICAL SEASON CONVENTION CHECK

K ČEMU:
Zjistit přesnou season konvenci pro sport, do kterého patří
canonical league 24881.

CÍL:
Rozhodnout, zda má HB season 2024 být například:
season_code  = 2024
season_label = 2024/2025

nebo jinak.

JAK:
Pouze SELECT.
*/


/* =========================================================
   1. SPORT_ID PRO LIGU 24881
   ========================================================= */

SELECT
    id AS league_id,
    sport_id,
    name
FROM public.leagues
WHERE id = 24881;


/* =========================================================
   2. SEZONY OSTATNÍCH LIG STEJNÉHO SPORTU
   ========================================================= */

SELECT
    l.id AS league_id,
    l.name,
    s.id AS season_id,
    s.season_code,
    s.season_label,
    s.start_date,
    s.end_date,
    s.is_current
FROM public.leagues l
JOIN public.seasons s
  ON s.league_id = l.id
WHERE l.sport_id = (
    SELECT sport_id
    FROM public.leagues
    WHERE id = 24881
)
ORDER BY
    l.id,
    s.season_code
LIMIT 100;


/* =========================================================
   3. KONVENCE SEASON 2024 V TOMTO SPORTU
   ========================================================= */

SELECT
    s.season_code,
    s.season_label,
    COUNT(*) AS rows_count,
    MIN(s.start_date) AS min_start,
    MAX(s.end_date) AS max_end
FROM public.seasons s
JOIN public.leagues l
  ON l.id = s.league_id
WHERE l.sport_id = (
    SELECT sport_id
    FROM public.leagues
    WHERE id = 24881
)
  AND s.season_code = '2024'
GROUP BY
    s.season_code,
    s.season_label
ORDER BY
    rows_count DESC,
    s.season_label;