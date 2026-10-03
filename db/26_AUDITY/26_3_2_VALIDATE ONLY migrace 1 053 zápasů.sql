BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SET LOCAL TIME ZONE 'UTC';
SET LOCAL lock_timeout = '10s';
SET LOCAL statement_timeout = '15min';

-- ============================================================================
-- 1. POTVRZENÁ MAPA HISTORICKÝCH A KANONICKÝCH API TÝMŮ
-- ============================================================================

CREATE TEMP TABLE mm_belgium_team_map (
    fd_uk_team_id bigint PRIMARY KEY,
    api_team_id   bigint NOT NULL,
    pair_label    text NOT NULL
) ON COMMIT DROP;

INSERT INTO mm_belgium_team_map (
    fd_uk_team_id,
    api_team_id,
    pair_label
)
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
    (973, 13279, 'Westerlo');

-- ============================================================================
-- 2. PŘESNÁ SADA 1 053 PLNĚ MAPOVATELNÝCH ZÁPASŮ
-- ============================================================================

CREATE TEMP TABLE mm_belgium_1053_candidates
ON COMMIT DROP
AS
SELECT
    m.id AS match_id,
    m.league_id AS original_league_id,
    m.home_team_id AS original_home_team_id,
    m.away_team_id AS original_away_team_id,
    hm.api_team_id AS target_home_team_id,
    am.api_team_id AS target_away_team_id,
    m.kickoff,
    m.ext_source,
    m.ext_match_id,
    m.season
FROM public.matches m
JOIN mm_belgium_team_map hm
    ON hm.fd_uk_team_id = m.home_team_id
JOIN mm_belgium_team_map am
    ON am.fd_uk_team_id = m.away_team_id
WHERE m.sport_id = 1
  AND m.league_id = 4
  AND m.ext_source = 'football_data_uk';

ALTER TABLE mm_belgium_1053_candidates
    ADD PRIMARY KEY (match_id);

-- ============================================================================
-- 3. VÝCHOZÍ KONTROLNÍ SNAPSHOT
-- ============================================================================

CREATE TEMP TABLE mm_belgium_baseline
ON COMMIT DROP
AS
SELECT
    (
        SELECT COUNT(*)
        FROM public.matches
    )::bigint AS matches_total,

    (
        SELECT COUNT(*)
        FROM public.match_provider_map
    )::bigint AS provider_map_total,

    (
        SELECT COUNT(*)
        FROM public.mm_match_ratings r
        LEFT JOIN public.matches m
            ON m.id = r.match_id
        WHERE m.id IS NULL
    )::bigint AS global_rating_orphans,

    (
        SELECT COUNT(*)
        FROM public.matches
        WHERE sport_id = 1
          AND league_id = 4
          AND ext_source = 'football_data_uk'
    )::bigint AS legacy_scope_matches,

    (
        SELECT COUNT(*)
        FROM mm_belgium_1053_candidates
    )::bigint AS candidate_matches,

    (
        SELECT COUNT(*)
        FROM public.leagues
        WHERE id = 20853
    )::bigint AS target_league_rows,

    (
        SELECT COUNT(*)
        FROM mm_belgium_team_map p
        WHERE EXISTS (
            SELECT 1
            FROM public.teams ht
            JOIN public.team_provider_map hpm
                ON hpm.team_id = ht.id
               AND hpm.provider = 'football_data_uk'
               AND hpm.provider_team_id = ht.ext_team_id
            WHERE ht.id = p.fd_uk_team_id
              AND ht.ext_source = 'football_data_uk'
        )
        AND EXISTS (
            SELECT 1
            FROM public.teams at
            JOIN public.team_provider_map apm
                ON apm.team_id = at.id
               AND apm.provider = 'api_football'
               AND apm.provider_team_id = at.ext_team_id
            WHERE at.id = p.api_team_id
              AND at.ext_source = 'api_football'
        )
    )::bigint AS validated_team_pairs,

    (
        SELECT COUNT(*)
        FROM public.match_features mf
        JOIN mm_belgium_1053_candidates c
            ON c.match_id = mf.match_id
    )::bigint AS feature_rows,

    (
        SELECT COUNT(DISTINCT mf.match_id)
        FROM public.match_features mf
        JOIN mm_belgium_1053_candidates c
            ON c.match_id = mf.match_id
    )::bigint AS feature_matches,

    (
        SELECT COUNT(*)
        FROM public.mm_match_ratings r
        JOIN mm_belgium_1053_candidates c
            ON c.match_id = r.match_id
    )::bigint AS rating_rows,

    (
        SELECT COUNT(DISTINCT r.match_id)
        FROM public.mm_match_ratings r
        JOIN mm_belgium_1053_candidates c
            ON c.match_id = r.match_id
    )::bigint AS rating_matches,

    (
        SELECT COUNT(*)
        FROM public.mm_match_ratings r
        JOIN mm_belgium_1053_candidates c
            ON c.match_id = r.match_id
        WHERE r.league_id IS NOT DISTINCT FROM c.original_league_id
          AND r.home_team_id IS NOT DISTINCT FROM c.original_home_team_id
          AND r.away_team_id IS NOT DISTINCT FROM c.original_away_team_id
          AND r.kickoff IS NOT DISTINCT FROM
              (c.kickoff::timestamp AT TIME ZONE 'UTC')
    )::bigint AS rating_dimensions_before_ok,

    (
        SELECT COUNT(*)
        FROM public.match_provider_map p
        JOIN mm_belgium_1053_candidates c
            ON c.match_id = p.match_id
        WHERE p.provider = 'football_data_uk'
          AND p.provider_match_id = c.ext_match_id
    )::bigint AS historical_identity_rows;

-- ============================================================================
-- 4. BEZPEČNOSTNÍ BRÁNA
-- ZMĚNY PROBĚHNOU POUZE PŘI PŘESNĚ OČEKÁVANÉM STAVU
-- ============================================================================

CREATE TEMP TABLE mm_belgium_guard
ON COMMIT DROP
AS
SELECT
    (
        legacy_scope_matches = 1284
        AND candidate_matches = 1053
        AND target_league_rows = 1
        AND validated_team_pairs = 21
        AND feature_rows = 1053
        AND feature_matches = 1053
        AND rating_rows = 1053
        AND rating_matches = 1053
        AND rating_dimensions_before_ok = 1053
        AND historical_identity_rows = 1053
    ) AS can_run
FROM mm_belgium_baseline;

-- ============================================================================
-- 5. SNAPSHOT OBSAHU PŘED ZKUŠEBNÍ ZMĚNOU
-- ============================================================================

CREATE TEMP TABLE mm_belgium_match_payload_before
ON COMMIT DROP
AS
SELECT
    m.id AS match_id,
    md5(
        (
            to_jsonb(m)
            - ARRAY[
                'league_id',
                'home_team_id',
                'away_team_id',
                'updated_at'
            ]::text[]
        )::text
    ) AS payload_hash,
    m.ext_source,
    m.ext_match_id
FROM public.matches m
JOIN mm_belgium_1053_candidates c
    ON c.match_id = m.id;

CREATE TEMP TABLE mm_belgium_rating_payload_before
ON COMMIT DROP
AS
SELECT
    r.match_id,
    md5(
        (
            to_jsonb(r)
            - ARRAY[
                'league_id',
                'home_team_id',
                'away_team_id',
                'kickoff',
                'updated_at'
            ]::text[]
        )::text
    ) AS payload_hash
FROM public.mm_match_ratings r
JOIN mm_belgium_1053_candidates c
    ON c.match_id = r.match_id;

-- ============================================================================
-- 6. VALIDATE ONLY – ZKUŠEBNÍ ZMĚNA KANONICKÝCH DIMENZÍ ZÁPASŮ
-- ============================================================================

CREATE TEMP TABLE mm_belgium_match_update_result
ON COMMIT DROP
AS
WITH updated AS (
    UPDATE public.matches m
    SET
        league_id = 20853,
        home_team_id = c.target_home_team_id,
        away_team_id = c.target_away_team_id
    FROM mm_belgium_1053_candidates c
    CROSS JOIN mm_belgium_guard g
    WHERE g.can_run
      AND m.id = c.match_id
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
    RETURNING m.id
)
SELECT COUNT(*)::bigint AS updated_rows
FROM updated;

-- ============================================================================
-- 7. VALIDATE ONLY – ZKUŠEBNÍ SJEDNOCENÍ RATINGOVÝCH DIMENZÍ
-- Ratingové metriky se nemění.
-- ============================================================================

CREATE TEMP TABLE mm_belgium_rating_update_result
ON COMMIT DROP
AS
WITH updated AS (
    UPDATE public.mm_match_ratings r
    SET
        league_id = 20853,
        home_team_id = c.target_home_team_id,
        away_team_id = c.target_away_team_id,
        kickoff = m.kickoff::timestamp AT TIME ZONE 'UTC'
    FROM mm_belgium_1053_candidates c
    JOIN public.matches m
        ON m.id = c.match_id
    CROSS JOIN mm_belgium_guard g
    WHERE g.can_run
      AND r.match_id = c.match_id
    RETURNING r.match_id
)
SELECT COUNT(*)::bigint AS updated_rows
FROM updated;

-- ============================================================================
-- 8. KLASIFIKACE 231 ZÁPASŮ, KTERÉ MUSÍ ZŮSTAT V LEGACY STAVU
-- ============================================================================

CREATE TEMP TABLE mm_belgium_remaining_classification
ON COMMIT DROP
AS
SELECT
    CASE
        WHEN hm.fd_uk_team_id IS NOT NULL
         AND am.fd_uk_team_id IS NOT NULL
            THEN 'FULLY_MAPPABLE'
        WHEN hm.fd_uk_team_id IS NOT NULL
          OR am.fd_uk_team_id IS NOT NULL
            THEN 'PARTIALLY_MAPPABLE'
        ELSE 'UNMAPPED_TEAM_REQUIRED'
    END AS mapping_class,
    COUNT(*)::bigint AS match_count
FROM public.matches m
LEFT JOIN mm_belgium_team_map hm
    ON hm.fd_uk_team_id = m.home_team_id
LEFT JOIN mm_belgium_team_map am
    ON am.fd_uk_team_id = m.away_team_id
WHERE m.sport_id = 1
  AND m.league_id = 4
  AND m.ext_source = 'football_data_uk'
GROUP BY 1;

-- ============================================================================
-- 9. VÝSLEDKOVÁ TABULKA
-- ============================================================================

CREATE TEMP TABLE mm_belgium_validation_report (
    sort_order integer,
    sekce text,
    kontrola text,
    stav text,
    ocekavano bigint,
    skutecnost bigint,
    detail text
) ON COMMIT DROP;

INSERT INTO mm_belgium_validation_report
SELECT
    10,
    'PRECHECK',
    'SAFETY_GUARD',
    CASE WHEN can_run THEN 'OK' ELSE 'BLOCKED' END,
    1,
    CASE WHEN can_run THEN 1 ELSE 0 END,
    'Změny byly povoleny pouze při přesném splnění všech vstupních podmínek.'
FROM mm_belgium_guard;

INSERT INTO mm_belgium_validation_report
SELECT
    20,
    'PRECHECK',
    'LEGACY_SCOPE_MATCHES',
    CASE WHEN legacy_scope_matches = 1284 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    1284,
    legacy_scope_matches,
    NULL
FROM mm_belgium_baseline;

INSERT INTO mm_belgium_validation_report
SELECT
    30,
    'PRECHECK',
    'FULLY_MAPPABLE_CANDIDATES',
    CASE WHEN candidate_matches = 1053 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    1053,
    candidate_matches,
    NULL
FROM mm_belgium_baseline;

INSERT INTO mm_belgium_validation_report
SELECT
    40,
    'PRECHECK',
    'VALIDATED_TEAM_PAIRS',
    CASE WHEN validated_team_pairs = 21 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    21,
    validated_team_pairs,
    NULL
FROM mm_belgium_baseline;

INSERT INTO mm_belgium_validation_report
SELECT
    100,
    'VALIDATE_ONLY',
    'MATCHES_UPDATED',
    CASE WHEN updated_rows = 1053 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    1053,
    updated_rows,
    'Pouze league_id, home_team_id a away_team_id.'
FROM mm_belgium_match_update_result;

INSERT INTO mm_belgium_validation_report
SELECT
    110,
    'VALIDATE_ONLY',
    'RATINGS_UPDATED',
    CASE WHEN updated_rows = 1053 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    1053,
    updated_rows,
    'Pouze league_id, home_team_id, away_team_id a kickoff UTC.'
FROM mm_belgium_rating_update_result;

INSERT INTO mm_belgium_validation_report
SELECT
    200,
    'POSTCHECK',
    'TARGET_MATCH_DIMENSIONS_OK',
    CASE WHEN COUNT(*) = 1053 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    1053,
    COUNT(*)::bigint,
    NULL
FROM public.matches m
JOIN mm_belgium_1053_candidates c
    ON c.match_id = m.id
WHERE m.league_id = 20853
  AND m.home_team_id = c.target_home_team_id
  AND m.away_team_id = c.target_away_team_id;

INSERT INTO mm_belgium_validation_report
SELECT
    210,
    'POSTCHECK',
    'CANDIDATES_REMAINING_IN_LEGACY',
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    0,
    COUNT(*)::bigint,
    NULL
FROM public.matches m
JOIN mm_belgium_1053_candidates c
    ON c.match_id = m.id
WHERE m.league_id = 4;

INSERT INTO mm_belgium_validation_report
SELECT
    220,
    'POSTCHECK',
    'LEGACY_MATCHES_REMAINING',
    CASE WHEN COUNT(*) = 231 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    231,
    COUNT(*)::bigint,
    'Pouze zápasy obsahující jeden nebo dva otevřené historické týmy.'
FROM public.matches
WHERE sport_id = 1
  AND league_id = 4
  AND ext_source = 'football_data_uk';

INSERT INTO mm_belgium_validation_report
SELECT
    230,
    'POSTCHECK',
    'REMAINING_PARTIALLY_MAPPABLE',
    CASE WHEN COALESCE(MAX(match_count), 0) = 221 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    221,
    COALESCE(MAX(match_count), 0),
    NULL
FROM mm_belgium_remaining_classification
WHERE mapping_class = 'PARTIALLY_MAPPABLE';

INSERT INTO mm_belgium_validation_report
SELECT
    240,
    'POSTCHECK',
    'REMAINING_UNMAPPED_TEAM_REQUIRED',
    CASE WHEN COALESCE(MAX(match_count), 0) = 10 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    10,
    COALESCE(MAX(match_count), 0),
    NULL
FROM mm_belgium_remaining_classification
WHERE mapping_class = 'UNMAPPED_TEAM_REQUIRED';

INSERT INTO mm_belgium_validation_report
SELECT
    250,
    'POSTCHECK',
    'REMAINING_FULLY_MAPPABLE',
    CASE WHEN COALESCE(MAX(match_count), 0) = 0 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    0,
    COALESCE(MAX(match_count), 0),
    NULL
FROM mm_belgium_remaining_classification
WHERE mapping_class = 'FULLY_MAPPABLE';

INSERT INTO mm_belgium_validation_report
SELECT
    300,
    'DOWNSTREAM',
    'MATCH_FEATURE_ROWS_PRESERVED',
    CASE WHEN COUNT(*) = 1053 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    1053,
    COUNT(*)::bigint,
    'match_id se nemění, proto se feature řádky nepřevádějí.'
FROM public.match_features mf
JOIN mm_belgium_1053_candidates c
    ON c.match_id = mf.match_id;

INSERT INTO mm_belgium_validation_report
SELECT
    310,
    'DOWNSTREAM',
    'RATING_DIMENSIONS_ALIGNED',
    CASE WHEN COUNT(*) = 1053 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    1053,
    COUNT(*)::bigint,
    NULL
FROM public.mm_match_ratings r
JOIN mm_belgium_1053_candidates c
    ON c.match_id = r.match_id
JOIN public.matches m
    ON m.id = c.match_id
WHERE r.league_id = 20853
  AND r.home_team_id = c.target_home_team_id
  AND r.away_team_id = c.target_away_team_id
  AND r.kickoff IS NOT DISTINCT FROM
      (m.kickoff::timestamp AT TIME ZONE 'UTC');

INSERT INTO mm_belgium_validation_report
SELECT
    320,
    'DOWNSTREAM',
    'RATING_PAYLOAD_UNCHANGED',
    CASE WHEN COUNT(*) = 1053 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    1053,
    COUNT(*)::bigint,
    'Kontrola všech nedimenzionálních hodnot ratingu.'
FROM mm_belgium_rating_payload_before b
JOIN public.mm_match_ratings r
    ON r.match_id = b.match_id
WHERE b.payload_hash = md5(
    (
        to_jsonb(r)
        - ARRAY[
            'league_id',
            'home_team_id',
            'away_team_id',
            'kickoff',
            'updated_at'
        ]::text[]
    )::text
);

INSERT INTO mm_belgium_validation_report
SELECT
    330,
    'IDENTITY',
    'MATCH_PAYLOAD_UNCHANGED',
    CASE WHEN COUNT(*) = 1053 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    1053,
    COUNT(*)::bigint,
    'Mimo league_id a týmových dimenzí se obsah zápasu nezměnil.'
FROM mm_belgium_match_payload_before b
JOIN public.matches m
    ON m.id = b.match_id
WHERE b.payload_hash = md5(
    (
        to_jsonb(m)
        - ARRAY[
            'league_id',
            'home_team_id',
            'away_team_id',
            'updated_at'
        ]::text[]
    )::text
);

INSERT INTO mm_belgium_validation_report
SELECT
    340,
    'IDENTITY',
    'HISTORICAL_EXT_IDENTITY_UNCHANGED',
    CASE WHEN COUNT(*) = 1053 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    1053,
    COUNT(*)::bigint,
    'ext_source a ext_match_id zůstávají historické.'
FROM mm_belgium_match_payload_before b
JOIN public.matches m
    ON m.id = b.match_id
WHERE m.ext_source IS NOT DISTINCT FROM b.ext_source
  AND m.ext_match_id IS NOT DISTINCT FROM b.ext_match_id;

INSERT INTO mm_belgium_validation_report
SELECT
    350,
    'IDENTITY',
    'PROVIDER_IDENTITIES_PRESERVED',
    CASE WHEN COUNT(*) = 1053 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    1053,
    COUNT(*)::bigint,
    NULL
FROM public.match_provider_map p
JOIN mm_belgium_1053_candidates c
    ON c.match_id = p.match_id
WHERE p.provider = 'football_data_uk'
  AND p.provider_match_id = c.ext_match_id;

INSERT INTO mm_belgium_validation_report
SELECT
    400,
    'GLOBAL',
    'MATCH_COUNT_UNCHANGED',
    CASE
        WHEN COUNT(*) = b.matches_total THEN 'OK'
        ELSE 'REVIEW_REQUIRED'
    END,
    b.matches_total,
    COUNT(*)::bigint,
    NULL
FROM public.matches
CROSS JOIN mm_belgium_baseline b
GROUP BY b.matches_total;

INSERT INTO mm_belgium_validation_report
SELECT
    410,
    'GLOBAL',
    'PROVIDER_MAP_COUNT_UNCHANGED',
    CASE
        WHEN COUNT(*) = b.provider_map_total THEN 'OK'
        ELSE 'REVIEW_REQUIRED'
    END,
    b.provider_map_total,
    COUNT(*)::bigint,
    NULL
FROM public.match_provider_map
CROSS JOIN mm_belgium_baseline b
GROUP BY b.provider_map_total;

INSERT INTO mm_belgium_validation_report
SELECT
    420,
    'GLOBAL',
    'GLOBAL_RATING_ORPHANS_UNCHANGED',
    CASE
        WHEN COUNT(*) = b.global_rating_orphans THEN 'OK'
        ELSE 'REVIEW_REQUIRED'
    END,
    b.global_rating_orphans,
    COUNT(*)::bigint,
    'Globální orphan sada se v této etapě neopravuje.'
FROM public.mm_match_ratings r
LEFT JOIN public.matches m
    ON m.id = r.match_id
CROSS JOIN mm_belgium_baseline b
WHERE m.id IS NULL
GROUP BY b.global_rating_orphans;

INSERT INTO mm_belgium_validation_report
SELECT
    999,
    'ZAVER',
    'VALIDATE_ONLY_STATUS',
    CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM mm_belgium_validation_report
            WHERE stav <> 'OK'
        )
        THEN 'VALIDATE_ONLY_ROLLBACK_OK'
        ELSE 'VALIDATE_ONLY_REVIEW_REQUIRED'
    END,
    1053,
    (
        SELECT updated_rows
        FROM mm_belgium_match_update_result
    ),
    'Po zobrazení výsledku následuje povinný ROLLBACK.';

SELECT
    sekce,
    kontrola,
    stav,
    ocekavano,
    skutecnost,
    detail
FROM mm_belgium_validation_report
ORDER BY sort_order;

ROLLBACK;