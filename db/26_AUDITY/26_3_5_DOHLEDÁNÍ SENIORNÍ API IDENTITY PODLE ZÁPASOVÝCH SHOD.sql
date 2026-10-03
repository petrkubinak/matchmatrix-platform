BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;

SET LOCAL TIME ZONE 'UTC';


-- ============================================================================
-- RAAL LA LOUVIERE
-- DOHLEDÁNÍ SENIORNÍ API IDENTITY PODLE ZÁPASOVÝCH SHOD
-- ============================================================================

WITH
confirmed_team_map (
    historical_team_id,
    api_team_id,
    team_label
) AS (
    VALUES
        (972::bigint, 12940::bigint, 'Anderlecht'::text),
        (964::bigint, 13172::bigint, 'Antwerp'::text),
        (980::bigint, 12515::bigint, 'Beerschot VA'::text),
        (967::bigint, 12844::bigint, 'Cercle Brugge'::text),
        (975::bigint, 13032::bigint, 'Charleroi'::text),
        (976::bigint, 12803::bigint, 'Club Brugge'::text),
        (966::bigint, 12665::bigint, 'Dender'::text),
        (982::bigint, 13516::bigint, 'Eupen'::text),
        (977::bigint, 12254::bigint, 'Genk'::text),
        (979::bigint, 12719::bigint, 'Gent'::text),
        (981::bigint, 13043::bigint, 'Kortrijk'::text),
        (969::bigint, 12517::bigint, 'Mechelen'::text),
        (985::bigint, 15765::bigint, 'Oostende'::text),
        (974::bigint, 12636::bigint, 'OH Leuven'::text),
        (983::bigint, 13328::bigint, 'RWD Molenbeek'::text),
        (984::bigint, 12565::bigint, 'Seraing'::text),
        (971::bigint, 13537::bigint, 'Standard Liege'::text),
        (965::bigint, 13160::bigint, 'Union St. Gilloise'::text),
        (978::bigint, 12277::bigint, 'St. Truiden'::text),
        (968::bigint, 12993::bigint, 'Zulte Waregem'::text),
        (973::bigint, 13279::bigint, 'Westerlo'::text)
),
historical_raal_matches AS (
    SELECT
        m.id AS historical_match_id,
        m.season,
        m.kickoff AS historical_kickoff,
        m.home_team_id AS historical_home_team_id,
        ht.name AS historical_home_name,
        m.away_team_id AS historical_away_team_id,
        at.name AS historical_away_name,
        m.home_score AS historical_home_score,
        m.away_score AS historical_away_score,
        m.status AS historical_status,
        m.ext_match_id AS historical_ext_match_id,

        CASE
            WHEN m.home_team_id = 970
                THEN 'HOME'
            ELSE 'AWAY'
        END AS raal_side,

        CASE
            WHEN m.home_team_id = 970
                THEN m.away_team_id
            ELSE m.home_team_id
        END AS historical_opponent_id

    FROM public.matches m
    LEFT JOIN public.teams ht
        ON ht.id = m.home_team_id
    LEFT JOIN public.teams at
        ON at.id = m.away_team_id
    WHERE m.sport_id = 1
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
      AND m.season = '2526'
      AND (
          m.home_team_id = 970
          OR m.away_team_id = 970
      )
),
historical_with_opponent_map AS (
    SELECT
        h.*,
        tm.api_team_id AS api_opponent_team_id,
        tm.team_label AS opponent_label
    FROM historical_raal_matches h
    LEFT JOIN confirmed_team_map tm
        ON tm.historical_team_id = h.historical_opponent_id
),
api_candidates AS (
    SELECT
        h.historical_match_id,
        h.season,
        h.historical_kickoff,
        h.historical_home_name,
        h.historical_away_name,
        h.historical_home_score,
        h.historical_away_score,
        h.historical_status,
        h.historical_ext_match_id,
        h.raal_side,
        h.api_opponent_team_id,
        h.opponent_label,

        a.id AS api_match_id,
        a.kickoff AS api_kickoff,
        a.home_team_id AS api_home_team_id,
        ah.name AS api_home_name,
        a.away_team_id AS api_away_team_id,
        aa.name AS api_away_name,
        a.home_score AS api_home_score,
        a.away_score AS api_away_score,
        a.status AS api_status,
        a.ext_match_id AS api_ext_match_id,

        CASE
            WHEN h.raal_side = 'HOME'
                THEN a.home_team_id
            ELSE a.away_team_id
        END AS candidate_raal_team_id,

        CASE
            WHEN h.raal_side = 'HOME'
                THEN ah.name
            ELSE aa.name
        END AS candidate_raal_team_name,

        CASE
            WHEN h.raal_side = 'HOME'
                THEN ah.ext_source
            ELSE aa.ext_source
        END AS candidate_raal_ext_source,

        CASE
            WHEN h.raal_side = 'HOME'
                THEN ah.ext_team_id
            ELSE aa.ext_team_id
        END AS candidate_raal_ext_team_id,

        (
            h.historical_home_score IS NOT DISTINCT FROM a.home_score
            AND
            h.historical_away_score IS NOT DISTINCT FROM a.away_score
        ) AS score_matches,

        (
            h.historical_kickoff::date = a.kickoff::date
        ) AS date_matches

    FROM historical_with_opponent_map h
    JOIN public.matches a
        ON a.sport_id = 1
       AND a.league_id = 20853
       AND a.ext_source = 'api_football'
       AND a.kickoff::date = h.historical_kickoff::date
       AND (
            (
                h.raal_side = 'HOME'
                AND a.away_team_id = h.api_opponent_team_id
            )
            OR
            (
                h.raal_side = 'AWAY'
                AND a.home_team_id = h.api_opponent_team_id
            )
       )
    LEFT JOIN public.teams ah
        ON ah.id = a.home_team_id
    LEFT JOIN public.teams aa
        ON aa.id = a.away_team_id
    WHERE h.api_opponent_team_id IS NOT NULL
)


-- ============================================================================
-- VÝSTUP 1
-- SOUHRN KANDIDÁTŮ
-- ============================================================================

SELECT
    candidate_raal_team_id,
    candidate_raal_team_name,
    candidate_raal_ext_source,
    candidate_raal_ext_team_id,

    COUNT(*)::bigint AS matched_rows,

    COUNT(DISTINCT historical_match_id)::bigint
        AS matched_historical_matches,

    COUNT(*) FILTER (
        WHERE date_matches
    )::bigint AS date_matches,

    COUNT(*) FILTER (
        WHERE score_matches
    )::bigint AS score_matches,

    COUNT(*) FILTER (
        WHERE date_matches
          AND score_matches
    )::bigint AS exact_date_and_score_matches,

    MIN(historical_kickoff) AS first_historical_match,
    MAX(historical_kickoff) AS last_historical_match,

    (
        SELECT string_agg(
            p.provider || ':' || p.provider_team_id::text,
            ', ' ORDER BY p.provider, p.provider_team_id::text
        )
        FROM public.team_provider_map p
        WHERE p.team_id = candidate_raal_team_id
    ) AS provider_identities

FROM api_candidates
GROUP BY
    candidate_raal_team_id,
    candidate_raal_team_name,
    candidate_raal_ext_source,
    candidate_raal_ext_team_id
ORDER BY
    exact_date_and_score_matches DESC,
    matched_historical_matches DESC,
    candidate_raal_team_name;


-- ============================================================================
-- VÝSTUP 2
-- DETAIL VŠECH NALEZENÝCH ZÁPASOVÝCH SHOD
-- ============================================================================

WITH
confirmed_team_map (
    historical_team_id,
    api_team_id,
    team_label
) AS (
    VALUES
        (972::bigint, 12940::bigint, 'Anderlecht'::text),
        (964::bigint, 13172::bigint, 'Antwerp'::text),
        (980::bigint, 12515::bigint, 'Beerschot VA'::text),
        (967::bigint, 12844::bigint, 'Cercle Brugge'::text),
        (975::bigint, 13032::bigint, 'Charleroi'::text),
        (976::bigint, 12803::bigint, 'Club Brugge'::text),
        (966::bigint, 12665::bigint, 'Dender'::text),
        (982::bigint, 13516::bigint, 'Eupen'::text),
        (977::bigint, 12254::bigint, 'Genk'::text),
        (979::bigint, 12719::bigint, 'Gent'::text),
        (981::bigint, 13043::bigint, 'Kortrijk'::text),
        (969::bigint, 12517::bigint, 'Mechelen'::text),
        (985::bigint, 15765::bigint, 'Oostende'::text),
        (974::bigint, 12636::bigint, 'OH Leuven'::text),
        (983::bigint, 13328::bigint, 'RWD Molenbeek'::text),
        (984::bigint, 12565::bigint, 'Seraing'::text),
        (971::bigint, 13537::bigint, 'Standard Liege'::text),
        (965::bigint, 13160::bigint, 'Union St. Gilloise'::text),
        (978::bigint, 12277::bigint, 'St. Truiden'::text),
        (968::bigint, 12993::bigint, 'Zulte Waregem'::text),
        (973::bigint, 13279::bigint, 'Westerlo'::text)
),
historical_matches AS (
    SELECT
        m.id AS historical_match_id,
        m.kickoff AS historical_kickoff,
        m.home_team_id,
        ht.name AS historical_home_name,
        m.away_team_id,
        at.name AS historical_away_name,
        m.home_score AS historical_home_score,
        m.away_score AS historical_away_score,
        m.ext_match_id AS historical_ext_match_id,

        CASE
            WHEN m.home_team_id = 970
                THEN 'HOME'
            ELSE 'AWAY'
        END AS raal_side,

        CASE
            WHEN m.home_team_id = 970
                THEN m.away_team_id
            ELSE m.home_team_id
        END AS historical_opponent_id

    FROM public.matches m
    LEFT JOIN public.teams ht
        ON ht.id = m.home_team_id
    LEFT JOIN public.teams at
        ON at.id = m.away_team_id
    WHERE m.sport_id = 1
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
      AND m.season = '2526'
      AND (
          m.home_team_id = 970
          OR m.away_team_id = 970
      )
)
SELECT
    h.historical_match_id,
    h.historical_kickoff,
    h.historical_home_name,
    h.historical_away_name,
    h.historical_home_score,
    h.historical_away_score,
    h.historical_ext_match_id,

    a.id AS api_match_id,
    a.kickoff AS api_kickoff,
    ah.name AS api_home_name,
    aa.name AS api_away_name,
    a.home_score AS api_home_score,
    a.away_score AS api_away_score,
    a.ext_match_id AS api_ext_match_id,

    CASE
        WHEN h.raal_side = 'HOME'
            THEN a.home_team_id
        ELSE a.away_team_id
    END AS candidate_raal_team_id,

    CASE
        WHEN h.raal_side = 'HOME'
            THEN ah.name
        ELSE aa.name
    END AS candidate_raal_team_name,

    (
        h.historical_home_score IS NOT DISTINCT FROM a.home_score
        AND
        h.historical_away_score IS NOT DISTINCT FROM a.away_score
    ) AS score_matches

FROM historical_matches h
JOIN confirmed_team_map tm
    ON tm.historical_team_id = h.historical_opponent_id
JOIN public.matches a
    ON a.sport_id = 1
   AND a.league_id = 20853
   AND a.ext_source = 'api_football'
   AND a.kickoff::date = h.historical_kickoff::date
   AND (
        (
            h.raal_side = 'HOME'
            AND a.away_team_id = tm.api_team_id
        )
        OR
        (
            h.raal_side = 'AWAY'
            AND a.home_team_id = tm.api_team_id
        )
   )
LEFT JOIN public.teams ah
    ON ah.id = a.home_team_id
LEFT JOIN public.teams aa
    ON aa.id = a.away_team_id
ORDER BY
    h.historical_kickoff,
    h.historical_match_id;


-- ============================================================================
-- VÝSTUP 3
-- HISTORICKÉ ZÁPASY RAAL BEZ NALEZENÉ API SHODY
-- ============================================================================

WITH
confirmed_team_map (
    historical_team_id,
    api_team_id
) AS (
    VALUES
        (972::bigint, 12940::bigint),
        (964::bigint, 13172::bigint),
        (980::bigint, 12515::bigint),
        (967::bigint, 12844::bigint),
        (975::bigint, 13032::bigint),
        (976::bigint, 12803::bigint),
        (966::bigint, 12665::bigint),
        (982::bigint, 13516::bigint),
        (977::bigint, 12254::bigint),
        (979::bigint, 12719::bigint),
        (981::bigint, 13043::bigint),
        (969::bigint, 12517::bigint),
        (985::bigint, 15765::bigint),
        (974::bigint, 12636::bigint),
        (983::bigint, 13328::bigint),
        (984::bigint, 12565::bigint),
        (971::bigint, 13537::bigint),
        (965::bigint, 13160::bigint),
        (978::bigint, 12277::bigint),
        (968::bigint, 12993::bigint),
        (973::bigint, 13279::bigint)
),
historical_matches AS (
    SELECT
        m.id AS historical_match_id,
        m.kickoff,
        m.home_team_id,
        ht.name AS home_team_name,
        m.away_team_id,
        at.name AS away_team_name,
        m.home_score,
        m.away_score,
        m.ext_match_id,

        CASE
            WHEN m.home_team_id = 970
                THEN 'HOME'
            ELSE 'AWAY'
        END AS raal_side,

        CASE
            WHEN m.home_team_id = 970
                THEN m.away_team_id
            ELSE m.home_team_id
        END AS historical_opponent_id

    FROM public.matches m
    LEFT JOIN public.teams ht
        ON ht.id = m.home_team_id
    LEFT JOIN public.teams at
        ON at.id = m.away_team_id
    WHERE m.sport_id = 1
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
      AND m.season = '2526'
      AND (
          m.home_team_id = 970
          OR m.away_team_id = 970
      )
)
SELECT
    h.historical_match_id,
    h.kickoff,
    h.home_team_name,
    h.away_team_name,
    h.home_score,
    h.away_score,
    h.ext_match_id
FROM historical_matches h
LEFT JOIN confirmed_team_map tm
    ON tm.historical_team_id = h.historical_opponent_id
WHERE tm.api_team_id IS NULL
   OR NOT EXISTS (
        SELECT 1
        FROM public.matches a
        WHERE a.sport_id = 1
          AND a.league_id = 20853
          AND a.ext_source = 'api_football'
          AND a.kickoff::date = h.kickoff::date
          AND (
              (
                  h.raal_side = 'HOME'
                  AND a.away_team_id = tm.api_team_id
              )
              OR
              (
                  h.raal_side = 'AWAY'
                  AND a.home_team_id = tm.api_team_id
              )
          )
   )
ORDER BY
    h.kickoff,
    h.historical_match_id;


ROLLBACK;