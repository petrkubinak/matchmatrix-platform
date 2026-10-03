BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;

SET LOCAL TIME ZONE 'UTC';
SET LOCAL statement_timeout = '10min';


-- ============================================================================
-- VÝSTUP 1
-- SOUHRNNÝ AUDIT NOVÉ MAPY 23 TÝMŮ A 110 ZÁPASŮ
-- ============================================================================

WITH
team_map (
    historical_team_id,
    api_team_id,
    team_label,
    mapping_stage
) AS (
    VALUES
        (972::bigint, 12940::bigint, 'Anderlecht'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (964::bigint, 13172::bigint, 'Antwerp'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (980::bigint, 12515::bigint, 'Beerschot VA'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (967::bigint, 12844::bigint, 'Cercle Brugge'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (975::bigint, 13032::bigint, 'Charleroi'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (976::bigint, 12803::bigint, 'Club Brugge'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (966::bigint, 12665::bigint, 'Dender'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (982::bigint, 13516::bigint, 'Eupen'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (977::bigint, 12254::bigint, 'Genk'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (979::bigint, 12719::bigint, 'Gent'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (981::bigint, 13043::bigint, 'Kortrijk'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (969::bigint, 12517::bigint, 'Mechelen'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (985::bigint, 15765::bigint, 'Oostende'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (974::bigint, 12636::bigint, 'OH Leuven'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (983::bigint, 13328::bigint, 'RWD Molenbeek'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (984::bigint, 12565::bigint, 'Seraing'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (971::bigint, 13537::bigint, 'Standard Liege'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (965::bigint, 13160::bigint, 'Union St. Gilloise'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (978::bigint, 12277::bigint, 'St. Truiden'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (968::bigint, 12993::bigint, 'Zulte Waregem'::text, 'PREVIOUSLY_CONFIRMED'::text),
        (973::bigint, 13279::bigint, 'Westerlo'::text, 'PREVIOUSLY_CONFIRMED'::text),

        (970::bigint, 12427::bigint, 'RAAL La Louviere'::text, 'NEWLY_CONFIRMED'::text),
        (987::bigint, 13137::bigint, 'Waasland-Beveren / SK Beveren'::text, 'NEWLY_CONFIRMED'::text)
),
validated_pairs AS (
    SELECT
        tm.*,
        ht.name AS historical_name,
        ht.ext_source AS historical_ext_source,
        ht.ext_team_id AS historical_ext_team_id,
        at.name AS api_name,
        at.ext_source AS api_ext_source,
        at.ext_team_id AS api_ext_team_id,
        hpm.provider_team_id AS historical_provider_team_id,
        apm.provider_team_id AS api_provider_team_id,

        (
            ht.id IS NOT NULL
            AND at.id IS NOT NULL
            AND ht.ext_source = 'football_data_uk'
            AND at.ext_source = 'api_football'
            AND hpm.team_id IS NOT NULL
            AND apm.team_id IS NOT NULL
            AND hpm.provider_team_id IS NOT DISTINCT FROM ht.ext_team_id
            AND apm.provider_team_id IS NOT DISTINCT FROM at.ext_team_id
        ) AS mapping_valid

    FROM team_map tm
    LEFT JOIN public.teams ht
        ON ht.id = tm.historical_team_id
    LEFT JOIN public.teams at
        ON at.id = tm.api_team_id
    LEFT JOIN public.team_provider_map hpm
        ON hpm.team_id = tm.historical_team_id
       AND hpm.provider = 'football_data_uk'
    LEFT JOIN public.team_provider_map apm
        ON apm.team_id = tm.api_team_id
       AND apm.provider = 'api_football'
),
legacy_matches AS (
    SELECT
        m.id AS historical_match_id,
        m.season,
        m.kickoff,
        m.home_team_id AS historical_home_team_id,
        ht.name AS historical_home_name,
        m.away_team_id AS historical_away_team_id,
        at.name AS historical_away_name,
        m.home_score,
        m.away_score,
        m.status,
        m.ext_match_id,

        hm.api_team_id AS target_home_team_id,
        am.api_team_id AS target_away_team_id,

        CASE
            WHEN hm.api_team_id IS NOT NULL
             AND am.api_team_id IS NOT NULL
                THEN 'FULLY_MAPPABLE'
            WHEN hm.api_team_id IS NOT NULL
              OR am.api_team_id IS NOT NULL
                THEN 'PARTIALLY_MAPPABLE'
            ELSE 'UNMAPPED_TEAM_REQUIRED'
        END AS mapping_class,

        CASE
            WHEN m.home_team_id IN (970, 987)
              OR m.away_team_id IN (970, 987)
                THEN true
            ELSE false
        END AS contains_newly_confirmed_team

    FROM public.matches m
    LEFT JOIN public.teams ht
        ON ht.id = m.home_team_id
    LEFT JOIN public.teams at
        ON at.id = m.away_team_id
    LEFT JOIN validated_pairs hm
        ON hm.historical_team_id = m.home_team_id
       AND hm.mapping_valid
    LEFT JOIN validated_pairs am
        ON am.historical_team_id = m.away_team_id
       AND am.mapping_valid
    WHERE m.sport_id = 1
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
),
new_candidates AS (
    SELECT *
    FROM legacy_matches
    WHERE mapping_class = 'FULLY_MAPPABLE'
      AND contains_newly_confirmed_team
),
api_overlap_rows AS (
    SELECT
        h.historical_match_id,
        a.id AS api_match_id,
        a.kickoff AS api_kickoff,
        a.home_score AS api_home_score,
        a.away_score AS api_away_score,
        a.ext_source AS api_ext_source,
        a.ext_match_id AS api_ext_match_id,

        (
            h.home_score IS NOT DISTINCT FROM a.home_score
            AND h.away_score IS NOT DISTINCT FROM a.away_score
        ) AS same_score

    FROM new_candidates h
    JOIN public.matches a
        ON a.sport_id = 1
       AND a.league_id = 20853
       AND a.ext_source = 'api_football'
       AND a.home_team_id = h.target_home_team_id
       AND a.away_team_id = h.target_away_team_id
       AND a.kickoff::date = h.kickoff::date
       AND a.id <> h.historical_match_id
),
overlap_summary AS (
    SELECT
        h.historical_match_id,
        COUNT(a.api_match_id)::bigint AS api_candidate_count,
        COUNT(a.api_match_id) FILTER (
            WHERE a.same_score
        )::bigint AS same_score_count,
        COUNT(a.api_match_id) FILTER (
            WHERE NOT a.same_score
        )::bigint AS score_conflict_count
    FROM new_candidates h
    LEFT JOIN api_overlap_rows a
        ON a.historical_match_id = h.historical_match_id
    GROUP BY h.historical_match_id
),
classified_candidates AS (
    SELECT
        h.*,
        o.api_candidate_count,
        o.same_score_count,
        o.score_conflict_count,

        CASE
            WHEN o.api_candidate_count = 0
                THEN 'UNIQUE_HISTORY'
            WHEN o.api_candidate_count = 1
             AND o.same_score_count = 1
                THEN 'SAME_SCORE_OVERLAP'
            WHEN o.api_candidate_count = 1
             AND o.score_conflict_count = 1
                THEN 'SCORE_CONFLICT_REVIEW'
            ELSE 'AMBIGUOUS_API_MATCH'
        END AS overlap_class

    FROM new_candidates h
    JOIN overlap_summary o
        ON o.historical_match_id = h.historical_match_id
),
report_rows AS (
    SELECT
        10 AS sort_order,
        'KONTROLA'::text AS sekce,
        'TRANSACTION_READ_ONLY'::text AS kontrola,
        CASE
            WHEN current_setting('transaction_read_only') = 'on'
                THEN 'OK'
            ELSE 'REVIEW_REQUIRED'
        END AS stav,
        1::bigint AS ocekavano,
        CASE
            WHEN current_setting('transaction_read_only') = 'on'
                THEN 1::bigint
            ELSE 0::bigint
        END AS skutecnost,
        current_setting('transaction_isolation')::text AS detail

    UNION ALL

    SELECT
        20,
        'TEAM_MAP',
        'NEWLY_CONFIRMED_PAIRS_VALID',
        CASE WHEN COUNT(*) = 2 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        2,
        COUNT(*)::bigint,
        COALESCE(
            string_agg(
                team_label || ': '
                || historical_team_id::text
                || ' → '
                || api_team_id::text,
                ', ' ORDER BY team_label
            ),
            'ŽÁDNÉ'
        )
    FROM validated_pairs
    WHERE mapping_stage = 'NEWLY_CONFIRMED'
      AND mapping_valid

    UNION ALL

    SELECT
        30,
        'TEAM_MAP',
        'INVALID_NEW_PAIRS',
        CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        0,
        COUNT(*)::bigint,
        COALESCE(
            string_agg(team_label, ', ' ORDER BY team_label),
            'ŽÁDNÉ'
        )
    FROM validated_pairs
    WHERE mapping_stage = 'NEWLY_CONFIRMED'
      AND NOT mapping_valid

    UNION ALL

    SELECT
        100,
        'ROZSAH',
        'LEGACY_MATCHES_TOTAL',
        CASE WHEN COUNT(*) = 231 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        231,
        COUNT(*)::bigint,
        NULL::text
    FROM legacy_matches

    UNION ALL

    SELECT
        110,
        'ROZSAH',
        'NEW_FULLY_MAPPABLE',
        CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        110,
        COUNT(*)::bigint,
        'Zápasy obsahující RAAL nebo Waasland-Beveren a dva potvrzené cílové týmy.'
    FROM new_candidates

    UNION ALL

    SELECT
        120,
        'ROZSAH',
        'REMAINING_PARTIALLY_MAPPABLE',
        CASE WHEN COUNT(*) = 119 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        119,
        COUNT(*)::bigint,
        NULL::text
    FROM legacy_matches
    WHERE mapping_class = 'PARTIALLY_MAPPABLE'

    UNION ALL

    SELECT
        130,
        'ROZSAH',
        'REMAINING_UNMAPPED_TEAM_REQUIRED',
        CASE WHEN COUNT(*) = 2 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        2,
        COUNT(*)::bigint,
        NULL::text
    FROM legacy_matches
    WHERE mapping_class = 'UNMAPPED_TEAM_REQUIRED'

    UNION ALL

    SELECT
        200 + ROW_NUMBER() OVER (
            ORDER BY overlap_class
        )::integer,
        'OVERLAP_CLASSIFICATION',
        overlap_class,
        'INFO',
        NULL::bigint,
        COUNT(*)::bigint,
        NULL::text
    FROM classified_candidates
    GROUP BY overlap_class

    UNION ALL

    SELECT
        300,
        'IDENTITY',
        'HISTORICAL_PROVIDER_IDENTITIES',
        CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        110,
        COUNT(*)::bigint,
        NULL::text
    FROM new_candidates h
    JOIN public.match_provider_map p
        ON p.match_id = h.historical_match_id
       AND p.provider = 'football_data_uk'
       AND p.provider_match_id = h.ext_match_id

    UNION ALL

    SELECT
        310,
        'DOWNSTREAM',
        'MATCHES_WITH_FEATURES',
        CASE WHEN COUNT(DISTINCT mf.match_id) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        110,
        COUNT(DISTINCT mf.match_id)::bigint,
        format('Feature řádků: %s', COUNT(mf.match_id))
    FROM new_candidates h
    LEFT JOIN public.match_features mf
        ON mf.match_id = h.historical_match_id

    UNION ALL

    SELECT
        320,
        'DOWNSTREAM',
        'MATCHES_WITH_RATINGS',
        CASE WHEN COUNT(DISTINCT r.match_id) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        110,
        COUNT(DISTINCT r.match_id)::bigint,
        format('Ratingových řádků: %s', COUNT(r.match_id))
    FROM new_candidates h
    LEFT JOIN public.mm_match_ratings r
        ON r.match_id = h.historical_match_id

    UNION ALL

    SELECT
        400,
        'RAAL',
        'STAGING_API_FIXTURES_2025_LEAGUE_144',
        CASE WHEN COUNT(DISTINCT f.fixture_id) = 0 THEN 'OK' ELSE 'INFO' END,
        0,
        COUNT(DISTINCT f.fixture_id)::bigint,
        'Nulový počet potvrzuje, že současné historické zápasy RAAL nemají ve stagingu překryv API-Football.'
    FROM staging.api_football_fixtures f
    WHERE (f.home_team_id = 5902 OR f.away_team_id = 5902)
      AND f.season = 2025
      AND f.league_id = 144

    UNION ALL

    SELECT
        999,
        'ZAVER',
        'READ_ONLY_AUDIT_STATUS',
        CASE
            WHEN (
                SELECT COUNT(*)
                FROM validated_pairs
                WHERE mapping_stage = 'NEWLY_CONFIRMED'
                  AND mapping_valid
            ) = 2
             AND (
                SELECT COUNT(*) FROM new_candidates
            ) = 110
             AND (
                SELECT COUNT(*)
                FROM legacy_matches
                WHERE mapping_class = 'PARTIALLY_MAPPABLE'
            ) = 119
             AND (
                SELECT COUNT(*)
                FROM legacy_matches
                WHERE mapping_class = 'UNMAPPED_TEAM_REQUIRED'
            ) = 2
            THEN 'READ_ONLY_AUDIT_OK'
            ELSE 'READ_ONLY_AUDIT_REVIEW_REQUIRED'
        END,
        110,
        (SELECT COUNT(*) FROM new_candidates)::bigint,
        'Výsledky překryvové klasifikace určují další postup.'
)
SELECT
    sekce,
    kontrola,
    stav,
    ocekavano,
    skutecnost,
    detail
FROM report_rows
ORDER BY
    sort_order,
    sekce,
    kontrola;


-- ============================================================================
-- VÝSTUP 2
-- DETAIL PŘÍPADNÝCH API PŘEKRYVŮ NEBO KONFLIKTŮ
-- Pokud je výstup prázdný, všech 110 zápasů je UNIQUE_HISTORY.
-- ============================================================================

WITH
team_map (
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
        (973::bigint, 13279::bigint),
        (970::bigint, 12427::bigint),
        (987::bigint, 13137::bigint)
),
historical_candidates AS (
    SELECT
        h.id AS historical_match_id,
        h.season,
        h.kickoff AS historical_kickoff,
        h.home_team_id AS historical_home_team_id,
        hht.name AS historical_home_name,
        h.away_team_id AS historical_away_team_id,
        hat.name AS historical_away_name,
        h.home_score AS historical_home_score,
        h.away_score AS historical_away_score,
        h.ext_match_id AS historical_ext_match_id,
        hm.api_team_id AS target_home_team_id,
        am.api_team_id AS target_away_team_id
    FROM public.matches h
    JOIN team_map hm
        ON hm.historical_team_id = h.home_team_id
    JOIN team_map am
        ON am.historical_team_id = h.away_team_id
    LEFT JOIN public.teams hht
        ON hht.id = h.home_team_id
    LEFT JOIN public.teams hat
        ON hat.id = h.away_team_id
    WHERE h.sport_id = 1
      AND h.league_id = 4
      AND h.ext_source = 'football_data_uk'
      AND (
          h.home_team_id IN (970, 987)
          OR h.away_team_id IN (970, 987)
      )
)
SELECT
    h.historical_match_id,
    h.season,
    h.historical_kickoff,
    h.historical_home_name,
    h.historical_away_name,
    h.historical_home_score,
    h.historical_away_score,
    h.historical_ext_match_id,

    a.id AS api_match_id,
    a.kickoff AS api_kickoff,
    aht.name AS api_home_name,
    aat.name AS api_away_name,
    a.home_score AS api_home_score,
    a.away_score AS api_away_score,
    a.ext_match_id AS api_ext_match_id,

    CASE
        WHEN h.historical_home_score IS NOT DISTINCT FROM a.home_score
         AND h.historical_away_score IS NOT DISTINCT FROM a.away_score
            THEN 'SAME_SCORE_OVERLAP'
        ELSE 'SCORE_CONFLICT_REVIEW'
    END AS overlap_result

FROM historical_candidates h
JOIN public.matches a
    ON a.sport_id = 1
   AND a.league_id = 20853
   AND a.ext_source = 'api_football'
   AND a.home_team_id = h.target_home_team_id
   AND a.away_team_id = h.target_away_team_id
   AND a.kickoff::date = h.historical_kickoff::date
   AND a.id <> h.historical_match_id
LEFT JOIN public.teams aht
    ON aht.id = a.home_team_id
LEFT JOIN public.teams aat
    ON aat.id = a.away_team_id
ORDER BY
    h.historical_kickoff,
    h.historical_match_id,
    a.id;


ROLLBACK;