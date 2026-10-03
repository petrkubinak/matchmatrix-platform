-- ============================================================================
-- MATCHMATRIX
-- BELGIUM JUPILER PRO LEAGUE
-- APPLY 110 PLNĚ MAPOVATELNÝCH HISTORICKÝCH ZÁPASŮ
--
-- Změny:
--   public.matches:
--     league_id, home_team_id, away_team_id
--
--   public.mm_match_ratings:
--     league_id, home_team_id, away_team_id, kickoff UTC
--
-- Nemění se:
--   match_id
--   ext_source
--   ext_match_id
--   providerové identity
--   match_features
--   výpočtové hodnoty ratingů
--
-- Po úspěšném COMMIT následuje READ ONLY post-commit audit.
-- ============================================================================


-- ============================================================================
-- A. APPLY TRANSAKCE
-- ============================================================================

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SET LOCAL TIME ZONE 'UTC';
SET LOCAL lock_timeout = '15s';
SET LOCAL statement_timeout = '15min';

SELECT pg_advisory_xact_lock(
    hashtext('MM_BELGIUM_110_CANONICALIZATION_APPLY_V1')
);

LOCK TABLE
    public.matches,
    public.mm_match_ratings
IN SHARE ROW EXCLUSIVE MODE;

LOCK TABLE
    public.match_features,
    public.match_provider_map,
    public.teams,
    public.team_provider_map,
    public.leagues
IN SHARE MODE;


-- ============================================================================
-- 1. ODSTRANĚNÍ PŘÍPADNÝCH TEMP TABULEK Z PŘEDCHOZÍHO BĚHU
-- ============================================================================

DROP TABLE IF EXISTS pg_temp.mm_belgium_team_map;
DROP TABLE IF EXISTS pg_temp.mm_belgium_110_candidates;
DROP TABLE IF EXISTS pg_temp.mm_belgium_baseline;
DROP TABLE IF EXISTS pg_temp.mm_belgium_guard;
DROP TABLE IF EXISTS pg_temp.mm_belgium_match_payload_before;
DROP TABLE IF EXISTS pg_temp.mm_belgium_rating_payload_before;
DROP TABLE IF EXISTS pg_temp.mm_belgium_match_update_result;
DROP TABLE IF EXISTS pg_temp.mm_belgium_rating_update_result;
DROP TABLE IF EXISTS pg_temp.mm_belgium_remaining_classification;
DROP TABLE IF EXISTS pg_temp.mm_belgium_apply_report;


-- ============================================================================
-- 2. POTVRZENÁ MAPA 23 HISTORICKÝCH A API TÝMŮ
-- ============================================================================

CREATE TEMP TABLE mm_belgium_team_map (
    fd_uk_team_id bigint PRIMARY KEY,
    api_team_id   bigint NOT NULL,
    pair_label    text NOT NULL
)
ON COMMIT PRESERVE ROWS;

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
    (973, 13279, 'Westerlo'),
    (970, 12427, 'RAAL La Louviere'),
    (987, 13137, 'Waasland-Beveren / SK Beveren');


-- ============================================================================
-- 3. PŘESNÁ SADA 110 PLNĚ MAPOVATELNÝCH ZÁPASŮ
-- ============================================================================

CREATE TEMP TABLE mm_belgium_110_candidates
ON COMMIT PRESERVE ROWS
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

ALTER TABLE mm_belgium_110_candidates
    ADD PRIMARY KEY (match_id);


-- ============================================================================
-- 4. VÝCHOZÍ SNAPSHOT
-- ============================================================================

CREATE TEMP TABLE mm_belgium_baseline
ON COMMIT PRESERVE ROWS
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
        FROM mm_belgium_110_candidates
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
        JOIN mm_belgium_110_candidates c
            ON c.match_id = mf.match_id
    )::bigint AS feature_rows,

    (
        SELECT COUNT(DISTINCT mf.match_id)
        FROM public.match_features mf
        JOIN mm_belgium_110_candidates c
            ON c.match_id = mf.match_id
    )::bigint AS feature_matches,

    (
        SELECT COUNT(*)
        FROM public.mm_match_ratings r
        JOIN mm_belgium_110_candidates c
            ON c.match_id = r.match_id
    )::bigint AS rating_rows,

    (
        SELECT COUNT(DISTINCT r.match_id)
        FROM public.mm_match_ratings r
        JOIN mm_belgium_110_candidates c
            ON c.match_id = r.match_id
    )::bigint AS rating_matches,

    (
        SELECT COUNT(*)
        FROM public.mm_match_ratings r
        JOIN mm_belgium_110_candidates c
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
        JOIN mm_belgium_110_candidates c
            ON c.match_id = p.match_id
        WHERE p.provider = 'football_data_uk'
          AND p.provider_match_id = c.ext_match_id
    )::bigint AS historical_identity_rows;


-- ============================================================================
-- 5. BEZPEČNOSTNÍ BRÁNA
-- ============================================================================

CREATE TEMP TABLE mm_belgium_guard
ON COMMIT PRESERVE ROWS
AS
SELECT
    (
        legacy_scope_matches = 231
        AND candidate_matches = 110
        AND target_league_rows = 1
        AND validated_team_pairs = 23
        AND feature_rows = 110
        AND feature_matches = 110
        AND rating_rows = 110
        AND rating_matches = 110
        AND rating_dimensions_before_ok = 110
        AND historical_identity_rows = 110
    ) AS can_run
FROM mm_belgium_baseline;

DO $$
BEGIN
    IF NOT COALESCE(
        (SELECT can_run FROM mm_belgium_guard),
        false
    ) THEN
        RAISE EXCEPTION
            'APPLY BLOKOVÁN: vstupní bezpečnostní podmínky nejsou splněny.';
    END IF;
END
$$;


-- ============================================================================
-- 6. SNAPSHOT NEDIMENZIONÁLNÍHO OBSAHU
-- ============================================================================

CREATE TEMP TABLE mm_belgium_match_payload_before
ON COMMIT PRESERVE ROWS
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
JOIN mm_belgium_110_candidates c
    ON c.match_id = m.id;


CREATE TEMP TABLE mm_belgium_rating_payload_before
ON COMMIT PRESERVE ROWS
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
JOIN mm_belgium_110_candidates c
    ON c.match_id = r.match_id;


-- ============================================================================
-- 7. APPLY – ZMĚNA KANONICKÝCH DIMENZÍ ZÁPASŮ
-- ============================================================================

CREATE TEMP TABLE mm_belgium_match_update_result
ON COMMIT PRESERVE ROWS
AS
WITH updated AS (
    UPDATE public.matches m
    SET
        league_id = 20853,
        home_team_id = c.target_home_team_id,
        away_team_id = c.target_away_team_id
    FROM mm_belgium_110_candidates c
    WHERE m.id = c.match_id
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
    RETURNING m.id
)
SELECT COUNT(*)::bigint AS updated_rows
FROM updated;


-- ============================================================================
-- 8. APPLY – SJEDNOCENÍ RATINGOVÝCH DIMENZÍ
-- ============================================================================

CREATE TEMP TABLE mm_belgium_rating_update_result
ON COMMIT PRESERVE ROWS
AS
WITH updated AS (
    UPDATE public.mm_match_ratings r
    SET
        league_id = 20853,
        home_team_id = c.target_home_team_id,
        away_team_id = c.target_away_team_id,
        kickoff = m.kickoff::timestamp AT TIME ZONE 'UTC'
    FROM mm_belgium_110_candidates c
    JOIN public.matches m
        ON m.id = c.match_id
    WHERE r.match_id = c.match_id
    RETURNING r.match_id
)
SELECT COUNT(*)::bigint AS updated_rows
FROM updated;


-- ============================================================================
-- 9. KLASIFIKACE 121 ZÁPASŮ, KTERÉ MUSÍ PO APPLY ZŮSTAT V LEGACY STAVU
-- ============================================================================

CREATE TEMP TABLE mm_belgium_remaining_classification
ON COMMIT PRESERVE ROWS
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
-- 10. PRE-COMMIT APPLY REPORT
-- ============================================================================

CREATE TEMP TABLE mm_belgium_apply_report (
    sort_order integer,
    sekce text,
    kontrola text,
    stav text,
    ocekavano bigint,
    skutecnost bigint,
    detail text
)
ON COMMIT PRESERVE ROWS;


INSERT INTO mm_belgium_apply_report
SELECT
    10,
    'PRECHECK',
    'SAFETY_GUARD',
    CASE WHEN can_run THEN 'OK' ELSE 'BLOCKED' END,
    1,
    CASE WHEN can_run THEN 1 ELSE 0 END,
    'APPLY byl povolen pouze při přesném splnění všech vstupních podmínek.'
FROM mm_belgium_guard;


INSERT INTO mm_belgium_apply_report
SELECT
    20,
    'APPLY',
    'MATCHES_UPDATED',
    CASE WHEN updated_rows = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    110,
    updated_rows,
    'Změněny pouze league_id, home_team_id a away_team_id.'
FROM mm_belgium_match_update_result;


INSERT INTO mm_belgium_apply_report
SELECT
    30,
    'APPLY',
    'RATINGS_UPDATED',
    CASE WHEN updated_rows = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    110,
    updated_rows,
    'Změněny pouze dimenze ratingu a kickoff UTC.'
FROM mm_belgium_rating_update_result;


INSERT INTO mm_belgium_apply_report
SELECT
    100,
    'POSTCHECK',
    'TARGET_MATCH_DIMENSIONS_OK',
    CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    110,
    COUNT(*)::bigint,
    NULL
FROM public.matches m
JOIN mm_belgium_110_candidates c
    ON c.match_id = m.id
WHERE m.league_id = 20853
  AND m.home_team_id = c.target_home_team_id
  AND m.away_team_id = c.target_away_team_id;


INSERT INTO mm_belgium_apply_report
SELECT
    110,
    'POSTCHECK',
    'CANDIDATES_REMAINING_IN_LEGACY',
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    0,
    COUNT(*)::bigint,
    NULL
FROM public.matches m
JOIN mm_belgium_110_candidates c
    ON c.match_id = m.id
WHERE m.league_id = 4;


INSERT INTO mm_belgium_apply_report
SELECT
    120,
    'POSTCHECK',
    'LEGACY_MATCHES_REMAINING',
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    121,
    COUNT(*)::bigint,
    'Pouze zápasy obsahující jeden nebo dva otevřené historické týmy.'
FROM public.matches
WHERE sport_id = 1
  AND league_id = 4
  AND ext_source = 'football_data_uk';


INSERT INTO mm_belgium_apply_report
SELECT
    130,
    'POSTCHECK',
    'REMAINING_PARTIALLY_MAPPABLE',
    CASE
        WHEN COALESCE(MAX(match_count), 0) = 119 THEN 'OK'
        ELSE 'REVIEW_REQUIRED'
    END,
    119,
    COALESCE(MAX(match_count), 0),
    NULL
FROM mm_belgium_remaining_classification
WHERE mapping_class = 'PARTIALLY_MAPPABLE';


INSERT INTO mm_belgium_apply_report
SELECT
    140,
    'POSTCHECK',
    'REMAINING_UNMAPPED_TEAM_REQUIRED',
    CASE
        WHEN COALESCE(MAX(match_count), 0) = 2 THEN 'OK'
        ELSE 'REVIEW_REQUIRED'
    END,
    2,
    COALESCE(MAX(match_count), 0),
    NULL
FROM mm_belgium_remaining_classification
WHERE mapping_class = 'UNMAPPED_TEAM_REQUIRED';


INSERT INTO mm_belgium_apply_report
SELECT
    150,
    'POSTCHECK',
    'REMAINING_FULLY_MAPPABLE',
    CASE
        WHEN COALESCE(MAX(match_count), 0) = 0 THEN 'OK'
        ELSE 'REVIEW_REQUIRED'
    END,
    0,
    COALESCE(MAX(match_count), 0),
    NULL
FROM mm_belgium_remaining_classification
WHERE mapping_class = 'FULLY_MAPPABLE';


INSERT INTO mm_belgium_apply_report
SELECT
    200,
    'DOWNSTREAM',
    'MATCH_FEATURE_ROWS_PRESERVED',
    CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    110,
    COUNT(*)::bigint,
    'match_id se nezměnil.'
FROM public.match_features mf
JOIN mm_belgium_110_candidates c
    ON c.match_id = mf.match_id;


INSERT INTO mm_belgium_apply_report
SELECT
    210,
    'DOWNSTREAM',
    'RATING_DIMENSIONS_ALIGNED',
    CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    110,
    COUNT(*)::bigint,
    NULL
FROM public.mm_match_ratings r
JOIN mm_belgium_110_candidates c
    ON c.match_id = r.match_id
JOIN public.matches m
    ON m.id = c.match_id
WHERE r.league_id = 20853
  AND r.home_team_id = c.target_home_team_id
  AND r.away_team_id = c.target_away_team_id
  AND r.kickoff IS NOT DISTINCT FROM
      (m.kickoff::timestamp AT TIME ZONE 'UTC');


INSERT INTO mm_belgium_apply_report
SELECT
    220,
    'DOWNSTREAM',
    'RATING_PAYLOAD_UNCHANGED',
    CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    110,
    COUNT(*)::bigint,
    'Všechny nedimenzionální ratingové hodnoty zůstaly beze změny.'
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


INSERT INTO mm_belgium_apply_report
SELECT
    230,
    'IDENTITY',
    'MATCH_PAYLOAD_UNCHANGED',
    CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    110,
    COUNT(*)::bigint,
    'Mimo schválené kanonické dimenze se obsah zápasu nezměnil.'
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


INSERT INTO mm_belgium_apply_report
SELECT
    240,
    'IDENTITY',
    'HISTORICAL_EXT_IDENTITY_UNCHANGED',
    CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    110,
    COUNT(*)::bigint,
    'ext_source a ext_match_id zůstávají historické.'
FROM mm_belgium_match_payload_before b
JOIN public.matches m
    ON m.id = b.match_id
WHERE m.ext_source IS NOT DISTINCT FROM b.ext_source
  AND m.ext_match_id IS NOT DISTINCT FROM b.ext_match_id;


INSERT INTO mm_belgium_apply_report
SELECT
    250,
    'IDENTITY',
    'PROVIDER_IDENTITIES_PRESERVED',
    CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    110,
    COUNT(*)::bigint,
    NULL
FROM public.match_provider_map p
JOIN mm_belgium_110_candidates c
    ON c.match_id = p.match_id
WHERE p.provider = 'football_data_uk'
  AND p.provider_match_id = c.ext_match_id;


INSERT INTO mm_belgium_apply_report
SELECT
    300,
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


INSERT INTO mm_belgium_apply_report
SELECT
    310,
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


INSERT INTO mm_belgium_apply_report
SELECT
    320,
    'GLOBAL',
    'GLOBAL_RATING_ORPHANS_UNCHANGED',
    CASE
        WHEN COUNT(*) = b.global_rating_orphans THEN 'OK'
        ELSE 'REVIEW_REQUIRED'
    END,
    b.global_rating_orphans,
    COUNT(*)::bigint,
    'Globální orphan sada nebyla součástí migrace.'
FROM public.mm_match_ratings r
LEFT JOIN public.matches m
    ON m.id = r.match_id
CROSS JOIN mm_belgium_baseline b
WHERE m.id IS NULL
GROUP BY b.global_rating_orphans;


-- ============================================================================
-- 11. TVRDÁ PRE-COMMIT KONTROLA
-- ============================================================================

DO $$
DECLARE
    failures text;
BEGIN
    SELECT string_agg(
        format(
            '%s / %s: stav=%s, očekáváno=%s, skutečnost=%s',
            sekce,
            kontrola,
            stav,
            ocekavano,
            skutecnost
        ),
        E'\n'
        ORDER BY sort_order
    )
    INTO failures
    FROM mm_belgium_apply_report
    WHERE stav <> 'OK';

    IF failures IS NOT NULL THEN
        RAISE EXCEPTION
            'APPLY BLOKOVÁN – kontrola před COMMIT selhala:%',
            E'\n' || failures;
    END IF;
END
$$;


INSERT INTO mm_belgium_apply_report
VALUES (
    999,
    'ZAVER',
    'APPLY_PRECOMMIT_STATUS',
    'APPLY_PRECOMMIT_OK',
    110,
    110,
    'Všechny kontroly prošly; následuje COMMIT.'
);


SELECT
    sekce,
    kontrola,
    stav,
    ocekavano,
    skutecnost,
    detail
FROM mm_belgium_apply_report
ORDER BY sort_order;


COMMIT;


-- ============================================================================
-- B. POST-COMMIT READ ONLY AUDIT
-- ============================================================================

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;

SET LOCAL TIME ZONE 'UTC';


WITH
remaining_classification AS (
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
    GROUP BY 1
),
base_rows AS (
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
        'Post-commit audit probíhá pouze pro čtení.'::text AS detail

    UNION ALL

    SELECT
        100,
        'POST_COMMIT',
        'TARGET_MATCH_DIMENSIONS_OK',
        CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        110,
        COUNT(*)::bigint,
        NULL::text
    FROM public.matches m
    JOIN mm_belgium_110_candidates c
        ON c.match_id = m.id
    WHERE m.league_id = 20853
      AND m.home_team_id = c.target_home_team_id
      AND m.away_team_id = c.target_away_team_id

    UNION ALL

    SELECT
        110,
        'POST_COMMIT',
        'CANDIDATES_REMAINING_IN_LEGACY',
        CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        0,
        COUNT(*)::bigint,
        NULL::text
    FROM public.matches m
    JOIN mm_belgium_110_candidates c
        ON c.match_id = m.id
    WHERE m.league_id = 4

    UNION ALL

    SELECT
        120,
        'POST_COMMIT',
        'LEGACY_MATCHES_REMAINING',
        CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        121,
        COUNT(*)::bigint,
        NULL::text
    FROM public.matches
    WHERE sport_id = 1
      AND league_id = 4
      AND ext_source = 'football_data_uk'

    UNION ALL

    SELECT
        130,
        'POST_COMMIT',
        'REMAINING_PARTIALLY_MAPPABLE',
        CASE
            WHEN COALESCE(MAX(match_count), 0) = 119 THEN 'OK'
            ELSE 'REVIEW_REQUIRED'
        END,
        119,
        COALESCE(MAX(match_count), 0),
        NULL::text
    FROM remaining_classification
    WHERE mapping_class = 'PARTIALLY_MAPPABLE'

    UNION ALL

    SELECT
        140,
        'POST_COMMIT',
        'REMAINING_UNMAPPED_TEAM_REQUIRED',
        CASE
            WHEN COALESCE(MAX(match_count), 0) = 2 THEN 'OK'
            ELSE 'REVIEW_REQUIRED'
        END,
        2,
        COALESCE(MAX(match_count), 0),
        NULL::text
    FROM remaining_classification
    WHERE mapping_class = 'UNMAPPED_TEAM_REQUIRED'

    UNION ALL

    SELECT
        150,
        'POST_COMMIT',
        'REMAINING_FULLY_MAPPABLE',
        CASE
            WHEN COALESCE(MAX(match_count), 0) = 0 THEN 'OK'
            ELSE 'REVIEW_REQUIRED'
        END,
        0,
        COALESCE(MAX(match_count), 0),
        NULL::text
    FROM remaining_classification
    WHERE mapping_class = 'FULLY_MAPPABLE'

    UNION ALL

    SELECT
        200,
        'DOWNSTREAM',
        'MATCH_FEATURE_ROWS_PRESERVED',
        CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        110,
        COUNT(*)::bigint,
        NULL::text
    FROM public.match_features mf
    JOIN mm_belgium_110_candidates c
        ON c.match_id = mf.match_id

    UNION ALL

    SELECT
        210,
        'DOWNSTREAM',
        'RATING_DIMENSIONS_ALIGNED',
        CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        110,
        COUNT(*)::bigint,
        NULL::text
    FROM public.mm_match_ratings r
    JOIN mm_belgium_110_candidates c
        ON c.match_id = r.match_id
    JOIN public.matches m
        ON m.id = c.match_id
    WHERE r.league_id = 20853
      AND r.home_team_id = c.target_home_team_id
      AND r.away_team_id = c.target_away_team_id
      AND r.kickoff IS NOT DISTINCT FROM
          (m.kickoff::timestamp AT TIME ZONE 'UTC')

    UNION ALL

    SELECT
        220,
        'DOWNSTREAM',
        'RATING_PAYLOAD_UNCHANGED',
        CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        110,
        COUNT(*)::bigint,
        NULL::text
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
    )

    UNION ALL

    SELECT
        230,
        'IDENTITY',
        'MATCH_PAYLOAD_UNCHANGED',
        CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        110,
        COUNT(*)::bigint,
        NULL::text
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
    )

    UNION ALL

    SELECT
        240,
        'IDENTITY',
        'HISTORICAL_EXT_IDENTITY_UNCHANGED',
        CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        110,
        COUNT(*)::bigint,
        NULL::text
    FROM mm_belgium_match_payload_before b
    JOIN public.matches m
        ON m.id = b.match_id
    WHERE m.ext_source IS NOT DISTINCT FROM b.ext_source
      AND m.ext_match_id IS NOT DISTINCT FROM b.ext_match_id

    UNION ALL

    SELECT
        250,
        'IDENTITY',
        'PROVIDER_IDENTITIES_PRESERVED',
        CASE WHEN COUNT(*) = 110 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
        110,
        COUNT(*)::bigint,
        NULL::text
    FROM public.match_provider_map p
    JOIN mm_belgium_110_candidates c
        ON c.match_id = p.match_id
    WHERE p.provider = 'football_data_uk'
      AND p.provider_match_id = c.ext_match_id

    UNION ALL

    SELECT
        300,
        'GLOBAL',
        'MATCH_COUNT_UNCHANGED',
        CASE
            WHEN COUNT(*) = b.matches_total THEN 'OK'
            ELSE 'REVIEW_REQUIRED'
        END,
        b.matches_total,
        COUNT(*)::bigint,
        NULL::text
    FROM public.matches
    CROSS JOIN mm_belgium_baseline b
    GROUP BY b.matches_total

    UNION ALL

    SELECT
        310,
        'GLOBAL',
        'PROVIDER_MAP_COUNT_UNCHANGED',
        CASE
            WHEN COUNT(*) = b.provider_map_total THEN 'OK'
            ELSE 'REVIEW_REQUIRED'
        END,
        b.provider_map_total,
        COUNT(*)::bigint,
        NULL::text
    FROM public.match_provider_map
    CROSS JOIN mm_belgium_baseline b
    GROUP BY b.provider_map_total

    UNION ALL

    SELECT
        320,
        'GLOBAL',
        'GLOBAL_RATING_ORPHANS_UNCHANGED',
        CASE
            WHEN COUNT(*) = b.global_rating_orphans THEN 'OK'
            ELSE 'REVIEW_REQUIRED'
        END,
        b.global_rating_orphans,
        COUNT(*)::bigint,
        NULL::text
    FROM public.mm_match_ratings r
    LEFT JOIN public.matches m
        ON m.id = r.match_id
    CROSS JOIN mm_belgium_baseline b
    WHERE m.id IS NULL
    GROUP BY b.global_rating_orphans
),
report_rows AS (
    SELECT *
    FROM base_rows

    UNION ALL

    SELECT
        999,
        'ZAVER',
        'POST_COMMIT_AUDIT_STATUS',
        CASE
            WHEN NOT EXISTS (
                SELECT 1
                FROM base_rows
                WHERE stav <> 'OK'
            )
            THEN 'POST_COMMIT_AUDIT_OK'
            ELSE 'POST_COMMIT_AUDIT_REVIEW_REQUIRED'
        END,
        110::bigint,
        (
            SELECT COUNT(*)::bigint
            FROM public.matches m
            JOIN mm_belgium_110_candidates c
                ON c.match_id = m.id
            WHERE m.league_id = 20853
              AND m.home_team_id = c.target_home_team_id
              AND m.away_team_id = c.target_away_team_id
        ),
        'Trvalá migrace a všechny následné kontroly byly dokončeny.'
)
SELECT
    sekce,
    kontrola,
    stav,
    ocekavano,
    skutecnost,
    detail
FROM report_rows
ORDER BY sort_order;


ROLLBACK;