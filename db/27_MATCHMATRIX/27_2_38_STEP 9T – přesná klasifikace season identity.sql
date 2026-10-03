/*
CO:
STEP 9T – FOOTBALL SEASON SEMANTIC RESOLUTION AUDIT

K ČEMU:
Přesně rozlišit:
- přímou shodu match.season -> season_code,
- compact shodu 2425 -> 2024/2025,
- skutečnou kolizi obou interpretací,
- skutečně nevyřešené sezony.

DŮLEŽITÉ:
Compact kandidát vznikne pouze tehdy,
když druhá dvojice roku = první dvojice + 1.

Např.:
1819 -> 2018/2019
2425 -> 2024/2025

Ale:
2022 -> žádný compact kandidát
2024 -> žádný compact kandidát

JAK:
Pouze SELECT.
*/


/* =========================================================
   1. KLASIFIKACE VŠECH FOOTBALL MATCH SEASON SCOPE
   ========================================================= */

WITH match_scopes AS (
    SELECT
        m.league_id,
        NULLIF(btrim(m.season::text), '') AS match_season,
        COUNT(*) AS matches
    FROM public.matches m
    JOIN public.leagues l
      ON l.id = m.league_id
    JOIN public.sports sp
      ON sp.id = l.sport_id
    WHERE sp.code = 'FB'
    GROUP BY
        m.league_id,
        NULLIF(btrim(m.season::text), '')
),

candidate AS (
    SELECT
        ms.*,

        CASE
            WHEN ms.match_season ~ '^[0-9]{4}$'
             AND substring(ms.match_season,1,2)::int
                   BETWEEN 18 AND 99
             AND substring(ms.match_season,3,2)::int
                   =
                 (
                    substring(ms.match_season,1,2)::int + 1
                 ) % 100
            THEN
                CASE
                    WHEN substring(ms.match_season,1,2)::int >= 70
                    THEN
                        '19' || substring(ms.match_season,1,2)
                        || '/'
                        || CASE
                               WHEN substring(ms.match_season,3,2) = '00'
                               THEN '2000'
                               ELSE '19' || substring(ms.match_season,3,2)
                           END
                    ELSE
                        '20' || substring(ms.match_season,1,2)
                        || '/'
                        || '20' || substring(ms.match_season,3,2)
                END
            ELSE NULL
        END AS compact_label

    FROM match_scopes ms
),

resolved AS (
    SELECT
        c.league_id,
        c.match_season,
        c.matches,
        c.compact_label,

        direct_s.id AS direct_season_id,
        direct_s.season_code AS direct_season_code,
        direct_s.season_label AS direct_season_label,

        compact_s.id AS compact_season_id,
        compact_s.season_code AS compact_season_code,
        compact_s.season_label AS compact_season_label

    FROM candidate c

    LEFT JOIN public.seasons direct_s
      ON direct_s.league_id = c.league_id
     AND direct_s.season_code = c.match_season

    LEFT JOIN public.seasons compact_s
      ON compact_s.league_id = c.league_id
     AND compact_s.season_label = c.compact_label
),

classified AS (
    SELECT
        r.*,

        CASE
            WHEN r.match_season IS NULL
                THEN 'EMPTY'

            WHEN r.direct_season_id IS NOT NULL
             AND r.compact_season_id IS NULL
                THEN 'DIRECT_ONLY'

            WHEN r.direct_season_id IS NULL
             AND r.compact_season_id IS NOT NULL
                THEN 'COMPACT_ONLY'

            WHEN r.direct_season_id IS NOT NULL
             AND r.compact_season_id IS NOT NULL
             AND r.direct_season_id = r.compact_season_id
                THEN 'SAME_TARGET'

            WHEN r.direct_season_id IS NOT NULL
             AND r.compact_season_id IS NOT NULL
             AND r.direct_season_id <> r.compact_season_id
                THEN 'AMBIGUOUS'

            ELSE 'UNRESOLVED'
        END AS resolution_status

    FROM resolved r
)


/* =========================================================
   1A. SOUHRN
   ========================================================= */

SELECT
    resolution_status,
    COUNT(*) AS scopes,
    SUM(matches) AS matches
FROM classified
GROUP BY resolution_status
ORDER BY resolution_status;


/* =========================================================
   2. SKUTEČNÉ AMBIGUITY
   ========================================================= */

WITH match_scopes AS (
    SELECT
        m.league_id,
        NULLIF(btrim(m.season::text), '') AS match_season,
        COUNT(*) AS matches
    FROM public.matches m
    JOIN public.leagues l ON l.id = m.league_id
    JOIN public.sports sp ON sp.id = l.sport_id
    WHERE sp.code = 'FB'
    GROUP BY
        m.league_id,
        NULLIF(btrim(m.season::text), '')
),
candidate AS (
    SELECT
        ms.*,
        CASE
            WHEN ms.match_season ~ '^[0-9]{4}$'
             AND substring(ms.match_season,1,2)::int BETWEEN 18 AND 99
             AND substring(ms.match_season,3,2)::int =
                 (substring(ms.match_season,1,2)::int + 1) % 100
            THEN
                CASE
                    WHEN substring(ms.match_season,1,2)::int >= 70
                    THEN
                        '19' || substring(ms.match_season,1,2)
                        || '/'
                        || CASE
                               WHEN substring(ms.match_season,3,2) = '00'
                               THEN '2000'
                               ELSE '19' || substring(ms.match_season,3,2)
                           END
                    ELSE
                        '20' || substring(ms.match_season,1,2)
                        || '/'
                        || '20' || substring(ms.match_season,3,2)
                END
        END AS compact_label
    FROM match_scopes ms
)
SELECT
    c.league_id,
    l.name AS league_name,
    c.match_season,
    c.compact_label,
    c.matches,

    direct_s.id AS direct_season_id,
    direct_s.season_code AS direct_code,
    direct_s.season_label AS direct_label,

    compact_s.id AS compact_season_id,
    compact_s.season_code AS compact_code,
    compact_s.season_label AS compact_label_found

FROM candidate c

JOIN public.leagues l
  ON l.id = c.league_id

JOIN public.seasons direct_s
  ON direct_s.league_id = c.league_id
 AND direct_s.season_code = c.match_season

JOIN public.seasons compact_s
  ON compact_s.league_id = c.league_id
 AND compact_s.season_label = c.compact_label

WHERE direct_s.id <> compact_s.id

ORDER BY
    c.matches DESC,
    c.league_id,
    c.match_season;


/* =========================================================
   3. COMPACT_ONLY – BEZPEČNÍ KANDIDÁTI
   ========================================================= */

WITH match_scopes AS (
    SELECT
        m.league_id,
        NULLIF(btrim(m.season::text), '') AS match_season,
        COUNT(*) AS matches
    FROM public.matches m
    JOIN public.leagues l ON l.id = m.league_id
    JOIN public.sports sp ON sp.id = l.sport_id
    WHERE sp.code = 'FB'
    GROUP BY
        m.league_id,
        NULLIF(btrim(m.season::text), '')
),
candidate AS (
    SELECT
        ms.*,
        CASE
            WHEN ms.match_season ~ '^[0-9]{4}$'
             AND substring(ms.match_season,1,2)::int BETWEEN 18 AND 99
             AND substring(ms.match_season,3,2)::int =
                 (substring(ms.match_season,1,2)::int + 1) % 100
            THEN
                CASE
                    WHEN substring(ms.match_season,1,2)::int >= 70
                    THEN
                        '19' || substring(ms.match_season,1,2)
                        || '/'
                        || CASE
                               WHEN substring(ms.match_season,3,2) = '00'
                               THEN '2000'
                               ELSE '19' || substring(ms.match_season,3,2)
                           END
                    ELSE
                        '20' || substring(ms.match_season,1,2)
                        || '/'
                        || '20' || substring(ms.match_season,3,2)
                END
        END AS compact_label
    FROM match_scopes ms
)
SELECT
    c.league_id,
    l.name AS league_name,
    c.match_season,
    c.compact_label,
    c.matches,

    compact_s.id AS canonical_season_id,
    compact_s.season_code,
    compact_s.season_label

FROM candidate c

JOIN public.leagues l
  ON l.id = c.league_id

LEFT JOIN public.seasons direct_s
  ON direct_s.league_id = c.league_id
 AND direct_s.season_code = c.match_season

JOIN public.seasons compact_s
  ON compact_s.league_id = c.league_id
 AND compact_s.season_label = c.compact_label

WHERE direct_s.id IS NULL

ORDER BY
    c.matches DESC,
    c.league_id,
    c.match_season;


/* =========================================================
   4. SKUTEČNĚ UNRESOLVED
   ========================================================= */

WITH match_scopes AS (
    SELECT
        m.league_id,
        NULLIF(btrim(m.season::text), '') AS match_season,
        COUNT(*) AS matches
    FROM public.matches m
    JOIN public.leagues l ON l.id = m.league_id
    JOIN public.sports sp ON sp.id = l.sport_id
    WHERE sp.code = 'FB'
    GROUP BY
        m.league_id,
        NULLIF(btrim(m.season::text), '')
),
candidate AS (
    SELECT
        ms.*,
        CASE
            WHEN ms.match_season ~ '^[0-9]{4}$'
             AND substring(ms.match_season,1,2)::int BETWEEN 18 AND 99
             AND substring(ms.match_season,3,2)::int =
                 (substring(ms.match_season,1,2)::int + 1) % 100
            THEN
                CASE
                    WHEN substring(ms.match_season,1,2)::int >= 70
                    THEN
                        '19' || substring(ms.match_season,1,2)
                        || '/'
                        || CASE
                               WHEN substring(ms.match_season,3,2) = '00'
                               THEN '2000'
                               ELSE '19' || substring(ms.match_season,3,2)
                           END
                    ELSE
                        '20' || substring(ms.match_season,1,2)
                        || '/'
                        || '20' || substring(ms.match_season,3,2)
                END
        END AS compact_label
    FROM match_scopes ms
)
SELECT
    c.league_id,
    l.name AS league_name,
    c.match_season,
    c.compact_label,
    c.matches
FROM candidate c

JOIN public.leagues l
  ON l.id = c.league_id

LEFT JOIN public.seasons direct_s
  ON direct_s.league_id = c.league_id
 AND direct_s.season_code = c.match_season

LEFT JOIN public.seasons compact_s
  ON compact_s.league_id = c.league_id
 AND compact_s.season_label = c.compact_label

WHERE direct_s.id IS NULL
  AND compact_s.id IS NULL

ORDER BY
    c.matches DESC,
    c.league_id,
    c.match_season
LIMIT 300;