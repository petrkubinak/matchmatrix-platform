/*
CO:
STEP 10A – API-HANDBALL HISTORICAL COVERAGE BREADTH AUDIT

K ČEMU:
Zjistit skutečnou šířku historických dat api_handball,
která již v MatchMatrix existují.

CÍL:
Rozlišit:
- počet canonical lig,
- počet provider lig,
- počet league × season scope,
- čisté scope,
- problematické scope,
- objem jednotlivých scope.

DŮLEŽITÉ:
Tento krok:
- NEMĚNÍ coverage,
- NEMĚNÍ exact scope,
- NEVYTVÁŘÍ routing,
- NEVOLÁ API.

JAK:
Pouze SELECT.
*/


/* =========================================================
   1. ZÁKLADNÍ SOUHRN HISTORICKÉHO API_HANDBALL
   ========================================================= */

WITH hb_matches AS (
    SELECT DISTINCT
        m.id AS match_id,
        m.league_id,
        m.season,
        m.kickoff,
        m.status,
        m.home_score,
        m.away_score
    FROM public.matches m
    JOIN public.match_provider_map mpm
      ON mpm.match_id = m.id
     AND mpm.provider = 'api_handball'
    WHERE m.kickoff < CURRENT_DATE
),
scopes AS (
    SELECT
        hm.league_id,
        lpm.provider_league_id,
        hm.season,

        COUNT(*) AS matches,

        COUNT(*) FILTER (
            WHERE hm.status = 'FINISHED'
        ) AS finished,

        COUNT(*) FILTER (
            WHERE hm.status = 'FINISHED'
              AND hm.home_score IS NOT NULL
              AND hm.away_score IS NOT NULL
        ) AS finished_with_score,

        COUNT(*) FILTER (
            WHERE hm.status = 'SCHEDULED'
        ) AS scheduled,

        COUNT(*) FILTER (
            WHERE hm.status = 'CANCELLED'
        ) AS cancelled,

        MIN(hm.kickoff) AS first_kickoff,
        MAX(hm.kickoff) AS last_kickoff

    FROM hb_matches hm

    LEFT JOIN public.league_provider_map lpm
      ON lpm.league_id = hm.league_id
     AND lpm.provider = 'api_handball'

    GROUP BY
        hm.league_id,
        lpm.provider_league_id,
        hm.season
)
SELECT
    COUNT(*) AS league_season_scopes,
    COUNT(DISTINCT league_id) AS canonical_leagues,
    COUNT(DISTINCT provider_league_id)
        FILTER (WHERE provider_league_id IS NOT NULL)
        AS provider_leagues,

    SUM(matches) AS matches,

    COUNT(*) FILTER (
        WHERE finished = matches
          AND finished_with_score = matches
          AND scheduled = 0
          AND cancelled = 0
    ) AS fully_clean_scopes,

    COUNT(*) FILTER (
        WHERE NOT (
            finished = matches
            AND finished_with_score = matches
            AND scheduled = 0
            AND cancelled = 0
        )
    ) AS exception_scopes,

    MIN(first_kickoff) AS oldest_kickoff,
    MAX(last_kickoff) AS newest_kickoff

FROM scopes;


/* =========================================================
   2. ROZDĚLENÍ SCOPE PODLE OBJEMU
   ========================================================= */

WITH hb_matches AS (
    SELECT DISTINCT
        m.id AS match_id,
        m.league_id,
        m.season
    FROM public.matches m
    JOIN public.match_provider_map mpm
      ON mpm.match_id = m.id
     AND mpm.provider = 'api_handball'
    WHERE m.kickoff < CURRENT_DATE
),
scopes AS (
    SELECT
        league_id,
        season,
        COUNT(*) AS matches
    FROM hb_matches
    GROUP BY
        league_id,
        season
)
SELECT
    CASE
        WHEN matches >= 100 THEN '100+'
        WHEN matches >= 50  THEN '50-99'
        WHEN matches >= 10  THEN '10-49'
        ELSE '1-9'
    END AS scope_size,

    COUNT(*) AS scopes,
    SUM(matches) AS matches

FROM scopes

GROUP BY 1

ORDER BY
    CASE
        WHEN CASE
            WHEN matches >= 100 THEN '100+'
            WHEN matches >= 50  THEN '50-99'
            WHEN matches >= 10  THEN '10-49'
            ELSE '1-9'
        END = '100+' THEN 1
        WHEN CASE
            WHEN matches >= 100 THEN '100+'
            WHEN matches >= 50  THEN '50-99'
            WHEN matches >= 10  THEN '10-49'
            ELSE '1-9'
        END = '50-99' THEN 2
        WHEN CASE
            WHEN matches >= 100 THEN '100+'
            WHEN matches >= 50  THEN '50-99'
            WHEN matches >= 10  THEN '10-49'
            ELSE '1-9'
        END = '10-49' THEN 3
        ELSE 4
    END;


/* =========================================================
   3. NEJVĚTŠÍ ČISTÉ SCOPE

   Kandidáti pro další runtime replay testy.
   ========================================================= */

WITH hb_matches AS (
    SELECT DISTINCT
        m.id AS match_id,
        m.league_id,
        m.season,
        m.kickoff,
        m.status,
        m.home_score,
        m.away_score
    FROM public.matches m
    JOIN public.match_provider_map mpm
      ON mpm.match_id = m.id
     AND mpm.provider = 'api_handball'
    WHERE m.kickoff < CURRENT_DATE
)
SELECT
    hm.league_id AS canonical_league_id,
    l.name AS league_name,
    lpm.provider_league_id,
    hm.season,

    COUNT(*) AS matches,

    COUNT(*) FILTER (
        WHERE hm.status = 'FINISHED'
    ) AS finished,

    COUNT(*) FILTER (
        WHERE hm.status = 'FINISHED'
          AND hm.home_score IS NOT NULL
          AND hm.away_score IS NOT NULL
    ) AS finished_with_score,

    COUNT(*) FILTER (
        WHERE hm.status = 'SCHEDULED'
    ) AS scheduled,

    COUNT(*) FILTER (
        WHERE hm.status = 'CANCELLED'
    ) AS cancelled,

    MIN(hm.kickoff) AS first_kickoff,
    MAX(hm.kickoff) AS last_kickoff

FROM hb_matches hm

JOIN public.leagues l
  ON l.id = hm.league_id

LEFT JOIN public.league_provider_map lpm
  ON lpm.league_id = hm.league_id
 AND lpm.provider = 'api_handball'

GROUP BY
    hm.league_id,
    l.name,
    lpm.provider_league_id,
    hm.season

HAVING
    COUNT(*) FILTER (
        WHERE hm.status = 'FINISHED'
    ) = COUNT(*)

AND COUNT(*) FILTER (
        WHERE hm.status = 'FINISHED'
          AND hm.home_score IS NOT NULL
          AND hm.away_score IS NOT NULL
    ) = COUNT(*)

AND COUNT(*) FILTER (
        WHERE hm.status IN ('SCHEDULED', 'CANCELLED')
    ) = 0

ORDER BY
    matches DESC,
    hm.league_id

LIMIT 30;


/* =========================================================
   4. PROBLEMATICKÉ SCOPE
   ========================================================= */

WITH hb_matches AS (
    SELECT DISTINCT
        m.id AS match_id,
        m.league_id,
        m.season,
        m.kickoff,
        m.status,
        m.home_score,
        m.away_score
    FROM public.matches m
    JOIN public.match_provider_map mpm
      ON mpm.match_id = m.id
     AND mpm.provider = 'api_handball'
    WHERE m.kickoff < CURRENT_DATE
)
SELECT
    hm.league_id AS canonical_league_id,
    l.name AS league_name,
    lpm.provider_league_id,
    hm.season,

    COUNT(*) AS matches,

    COUNT(*) FILTER (
        WHERE hm.status = 'FINISHED'
    ) AS finished,

    COUNT(*) FILTER (
        WHERE hm.status = 'FINISHED'
          AND hm.home_score IS NOT NULL
          AND hm.away_score IS NOT NULL
    ) AS finished_with_score,

    COUNT(*) FILTER (
        WHERE hm.status = 'SCHEDULED'
    ) AS scheduled,

    COUNT(*) FILTER (
        WHERE hm.status = 'CANCELLED'
    ) AS cancelled,

    MIN(hm.kickoff) AS first_kickoff,
    MAX(hm.kickoff) AS last_kickoff

FROM hb_matches hm

JOIN public.leagues l
  ON l.id = hm.league_id

LEFT JOIN public.league_provider_map lpm
  ON lpm.league_id = hm.league_id
 AND lpm.provider = 'api_handball'

GROUP BY
    hm.league_id,
    l.name,
    lpm.provider_league_id,
    hm.season

HAVING NOT (
       COUNT(*) FILTER (
           WHERE hm.status = 'FINISHED'
       ) = COUNT(*)

   AND COUNT(*) FILTER (
           WHERE hm.status = 'FINISHED'
             AND hm.home_score IS NOT NULL
             AND hm.away_score IS NOT NULL
       ) = COUNT(*)

   AND COUNT(*) FILTER (
           WHERE hm.status IN ('SCHEDULED', 'CANCELLED')
       ) = 0
)

ORDER BY
    scheduled DESC,
    cancelled DESC,
    matches DESC

LIMIT 100;