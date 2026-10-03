/*
CO:
STEP 9S – FOOTBALL EXACT COVERAGE COMPLEXITY AUDIT

K ČEMU:
Použít historicky nejbohatší sport – fotbal – jako stress test
pro návrh budoucího exact coverage child registru.

CÍL:
Zjistit reálné kolize a složitější vztahy:

- canonical league × více providerů,
- provider league × canonical league,
- league × více season records,
- různé season_code / season_label konvence,
- provider × league × season multiplicity,
- potenciální konflikty, které HB kvůli malému objemu neukazuje.

DŮLEŽITÉ:
Pouze READ ONLY.
Žádný INSERT / UPDATE / DELETE / DDL.
*/


/* =========================================================
   1. IDENTIFIKACE FOTBALU
   ========================================================= */

SELECT
    to_jsonb(s) AS football_sport_candidate
FROM public.sports s
WHERE to_jsonb(s)::text ILIKE '%football%'
   OR to_jsonb(s)::text ILIKE '%soccer%'
ORDER BY s.id;


/* =========================================================
   2. ZÁKLADNÍ ROZSAH FOTBALOVÝCH LIG
   ========================================================= */

WITH football_sports AS (
    SELECT s.id
    FROM public.sports s
    WHERE to_jsonb(s)::text ILIKE '%football%'
       OR to_jsonb(s)::text ILIKE '%soccer%'
)
SELECT
    COUNT(*) AS football_leagues,
    COUNT(DISTINCT l.sport_id) AS football_sport_ids
FROM public.leagues l
WHERE l.sport_id IN (
    SELECT id
    FROM football_sports
);


/* =========================================================
   3. FOTBALOVÉ LIGY S NEJVÍCE PROVIDER MAPAMI

   Ukáže soutěže, kde je víceproviderová situace nejbohatší.
   ========================================================= */

WITH football_sports AS (
    SELECT s.id
    FROM public.sports s
    WHERE to_jsonb(s)::text ILIKE '%football%'
       OR to_jsonb(s)::text ILIKE '%soccer%'
)
SELECT
    l.id AS league_id,
    l.name AS league_name,
    COUNT(*) AS provider_map_rows,
    COUNT(DISTINCT lpm.provider) AS distinct_providers,
    STRING_AGG(
        DISTINCT lpm.provider,
        ', '
        ORDER BY lpm.provider
    ) AS providers
FROM public.leagues l
JOIN public.league_provider_map lpm
  ON lpm.league_id = l.id
WHERE l.sport_id IN (
    SELECT id
    FROM football_sports
)
GROUP BY
    l.id,
    l.name
HAVING COUNT(*) > 1
ORDER BY
    distinct_providers DESC,
    provider_map_rows DESC,
    l.id
LIMIT 100;


/* =========================================================
   4. PROVIDER LEAGUE ID MAPOVANÝ NA VÍCE CANONICAL LIG

   To by byl velmi důležitý collision pattern.
   ========================================================= */

SELECT
    provider,
    provider_league_id,
    COUNT(DISTINCT league_id) AS canonical_leagues,
    ARRAY_AGG(
        DISTINCT league_id
        ORDER BY league_id
    ) AS league_ids
FROM public.league_provider_map
GROUP BY
    provider,
    provider_league_id
HAVING COUNT(DISTINCT league_id) > 1
ORDER BY
    canonical_leagues DESC,
    provider,
    provider_league_id
LIMIT 100;


/* =========================================================
   5. FOTBALOVÉ LIGY S NEJVÍCE CANONICAL SEZONAMI
   ========================================================= */

WITH football_sports AS (
    SELECT s.id
    FROM public.sports s
    WHERE to_jsonb(s)::text ILIKE '%football%'
       OR to_jsonb(s)::text ILIKE '%soccer%'
)
SELECT
    l.id AS league_id,
    l.name AS league_name,
    COUNT(*) AS season_rows,
    MIN(s.season_code) AS first_season_code,
    MAX(s.season_code) AS last_season_code
FROM public.leagues l
JOIN public.seasons s
  ON s.league_id = l.id
WHERE l.sport_id IN (
    SELECT id
    FROM football_sports
)
GROUP BY
    l.id,
    l.name
ORDER BY
    season_rows DESC,
    l.id
LIMIT 100;


/* =========================================================
   6. SEASON CODE × LABEL KONVENCE VE FOTBALE
   ========================================================= */

WITH football_sports AS (
    SELECT s.id
    FROM public.sports s
    WHERE to_jsonb(s)::text ILIKE '%football%'
       OR to_jsonb(s)::text ILIKE '%soccer%'
)
SELECT
    s.season_code,
    s.season_label,
    COUNT(*) AS rows_count
FROM public.seasons s
JOIN public.leagues l
  ON l.id = s.league_id
WHERE l.sport_id IN (
    SELECT id
    FROM football_sports
)
GROUP BY
    s.season_code,
    s.season_label
ORDER BY
    rows_count DESC,
    s.season_code,
    s.season_label
LIMIT 200;


/* =========================================================
   7. STEJNÁ LIGA + STEJNÝ SEASON_CODE + VÍCE LABEL VARIANT

   Kontrola sémantických nekonzistencí.
   ========================================================= */

WITH football_sports AS (
    SELECT s.id
    FROM public.sports s
    WHERE to_jsonb(s)::text ILIKE '%football%'
       OR to_jsonb(s)::text ILIKE '%soccer%'
)
SELECT
    s.league_id,
    s.season_code,
    COUNT(*) AS rows_count,
    COUNT(DISTINCT s.season_label) AS label_variants,
    ARRAY_AGG(
        DISTINCT s.season_label
        ORDER BY s.season_label
    ) AS labels
FROM public.seasons s
JOIN public.leagues l
  ON l.id = s.league_id
WHERE l.sport_id IN (
    SELECT id
    FROM football_sports
)
GROUP BY
    s.league_id,
    s.season_code
HAVING COUNT(DISTINCT s.season_label) > 1
ORDER BY
    label_variants DESC,
    s.league_id,
    s.season_code;


/* =========================================================
   8. MATCHES – FOTBALOVÉ LIGY/SEZONY S NEJVĚTŠÍM OBJEMEM

   Ukáže skutečné historické datové scope.
   ========================================================= */

WITH football_sports AS (
    SELECT s.id
    FROM public.sports s
    WHERE to_jsonb(s)::text ILIKE '%football%'
       OR to_jsonb(s)::text ILIKE '%soccer%'
)
SELECT
    m.league_id,
    m.season,
    COUNT(*) AS matches,
    MIN(m.kickoff) AS first_kickoff,
    MAX(m.kickoff) AS last_kickoff
FROM public.matches m
JOIN public.leagues l
  ON l.id = m.league_id
WHERE l.sport_id IN (
    SELECT id
    FROM football_sports
)
GROUP BY
    m.league_id,
    m.season
ORDER BY
    matches DESC,
    m.league_id,
    m.season
LIMIT 100;


/* =========================================================
   9. MATCH SEASON BEZ CANONICAL PUBLIC.SEASONS

   Toto je pro náš návrh zásadní:
   zjistí, jak často existují historická data,
   ale chybí canonical season registry record.
   ========================================================= */

WITH football_sports AS (
    SELECT s.id
    FROM public.sports s
    WHERE to_jsonb(s)::text ILIKE '%football%'
       OR to_jsonb(s)::text ILIKE '%soccer%'
),
match_scopes AS (
    SELECT
        m.league_id,
        m.season::text AS match_season,
        COUNT(*) AS matches
    FROM public.matches m
    JOIN public.leagues l
      ON l.id = m.league_id
    WHERE l.sport_id IN (
        SELECT id
        FROM football_sports
    )
    GROUP BY
        m.league_id,
        m.season::text
)
SELECT
    ms.league_id,
    ms.match_season,
    ms.matches
FROM match_scopes ms
LEFT JOIN public.seasons s
  ON s.league_id = ms.league_id
 AND s.season_code = ms.match_season
WHERE s.id IS NULL
ORDER BY
    ms.matches DESC,
    ms.league_id,
    ms.match_season
LIMIT 200;


/* =========================================================
   10. INGEST TARGET MULTIPLICITY PRO FOTBAL

   Pouze jako provozní evidence.
   Ne jako canonical truth.

   Hledáme možné kombinace provider / league / season,
   které nám ukážou, zda budoucí scope_key potřebuje
   ještě další rozlišovací atribut.
   ========================================================= */

SELECT
    to_jsonb(x) AS football_ingest_target
FROM ops.ingest_targets x
WHERE to_jsonb(x)::text ILIKE '%football%'
ORDER BY 1
LIMIT 200;