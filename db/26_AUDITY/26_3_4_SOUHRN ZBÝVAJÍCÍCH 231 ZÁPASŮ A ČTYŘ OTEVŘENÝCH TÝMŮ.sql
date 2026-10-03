BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;

SET LOCAL TIME ZONE 'UTC';


-- ============================================================================
-- VÝSTUP 1
-- SOUHRN ZBÝVAJÍCÍCH 231 ZÁPASŮ A ČTYŘ OTEVŘENÝCH TÝMŮ
-- ============================================================================

WITH
open_teams (
    historical_team_id,
    historical_name,
    search_pattern
) AS (
    VALUES
        (988::bigint, 'Lokeren'::text, '%lokeren%'::text),
        (986::bigint, 'Mouscron'::text, '%mouscron%'::text),
        (970::bigint, 'RAAL La Louviere'::text, '%louviere%'::text),
        (987::bigint, 'Waasland-Beveren'::text, '%beveren%'::text)
),
remaining_matches AS (
    SELECT
        m.id AS match_id,
        m.season,
        m.kickoff,
        m.home_team_id,
        ht.name AS home_team_name,
        m.away_team_id,
        at.name AS away_team_name,
        m.home_score,
        m.away_score,
        m.status,
        m.ext_match_id,
        CASE
            WHEN oh.historical_team_id IS NOT NULL
             AND oa.historical_team_id IS NOT NULL
                THEN 'TWO_OPEN_TEAMS'
            WHEN oh.historical_team_id IS NOT NULL
              OR oa.historical_team_id IS NOT NULL
                THEN 'ONE_OPEN_TEAM'
            ELSE 'NO_OPEN_TEAM'
        END AS open_team_class
    FROM public.matches m
    LEFT JOIN public.teams ht
        ON ht.id = m.home_team_id
    LEFT JOIN public.teams at
        ON at.id = m.away_team_id
    LEFT JOIN open_teams oh
        ON oh.historical_team_id = m.home_team_id
    LEFT JOIN open_teams oa
        ON oa.historical_team_id = m.away_team_id
    WHERE m.sport_id = 1
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
)
SELECT
    current_database() AS database_name,
    current_setting('transaction_read_only') AS transaction_read_only,
    current_setting('transaction_isolation') AS transaction_isolation,

    COUNT(*)::bigint AS remaining_matches,

    COUNT(*) FILTER (
        WHERE open_team_class = 'ONE_OPEN_TEAM'
    )::bigint AS one_open_team_matches,

    COUNT(*) FILTER (
        WHERE open_team_class = 'TWO_OPEN_TEAMS'
    )::bigint AS two_open_team_matches,

    COUNT(*) FILTER (
        WHERE open_team_class = 'NO_OPEN_TEAM'
    )::bigint AS unexpected_without_open_team,

    COUNT(DISTINCT season)::bigint AS season_count,

    MIN(kickoff) AS first_kickoff,
    MAX(kickoff) AS last_kickoff,

    (
        SELECT COUNT(DISTINCT mf.match_id)
        FROM public.match_features mf
        JOIN remaining_matches r
            ON r.match_id = mf.match_id
    )::bigint AS matches_with_features,

    (
        SELECT COUNT(*)
        FROM public.match_features mf
        JOIN remaining_matches r
            ON r.match_id = mf.match_id
    )::bigint AS feature_rows,

    (
        SELECT COUNT(DISTINCT mr.match_id)
        FROM public.mm_match_ratings mr
        JOIN remaining_matches r
            ON r.match_id = mr.match_id
    )::bigint AS matches_with_ratings,

    (
        SELECT COUNT(*)
        FROM public.mm_match_ratings mr
        JOIN remaining_matches r
            ON r.match_id = mr.match_id
    )::bigint AS rating_rows,

    (
        SELECT COUNT(DISTINCT mpm.match_id)
        FROM public.match_provider_map mpm
        JOIN remaining_matches r
            ON r.match_id = mpm.match_id
        WHERE mpm.provider = 'football_data_uk'
    )::bigint AS matches_with_historical_identity

FROM remaining_matches;


-- ============================================================================
-- VÝSTUP 2
-- SOUHRN ČTYŘ OTEVŘENÝCH HISTORICKÝCH TÝMŮ
-- ============================================================================

WITH
open_teams (
    historical_team_id,
    historical_name,
    search_pattern
) AS (
    VALUES
        (988::bigint, 'Lokeren'::text, '%lokeren%'::text),
        (986::bigint, 'Mouscron'::text, '%mouscron%'::text),
        (970::bigint, 'RAAL La Louviere'::text, '%louviere%'::text),
        (987::bigint, 'Waasland-Beveren'::text, '%beveren%'::text)
),
remaining_matches AS (
    SELECT
        m.id AS match_id,
        m.season,
        m.home_team_id,
        m.away_team_id,
        CASE
            WHEN oh.historical_team_id IS NOT NULL
             AND oa.historical_team_id IS NOT NULL
                THEN 'TWO_OPEN_TEAMS'
            WHEN oh.historical_team_id IS NOT NULL
              OR oa.historical_team_id IS NOT NULL
                THEN 'ONE_OPEN_TEAM'
            ELSE 'NO_OPEN_TEAM'
        END AS open_team_class
    FROM public.matches m
    LEFT JOIN open_teams oh
        ON oh.historical_team_id = m.home_team_id
    LEFT JOIN open_teams oa
        ON oa.historical_team_id = m.away_team_id
    WHERE m.sport_id = 1
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
)
SELECT
    ot.historical_team_id,
    ot.historical_name,
    t.ext_source,
    t.ext_team_id,

    COUNT(r.match_id)::bigint AS match_appearances,

    COUNT(r.match_id) FILTER (
        WHERE r.home_team_id = ot.historical_team_id
    )::bigint AS home_appearances,

    COUNT(r.match_id) FILTER (
        WHERE r.away_team_id = ot.historical_team_id
    )::bigint AS away_appearances,

    COUNT(r.match_id) FILTER (
        WHERE r.open_team_class = 'TWO_OPEN_TEAMS'
    )::bigint AS appearances_against_open_team,

    string_agg(
        DISTINCT r.season,
        ', ' ORDER BY r.season
    ) FILTER (
        WHERE r.season IS NOT NULL
    ) AS seasons,

    (
        SELECT string_agg(
            p.provider || ':' || p.provider_team_id::text,
            ', ' ORDER BY p.provider, p.provider_team_id::text
        )
        FROM public.team_provider_map p
        WHERE p.team_id = ot.historical_team_id
    ) AS current_provider_identities

FROM open_teams ot
JOIN public.teams t
    ON t.id = ot.historical_team_id
LEFT JOIN remaining_matches r
    ON r.home_team_id = ot.historical_team_id
    OR r.away_team_id = ot.historical_team_id
GROUP BY
    ot.historical_team_id,
    ot.historical_name,
    t.ext_source,
    t.ext_team_id
ORDER BY
    ot.historical_name;


-- ============================================================================
-- VÝSTUP 3
-- ROZPAD OTEVŘENÝCH TÝMŮ PODLE SEZON
-- ============================================================================

WITH
open_teams (
    historical_team_id,
    historical_name
) AS (
    VALUES
        (988::bigint, 'Lokeren'::text),
        (986::bigint, 'Mouscron'::text),
        (970::bigint, 'RAAL La Louviere'::text),
        (987::bigint, 'Waasland-Beveren'::text)
),
remaining_matches AS (
    SELECT
        m.id AS match_id,
        m.season,
        m.home_team_id,
        m.away_team_id
    FROM public.matches m
    WHERE m.sport_id = 1
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
)
SELECT
    ot.historical_team_id,
    ot.historical_name,
    r.season,

    COUNT(*)::bigint AS match_appearances,

    COUNT(*) FILTER (
        WHERE r.home_team_id = ot.historical_team_id
    )::bigint AS home_appearances,

    COUNT(*) FILTER (
        WHERE r.away_team_id = ot.historical_team_id
    )::bigint AS away_appearances

FROM open_teams ot
JOIN remaining_matches r
    ON r.home_team_id = ot.historical_team_id
    OR r.away_team_id = ot.historical_team_id
GROUP BY
    ot.historical_team_id,
    ot.historical_name,
    r.season
ORDER BY
    ot.historical_name,
    r.season;


-- ============================================================================
-- VÝSTUP 4
-- DESET ZÁPASŮ, KDE JSOU OBA TÝMY OTEVŘENÉ
-- ============================================================================

WITH
open_teams (
    historical_team_id,
    historical_name
) AS (
    VALUES
        (988::bigint, 'Lokeren'::text),
        (986::bigint, 'Mouscron'::text),
        (970::bigint, 'RAAL La Louviere'::text),
        (987::bigint, 'Waasland-Beveren'::text)
)
SELECT
    m.id AS match_id,
    m.season,
    m.kickoff,
    m.home_team_id,
    ht.name AS home_team_name,
    m.away_team_id,
    at.name AS away_team_name,
    m.home_score,
    m.away_score,
    m.status,
    m.ext_match_id
FROM public.matches m
JOIN open_teams oh
    ON oh.historical_team_id = m.home_team_id
JOIN open_teams oa
    ON oa.historical_team_id = m.away_team_id
LEFT JOIN public.teams ht
    ON ht.id = m.home_team_id
LEFT JOIN public.teams at
    ON at.id = m.away_team_id
WHERE m.sport_id = 1
  AND m.league_id = 4
  AND m.ext_source = 'football_data_uk'
ORDER BY
    m.kickoff,
    m.id;


-- ============================================================================
-- VÝSTUP 5
-- MOŽNÉ EXISTUJÍCÍ TÝMOVÉ KANDIDÁTY PODLE NÁZVU
--
-- Jde pouze o kandidáty k ručnímu ověření.
-- Žádné mapování se nevytváří.
-- ============================================================================

WITH
open_teams (
    historical_team_id,
    historical_name,
    search_pattern
) AS (
    VALUES
        (988::bigint, 'Lokeren'::text, '%lokeren%'::text),
        (986::bigint, 'Mouscron'::text, '%mouscron%'::text),
        (970::bigint, 'RAAL La Louviere'::text, '%louviere%'::text),
        (987::bigint, 'Waasland-Beveren'::text, '%beveren%'::text)
),
candidate_teams AS (
    SELECT DISTINCT
        ot.historical_team_id,
        ot.historical_name,
        t.id AS candidate_team_id,
        t.name AS candidate_team_name,
        t.ext_source AS candidate_ext_source,
        t.ext_team_id AS candidate_ext_team_id
    FROM open_teams ot
    JOIN public.teams t
        ON lower(COALESCE(t.name, '')) LIKE ot.search_pattern
    WHERE t.id <> ot.historical_team_id
),
candidate_usage AS (
    SELECT
        c.*,

        (
            SELECT COUNT(*)
            FROM public.matches m
            WHERE m.home_team_id = c.candidate_team_id
               OR m.away_team_id = c.candidate_team_id
        )::bigint AS all_match_appearances,

        (
            SELECT COUNT(*)
            FROM public.matches m
            WHERE m.league_id = 20853
              AND (
                  m.home_team_id = c.candidate_team_id
                  OR m.away_team_id = c.candidate_team_id
              )
        )::bigint AS jupiler_match_appearances,

        (
            SELECT string_agg(
                p.provider || ':' || p.provider_team_id::text,
                ', ' ORDER BY p.provider, p.provider_team_id::text
            )
            FROM public.team_provider_map p
            WHERE p.team_id = c.candidate_team_id
        ) AS provider_identities

    FROM candidate_teams c
)
SELECT
    historical_team_id,
    historical_name,
    candidate_team_id,
    candidate_team_name,
    candidate_ext_source,
    candidate_ext_team_id,
    all_match_appearances,
    jupiler_match_appearances,
    provider_identities
FROM candidate_usage
ORDER BY
    historical_name,
    jupiler_match_appearances DESC,
    all_match_appearances DESC,
    candidate_team_name;


-- ============================================================================
-- VÝSTUP 6
-- PŘÍPADNÉ ZÁZNAMY V PUBLIC.TEAM_ALIASES
-- ============================================================================

WITH
open_teams (
    historical_team_id,
    historical_name,
    search_pattern
) AS (
    VALUES
        (988::bigint, 'Lokeren'::text, '%lokeren%'::text),
        (986::bigint, 'Mouscron'::text, '%mouscron%'::text),
        (970::bigint, 'RAAL La Louviere'::text, '%louviere%'::text),
        (987::bigint, 'Waasland-Beveren'::text, '%beveren%'::text)
)
SELECT
    ot.historical_team_id,
    ot.historical_name,
    to_jsonb(a) AS alias_record
FROM open_teams ot
JOIN public.team_aliases a
    ON lower(to_jsonb(a)::text) LIKE ot.search_pattern
ORDER BY
    ot.historical_name,
    to_jsonb(a)::text;


ROLLBACK;