/*
CO:
STEP 9S V2 – FOOTBALL EXACT COVERAGE COMPLEXITY AUDIT

K ČEMU:
Opravit STEP 9S tak, aby pracoval výhradně s klasickým
fotbalem sport_code = FB, nikoliv také American Football.

Současně přesně prověřit problém season identity:
2024 vs 2425 vs 2024/2025.

JAK:
Pouze SELECT.
*/


/* =========================================================
   1. PŘESNÁ IDENTITA FOTBALU
   ========================================================= */

SELECT
    id,
    code,
    name,
    sport_key
FROM public.sports
WHERE code = 'FB';


/* =========================================================
   2. ČISTÝ ROZSAH FB
   ========================================================= */

SELECT
    COUNT(*) AS fb_leagues
FROM public.leagues l
JOIN public.sports s
  ON s.id = l.sport_id
WHERE s.code = 'FB';


/* =========================================================
   3. CANONICAL LIGA S VÍCE PROVIDERY
   ========================================================= */

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
JOIN public.sports s
  ON s.id = l.sport_id
JOIN public.league_provider_map lpm
  ON lpm.league_id = l.id
WHERE s.code = 'FB'
GROUP BY
    l.id,
    l.name
HAVING COUNT(DISTINCT lpm.provider) > 1
ORDER BY
    distinct_providers DESC,
    l.id;


/* =========================================================
   4. PROVIDER LEAGUE ID → VÍCE CANONICAL LIG
   ========================================================= */

SELECT
    lpm.provider,
    lpm.provider_league_id,
    COUNT(DISTINCT lpm.league_id) AS canonical_leagues,
    ARRAY_AGG(
        DISTINCT lpm.league_id
        ORDER BY lpm.league_id
    ) AS league_ids
FROM public.league_provider_map lpm
JOIN public.leagues l
  ON l.id = lpm.league_id
JOIN public.sports s
  ON s.id = l.sport_id
WHERE s.code = 'FB'
GROUP BY
    lpm.provider,
    lpm.provider_league_id
HAVING COUNT(DISTINCT lpm.league_id) > 1
ORDER BY
    canonical_leagues DESC,
    lpm.provider,
    lpm.provider_league_id;


/* =========================================================
   5. FORMÁTY MATCH.SEASON VE FOTBALE
   ========================================================= */

SELECT
    m.season::text AS match_season,
    COUNT(*) AS matches,
    COUNT(DISTINCT m.league_id) AS leagues
FROM public.matches m
JOIN public.leagues l
  ON l.id = m.league_id
JOIN public.sports s
  ON s.id = l.sport_id
WHERE s.code = 'FB'
GROUP BY
    m.season::text
ORDER BY
    match_season;


/* =========================================================
   6. FORMÁTY CANONICAL SEASON
   ========================================================= */

SELECT
    se.season_code,
    se.season_label,
    COUNT(*) AS season_rows
FROM public.seasons se
JOIN public.leagues l
  ON l.id = se.league_id
JOIN public.sports s
  ON s.id = l.sport_id
WHERE s.code = 'FB'
GROUP BY
    se.season_code,
    se.season_label
ORDER BY
    se.season_code,
    se.season_label;


/* =========================================================
   7. PŘÍMÁ SHODA MATCH.SEASON → SEASON_CODE
   ========================================================= */

WITH match_scopes AS (
    SELECT
        m.league_id,
        m.season::text AS match_season,
        COUNT(*) AS matches
    FROM public.matches m
    JOIN public.leagues l
      ON l.id = m.league_id
    JOIN public.sports sp
      ON sp.id = l.sport_id
    WHERE sp.code = 'FB'
    GROUP BY
        m.league_id,
        m.season::text
)
SELECT
    COUNT(*) AS total_match_scopes,
    COUNT(*) FILTER (
        WHERE se.id IS NOT NULL
    ) AS direct_code_match,
    COUNT(*) FILTER (
        WHERE se.id IS NULL
    ) AS no_direct_code_match
FROM match_scopes ms
LEFT JOIN public.seasons se
  ON se.league_id = ms.league_id
 AND se.season_code = ms.match_season;


/* =========================================================
   8. COMPACT FORMAT 2425 → LABEL 2024/2025

   Záměrně pouze kandidátní diagnostika.
   Nic nemapujeme.
   ========================================================= */

WITH match_scopes AS (
    SELECT
        m.league_id,
        m.season::text AS match_season,
        COUNT(*) AS matches
    FROM public.matches m
    JOIN public.leagues l
      ON l.id = m.league_id
    JOIN public.sports sp
      ON sp.id = l.sport_id
    WHERE sp.code = 'FB'
    GROUP BY
        m.league_id,
        m.season::text
),
compact_candidates AS (
    SELECT
        ms.*,
        CASE
            WHEN ms.match_season ~ '^[0-9]{4}$'
             AND substring(ms.match_season,1,2)::int
                 BETWEEN 18 AND 29
            THEN
                '20' || substring(ms.match_season,1,2)
                || '/'
                || '20' || substring(ms.match_season,3,2)
            ELSE NULL
        END AS candidate_label
    FROM match_scopes ms
)
SELECT
    c.league_id,
    c.match_season,
    c.candidate_label,
    c.matches,
    se.id AS candidate_season_id,
    se.season_code,
    se.season_label
FROM compact_candidates c
LEFT JOIN public.seasons se
  ON se.league_id = c.league_id
 AND se.season_label = c.candidate_label
WHERE c.candidate_label IS NOT NULL
ORDER BY
    c.matches DESC,
    c.league_id,
    c.match_season
LIMIT 200;


/* =========================================================
   9. SKUTEČNĚ NEVYŘEŠENÉ MATCH SEASON SCOPE

   Ani přímý season_code,
   ani bezpečný compact-label kandidát.
   ========================================================= */

WITH match_scopes AS (
    SELECT
        m.league_id,
        m.season::text AS match_season,
        COUNT(*) AS matches
    FROM public.matches m
    JOIN public.leagues l
      ON l.id = m.league_id
    JOIN public.sports sp
      ON sp.id = l.sport_id
    WHERE sp.code = 'FB'
    GROUP BY
        m.league_id,
        m.season::text
),
resolved AS (
    SELECT
        ms.*,

        direct_s.id AS direct_season_id,

        CASE
            WHEN ms.match_season ~ '^[0-9]{4}$'
             AND substring(ms.match_season,1,2)::int
                 BETWEEN 18 AND 29
            THEN
                '20' || substring(ms.match_season,1,2)
                || '/'
                || '20' || substring(ms.match_season,3,2)
            ELSE NULL
        END AS candidate_label

    FROM match_scopes ms

    LEFT JOIN public.seasons direct_s
      ON direct_s.league_id = ms.league_id
     AND direct_s.season_code = ms.match_season
)
SELECT
    r.league_id,
    r.match_season,
    r.matches,
    r.candidate_label
FROM resolved r
LEFT JOIN public.seasons label_s
  ON label_s.league_id = r.league_id
 AND label_s.season_label = r.candidate_label
WHERE r.direct_season_id IS NULL
  AND label_s.id IS NULL
ORDER BY
    r.matches DESC,
    r.league_id,
    r.match_season
LIMIT 200;