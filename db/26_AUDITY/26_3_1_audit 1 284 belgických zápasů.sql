BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;
SET LOCAL TIME ZONE 'UTC';

WITH
confirmed_team_pairs(fd_uk_team_id, api_team_id, pair_label) AS (
    VALUES
        (972, 12940, 'Anderlecht'),
        (964, 13172, 'Antwerp'),
        (980, 12515, 'Beerschot VA'),
        (967, 12844, 'Cercle Brugge'),
        (975, 13032, 'Charleroi'),
        (976, 12803, 'Club Brugge'),
        (966, 12665, 'Dender'),
        (982, 13516, 'Eupen'),
        (977, 12254, 'Genk'),
        (979, 12719, 'Gent'),
        (981, 13043, 'Kortrijk'),
        (969, 12517, 'Mechelen'),
        (985, 15765, 'Oostende'),
        (974, 12636, 'OH Leuven'),
        (983, 13328, 'RWD Molenbeek'),
        (984, 12565, 'Seraing'),
        (971, 13537, 'Standard Liege'),
        (965, 13160, 'Union St. Gilloise'),
        (978, 12277, 'St. Truiden'),
        (968, 12993, 'Zulte Waregem'),
        (973, 13279, 'Westerlo')
),
validated_team_map AS (
    SELECT
        p.fd_uk_team_id,
        p.api_team_id,
        p.pair_label,
        ht.name AS historical_team_name,
        ht.ext_source AS historical_ext_source,
        ht.ext_team_id AS historical_ext_team_id,
        at.name AS api_team_name,
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
            AND hpm.provider_team_id = ht.ext_team_id
            AND apm.provider_team_id = at.ext_team_id
        ) AS mapping_confirmed
    FROM confirmed_team_pairs p
    LEFT JOIN public.teams ht
        ON ht.id = p.fd_uk_team_id
    LEFT JOIN public.teams at
        ON at.id = p.api_team_id
    LEFT JOIN public.team_provider_map hpm
        ON hpm.team_id = p.fd_uk_team_id
       AND hpm.provider = 'football_data_uk'
    LEFT JOIN public.team_provider_map apm
        ON apm.team_id = p.api_team_id
       AND apm.provider = 'api_football'
),
scope_matches AS (
    SELECT m.*
    FROM public.matches m
    WHERE m.sport_id = 1
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
),
classified_matches AS (
    SELECT
        m.*,
        ht.name AS historical_home_name,
        at.name AS historical_away_name,
        CASE
            WHEN COALESCE(hm.mapping_confirmed, false)
            THEN hm.api_team_id
        END AS target_home_team_id,
        CASE
            WHEN COALESCE(am.mapping_confirmed, false)
            THEN am.api_team_id
        END AS target_away_team_id,
        CASE
            WHEN COALESCE(hm.mapping_confirmed, false)
            THEN hm.api_team_name
        END AS target_home_team_name,
        CASE
            WHEN COALESCE(am.mapping_confirmed, false)
            THEN am.api_team_name
        END AS target_away_team_name,
        COALESCE(hm.mapping_confirmed, false) AS home_team_mapped,
        COALESCE(am.mapping_confirmed, false) AS away_team_mapped,
        CASE
            WHEN COALESCE(hm.mapping_confirmed, false)
             AND COALESCE(am.mapping_confirmed, false)
                THEN 'FULLY_MAPPABLE'
            WHEN COALESCE(hm.mapping_confirmed, false)
              OR COALESCE(am.mapping_confirmed, false)
                THEN 'PARTIALLY_MAPPABLE'
            ELSE 'UNMAPPED_TEAM_REQUIRED'
        END AS mapping_class
    FROM scope_matches m
    LEFT JOIN public.teams ht
        ON ht.id = m.home_team_id
    LEFT JOIN public.teams at
        ON at.id = m.away_team_id
    LEFT JOIN validated_team_map hm
        ON hm.fd_uk_team_id = m.home_team_id
    LEFT JOIN validated_team_map am
        ON am.fd_uk_team_id = m.away_team_id
),
feature_stats AS (
    SELECT
        mf.match_id,
        COUNT(*)::bigint AS row_count
    FROM public.match_features mf
    JOIN scope_matches m
        ON m.id = mf.match_id
    GROUP BY mf.match_id
),
rating_stats AS (
    SELECT
        mr.match_id,
        COUNT(*)::bigint AS row_count,
        COUNT(*) FILTER (
            WHERE mr.league_id IS NOT DISTINCT FROM m.league_id
              AND mr.home_team_id IS NOT DISTINCT FROM m.home_team_id
              AND mr.away_team_id IS NOT DISTINCT FROM m.away_team_id
              AND mr.kickoff IS NOT DISTINCT FROM
                  (m.kickoff::timestamp AT TIME ZONE 'UTC')
        )::bigint AS current_dimension_ok_count
    FROM public.mm_match_ratings mr
    JOIN scope_matches m
        ON m.id = mr.match_id
    GROUP BY mr.match_id
),
identity_stats AS (
    SELECT
        m.id AS match_id,
        COUNT(mpm.id) FILTER (
            WHERE mpm.provider = 'football_data_uk'
              AND mpm.provider_match_id = m.ext_match_id
        )::bigint AS matching_identity_rows
    FROM scope_matches m
    LEFT JOIN public.match_provider_map mpm
        ON mpm.match_id = m.id
    GROUP BY m.id
),
enriched_matches AS (
    SELECT
        c.*,
        COALESCE(fs.row_count, 0)::bigint AS feature_rows,
        COALESCE(rs.row_count, 0)::bigint AS rating_rows,
        COALESCE(rs.current_dimension_ok_count, 0)::bigint
            AS rating_current_dimension_ok_rows,
        COALESCE(ids.matching_identity_rows, 0)::bigint
            AS matching_identity_rows
    FROM classified_matches c
    LEFT JOIN feature_stats fs
        ON fs.match_id = c.id
    LEFT JOIN rating_stats rs
        ON rs.match_id = c.id
    LEFT JOIN identity_stats ids
        ON ids.match_id = c.id
),
team_usage AS (
    SELECT
        u.team_id,
        COUNT(*)::bigint AS match_appearances,
        COUNT(*) FILTER (
            WHERE u.role_name = 'HOME'
        )::bigint AS home_appearances,
        COUNT(*) FILTER (
            WHERE u.role_name = 'AWAY'
        )::bigint AS away_appearances
    FROM (
        SELECT
            home_team_id AS team_id,
            'HOME'::text AS role_name
        FROM scope_matches

        UNION ALL

        SELECT
            away_team_id AS team_id,
            'AWAY'::text AS role_name
        FROM scope_matches
    ) u
    GROUP BY u.team_id
),
team_audit AS (
    SELECT
        tu.team_id AS historical_team_id,
        t.name AS historical_team_name,
        t.ext_team_id AS historical_ext_team_id,
        tu.match_appearances,
        tu.home_appearances,
        tu.away_appearances,
        vtm.api_team_id,
        vtm.api_team_name,
        vtm.api_ext_team_id,
        COALESCE(
            vtm.mapping_confirmed,
            false
        ) AS mapping_confirmed
    FROM team_usage tu
    LEFT JOIN public.teams t
        ON t.id = tu.team_id
    LEFT JOIN validated_team_map vtm
        ON vtm.fd_uk_team_id = tu.team_id
),
report_rows AS (
    SELECT
        10 AS sort_order,
        'KONTROLA'::text AS sekce,
        'DATABASE'::text AS polozka,
        current_database()::text AS hodnota,
        NULL::bigint AS pocet,
        NULL::text AS detail

    UNION ALL

    SELECT
        20,
        'KONTROLA',
        'TRANSACTION_READ_ONLY',
        current_setting('transaction_read_only'),
        NULL::bigint,
        NULL::text

    UNION ALL

    SELECT
        30,
        'KONTROLA',
        'TRANSACTION_ISOLATION',
        current_setting('transaction_isolation'),
        NULL::bigint,
        NULL::text

    UNION ALL

    SELECT
        40,
        'KONTROLA',
        'TIME_ZONE',
        current_setting('TimeZone'),
        NULL::bigint,
        NULL::text

    UNION ALL

    SELECT
        100,
        'ROZSAH',
        'MATCHES_IN_SCOPE',
        CASE
            WHEN COUNT(*) = 1284 THEN 'OK'
            ELSE 'ODCHYLKA'
        END,
        COUNT(*)::bigint,
        'Očekáváno 1 284 zápasů: sport_id=1, league_id=4, ext_source=football_data_uk'
    FROM scope_matches

    UNION ALL

    SELECT
        110,
        'ROZSAH',
        'SEASONS',
        COUNT(DISTINCT season)::text,
        COUNT(DISTINCT season)::bigint,
        NULL::text
    FROM scope_matches

    UNION ALL

    SELECT
        120,
        'ROZSAH',
        'UNIQUE_HISTORICAL_TEAMS',
        COUNT(*)::text,
        COUNT(*)::bigint,
        NULL::text
    FROM team_audit

    UNION ALL

    SELECT
        130,
        'ROZSAH',
        'KICKOFF_RANGE',
        COALESCE(
            to_char(MIN(kickoff), 'YYYY-MM-DD'),
            '-'
        )
        || ' -> '
        || COALESCE(
            to_char(MAX(kickoff), 'YYYY-MM-DD'),
            '-'
        ),
        COUNT(*)::bigint,
        NULL::text
    FROM scope_matches

    UNION ALL

    SELECT
        200,
        'TEAM_MAP_VALIDATION',
        'CONFIRMED_PAIR_ROWS_EXPECTED',
        CASE
            WHEN COUNT(*) = 21 THEN 'OK'
            ELSE 'ODCHYLKA'
        END,
        COUNT(*)::bigint,
        NULL::text
    FROM validated_team_map

    UNION ALL

    SELECT
        210,
        'TEAM_MAP_VALIDATION',
        'VALIDATED_PAIR_ROWS',
        CASE
            WHEN COUNT(*) = 21 THEN 'OK'
            ELSE 'REVIEW_REQUIRED'
        END,
        COUNT(*)::bigint,
        NULL::text
    FROM validated_team_map
    WHERE mapping_confirmed

    UNION ALL

    SELECT
        220,
        'TEAM_MAP_VALIDATION',
        'INVALID_PAIR_ROWS',
        CASE
            WHEN COUNT(*) = 0 THEN 'OK'
            ELSE 'REVIEW_REQUIRED'
        END,
        COUNT(*)::bigint,
        COALESCE(
            string_agg(
                pair_label,
                ', ' ORDER BY pair_label
            ),
            'ŽÁDNÉ'
        )
    FROM validated_team_map
    WHERE NOT mapping_confirmed

    UNION ALL

    SELECT
        300,
        'PROVIDER_IDENTITY',
        'MATCHES_WITH_FD_UK_IDENTITY',
        CASE
            WHEN COUNT(*) FILTER (
                WHERE matching_identity_rows > 0
            ) = COUNT(*)
            THEN 'OK'
            ELSE 'REVIEW_REQUIRED'
        END,
        COUNT(*) FILTER (
            WHERE matching_identity_rows > 0
        )::bigint,
        format(
            'Celkem v rozsahu: %s',
            COUNT(*)
        )
    FROM enriched_matches

    UNION ALL

    SELECT
        310,
        'PROVIDER_IDENTITY',
        'MATCHES_WITHOUT_FD_UK_IDENTITY',
        CASE
            WHEN COUNT(*) FILTER (
                WHERE matching_identity_rows = 0
            ) = 0
            THEN 'OK'
            ELSE 'REVIEW_REQUIRED'
        END,
        COUNT(*) FILTER (
            WHERE matching_identity_rows = 0
        )::bigint,
        NULL::text
    FROM enriched_matches

    UNION ALL

    SELECT
        400
        + ROW_NUMBER() OVER (
            ORDER BY mapping_class
        )::integer,
        'KLASIFIKACE',
        mapping_class,
        mapping_class,
        COUNT(*)::bigint,
        NULL::text
    FROM enriched_matches
    GROUP BY mapping_class

    UNION ALL

    SELECT
        500
        + ROW_NUMBER() OVER (
            ORDER BY season NULLS LAST
        )::integer,
        'SEZONY',
        COALESCE(
            season,
            '[NULL]'
        ),
        'ROZPAD PODLE MAPOVATELNOSTI',
        COUNT(*)::bigint,
        format(
            'FULLY_MAPPABLE=%s | PARTIALLY_MAPPABLE=%s | UNMAPPED_TEAM_REQUIRED=%s',
            COUNT(*) FILTER (
                WHERE mapping_class = 'FULLY_MAPPABLE'
            ),
            COUNT(*) FILTER (
                WHERE mapping_class = 'PARTIALLY_MAPPABLE'
            ),
            COUNT(*) FILTER (
                WHERE mapping_class = 'UNMAPPED_TEAM_REQUIRED'
            )
        )
    FROM enriched_matches
    GROUP BY season

    UNION ALL

    SELECT
        600
        + ROW_NUMBER() OVER (
            ORDER BY
                mapping_confirmed,
                historical_team_name NULLS LAST
        )::integer,
        'TYMY',
        COALESCE(
            historical_team_name,
            '[NEZNÁMÝ TÝM]'
        ),
        CASE
            WHEN mapping_confirmed
            THEN 'CONFIRMED'
            ELSE 'REVIEW_REQUIRED'
        END,
        match_appearances,
        format(
            'FD_UK_TEAM_ID=%s | FD_UK_EXT_ID=%s | API_TEAM_ID=%s | API_NAME=%s | API_EXT_ID=%s | HOME=%s | AWAY=%s',
            historical_team_id,
            COALESCE(
                historical_ext_team_id,
                '-'
            ),
            COALESCE(
                api_team_id::text,
                '-'
            ),
            COALESCE(
                api_team_name,
                '-'
            ),
            COALESCE(
                api_ext_team_id,
                '-'
            ),
            home_appearances,
            away_appearances
        )
    FROM team_audit

    UNION ALL

    SELECT
        700,
        'DOWNSTREAM',
        'MATCHES_WITH_MATCH_FEATURES',
        NULL::text,
        COUNT(*) FILTER (
            WHERE feature_rows > 0
        )::bigint,
        format(
            'Celkem feature řádků: %s',
            COALESCE(
                SUM(feature_rows),
                0
            )
        )
    FROM enriched_matches

    UNION ALL

    SELECT
        710,
        'DOWNSTREAM',
        'MATCHES_WITH_MM_MATCH_RATINGS',
        NULL::text,
        COUNT(*) FILTER (
            WHERE rating_rows > 0
        )::bigint,
        format(
            'Celkem ratingových řádků: %s',
            COALESCE(
                SUM(rating_rows),
                0
            )
        )
    FROM enriched_matches

    UNION ALL

    SELECT
        720,
        'DOWNSTREAM',
        'RATING_ROWS_CURRENT_DIMENSIONS_OK',
        CASE
            WHEN COALESCE(
                SUM(rating_rows),
                0
            ) = COALESCE(
                SUM(rating_current_dimension_ok_rows),
                0
            )
            THEN 'OK'
            ELSE 'REVIEW_REQUIRED'
        END,
        COALESCE(
            SUM(rating_current_dimension_ok_rows),
            0
        )::bigint,
        'Kontrolováno proti aktuálním league_id, kickoff UTC, home_team_id a away_team_id'
    FROM enriched_matches

    UNION ALL

    SELECT
        730,
        'DOWNSTREAM',
        'RATING_ROWS_CURRENT_DIMENSION_MISMATCH',
        CASE
            WHEN COALESCE(
                SUM(
                    rating_rows
                    - rating_current_dimension_ok_rows
                ),
                0
            ) = 0
            THEN 'OK'
            ELSE 'REVIEW_REQUIRED'
        END,
        COALESCE(
            SUM(
                rating_rows
                - rating_current_dimension_ok_rows
            ),
            0
        )::bigint,
        NULL::text
    FROM enriched_matches

    UNION ALL

    SELECT
        800,
        'OTEVRENE_TYMY',
        'TEAMS_WITHOUT_CONFIRMED_API_TARGET',
        CASE
            WHEN COUNT(*) = 4
            THEN 'EXPECTED_4'
            ELSE 'CHECK_COUNT'
        END,
        COUNT(*)::bigint,
        COALESCE(
            string_agg(
                format(
                    '%s [team_id=%s]',
                    historical_team_name,
                    historical_team_id
                ),
                ', ' ORDER BY historical_team_name
            ),
            'ŽÁDNÉ'
        )
    FROM team_audit
    WHERE NOT mapping_confirmed

    UNION ALL

    SELECT
        900,
        'ZAVER',
        'READ_ONLY_AUDIT_STATUS',
        CASE
            WHEN (
                SELECT COUNT(*)
                FROM scope_matches
            ) = 1284
             AND (
                SELECT COUNT(*)
                FROM validated_team_map
                WHERE mapping_confirmed
            ) = 21
             AND (
                SELECT COUNT(*)
                FROM enriched_matches
                WHERE matching_identity_rows = 0
            ) = 0
            THEN 'READ_ONLY_AUDIT_OK'
            ELSE 'READ_ONLY_AUDIT_REVIEW_REQUIRED'
        END,
        (
            SELECT COUNT(*)::bigint
            FROM scope_matches
        ),
        format(
            'FULLY=%s | PARTIAL=%s | UNMAPPED=%s | OPEN_TEAMS=%s',
            (
                SELECT COUNT(*)
                FROM enriched_matches
                WHERE mapping_class = 'FULLY_MAPPABLE'
            ),
            (
                SELECT COUNT(*)
                FROM enriched_matches
                WHERE mapping_class = 'PARTIALLY_MAPPABLE'
            ),
            (
                SELECT COUNT(*)
                FROM enriched_matches
                WHERE mapping_class = 'UNMAPPED_TEAM_REQUIRED'
            ),
            (
                SELECT COUNT(*)
                FROM team_audit
                WHERE NOT mapping_confirmed
            )
        )
)
SELECT
    sekce,
    polozka,
    hodnota,
    pocet,
    detail
FROM report_rows
ORDER BY
    sort_order,
    sekce,
    polozka;

ROLLBACK;