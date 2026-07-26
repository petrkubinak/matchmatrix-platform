/*
===============================================================================
MATCHMATRIX – BELGIUM JUPILER PRO LEAGUE
VALIDATE ONLY – MATCH PROVIDER IDENTITY TRANSFER V1
===============================================================================

CO:
- Vytvoří dočasný migrační plán pro Jupiler Pro League.
- Ověří 21 potvrzených týmových dvojic.
- Klasifikuje 2 214 historických zápasů football_data_uk.
- Zkušebně přesune providerové identity bezpečných překryvů na
  kanonické API-Football zápasy.

OČEKÁVANÁ KLASIFIKACE:
- UNIQUE_HISTORY          : 1 284
- OVERLAP_SAME_SCORE      :   927
- REVIEW_INCOMPLETE_SCORE :     1
- REVIEW_SCORE_CONFLICT   :     2
- AMBIGUOUS_API_MATCH     :     0

BEZPEČNOST:
- public.matches se nemění.
- Downstream tabulky se nemění.
- Žádný zápas se nemaže.
- Všechny změny match_provider_map jsou pouze zkušební.
- Posledním transakčním příkazem je ROLLBACK.
===============================================================================
*/

BEGIN ISOLATION LEVEL REPEATABLE READ;

SET LOCAL lock_timeout = '10s';
SET LOCAL statement_timeout = '300s';
SET LOCAL client_min_messages = 'notice';
SET LOCAL TIME ZONE 'UTC';

-------------------------------------------------------------------------------
-- 1. PROSTŘEDÍ
-------------------------------------------------------------------------------

SELECT
    current_database() AS database_name,
    current_user AS database_user,
    current_setting('transaction_isolation') AS transaction_isolation,
    current_setting('transaction_read_only') AS transaction_read_only,
    current_setting('TimeZone') AS session_timezone,
    clock_timestamp() AS validation_started_at;

-------------------------------------------------------------------------------
-- 2. POVINNÉ OBJEKTY
-------------------------------------------------------------------------------

DO $objects$
BEGIN
    IF to_regclass('public.matches') IS NULL THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: public.matches neexistuje.';
    END IF;

    IF to_regclass('public.teams') IS NULL THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: public.teams neexistuje.';
    END IF;

    IF to_regclass('public.leagues') IS NULL THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: public.leagues neexistuje.';
    END IF;

    IF to_regclass('public.match_provider_map') IS NULL THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: public.match_provider_map neexistuje.';
    END IF;

    RAISE NOTICE
        'OK OBJECTS: Povinné tabulky existují.';
END
$objects$;

-------------------------------------------------------------------------------
-- 3. POTVRZENÉ MAPOVÁNÍ 21 BELGICKÝCH TÝMŮ
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_team_map
(
    historical_team_id integer PRIMARY KEY,
    api_team_id integer NOT NULL UNIQUE,
    club_name text NOT NULL
)
ON COMMIT DROP;

INSERT INTO mm_be_team_map
(
    historical_team_id,
    api_team_id,
    club_name
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
    (971, 13537, 'Standard Liège'),
    (965, 13160, 'Union St. Gilloise'),
    (978, 12277, 'St. Truiden'),
    (968, 12993, 'Zulte Waregem'),
    (973, 13279, 'Westerlo');

-------------------------------------------------------------------------------
-- 4. ZJIŠTĚNÍ SKUTEČNÝCH NÁZVŮ DATOVÝCH A SKÓROVÝCH SLOUPCŮ
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_detected_columns
(
    logical_name text PRIMARY KEY,
    physical_name text NOT NULL
)
ON COMMIT DROP;

DO $detect_columns$
DECLARE
    v_date_column text;
    v_home_score_column text;
    v_away_score_column text;
BEGIN
    SELECT candidate.column_name
    INTO v_date_column
    FROM unnest(
        ARRAY[
            'match_date',
            'kickoff_at',
            'start_time',
            'utc_date',
            'kickoff',
            'date'
        ]
    ) WITH ORDINALITY AS candidate(column_name, priority)
    JOIN information_schema.columns c
      ON c.table_schema = 'public'
     AND c.table_name = 'matches'
     AND c.column_name = candidate.column_name
    ORDER BY candidate.priority
    LIMIT 1;

    SELECT candidate.column_name
    INTO v_home_score_column
    FROM unnest(
        ARRAY[
            'home_score',
            'home_goals',
            'score_home',
            'home_team_score'
        ]
    ) WITH ORDINALITY AS candidate(column_name, priority)
    JOIN information_schema.columns c
      ON c.table_schema = 'public'
     AND c.table_name = 'matches'
     AND c.column_name = candidate.column_name
    ORDER BY candidate.priority
    LIMIT 1;

    SELECT candidate.column_name
    INTO v_away_score_column
    FROM unnest(
        ARRAY[
            'away_score',
            'away_goals',
            'score_away',
            'away_team_score'
        ]
    ) WITH ORDINALITY AS candidate(column_name, priority)
    JOIN information_schema.columns c
      ON c.table_schema = 'public'
     AND c.table_name = 'matches'
     AND c.column_name = candidate.column_name
    ORDER BY candidate.priority
    LIMIT 1;

    IF v_date_column IS NULL THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Nebyl nalezen datový sloupec zápasu.';
    END IF;

    IF v_home_score_column IS NULL
       OR v_away_score_column IS NULL THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Nebyly nalezeny oba skórové sloupce.';
    END IF;

    INSERT INTO mm_be_detected_columns
    VALUES
        ('MATCH_DATE', v_date_column),
        ('HOME_SCORE', v_home_score_column),
        ('AWAY_SCORE', v_away_score_column);

    RAISE NOTICE
        'OK COLUMNS: datum %, domácí skóre %, hostující skóre %.',
        v_date_column,
        v_home_score_column,
        v_away_score_column;
END
$detect_columns$;

SELECT *
FROM mm_be_detected_columns
ORDER BY logical_name;

-------------------------------------------------------------------------------
-- 5. NORMALIZOVANÝ BELGICKÝ VÝŘEZ Z public.matches
-------------------------------------------------------------------------------

DO $build_base$
DECLARE
    v_date_column text;
    v_home_score_column text;
    v_away_score_column text;
BEGIN
    SELECT physical_name
    INTO v_date_column
    FROM mm_be_detected_columns
    WHERE logical_name = 'MATCH_DATE';

    SELECT physical_name
    INTO v_home_score_column
    FROM mm_be_detected_columns
    WHERE logical_name = 'HOME_SCORE';

    SELECT physical_name
    INTO v_away_score_column
    FROM mm_be_detected_columns
    WHERE logical_name = 'AWAY_SCORE';

    EXECUTE format(
        $sql$
        CREATE TEMP TABLE mm_be_matches_base
        ON COMMIT DROP
        AS
        SELECT
            id AS match_id,
            league_id,
            home_team_id,
            away_team_id,
            (%I)::date AS match_day,
            (%I)::integer AS home_score,
            (%I)::integer AS away_score,
            btrim(ext_source::text) AS provider,
            btrim(ext_match_id::text) AS provider_match_id
        FROM public.matches
        WHERE
            (
                league_id = 4
                AND btrim(ext_source::text) = 'football_data_uk'
            )
            OR
            (
                league_id = 20853
                AND btrim(ext_source::text) = 'api_football'
            )
        $sql$,
        v_date_column,
        v_home_score_column,
        v_away_score_column
    );
END
$build_base$;

-------------------------------------------------------------------------------
-- 6. KONTROLA VSTUPNÍHO ROZSAHU
-------------------------------------------------------------------------------

DO $input_check$
DECLARE
    v_team_pairs bigint;
    v_history_rows bigint;
    v_api_rows bigint;
    v_provider_map_rows bigint;
BEGIN
    SELECT COUNT(*)
    INTO v_team_pairs
    FROM mm_be_team_map;

    SELECT COUNT(*)
    INTO v_history_rows
    FROM mm_be_matches_base
    WHERE provider = 'football_data_uk'
      AND league_id = 4;

    SELECT COUNT(*)
    INTO v_api_rows
    FROM mm_be_matches_base
    WHERE provider = 'api_football'
      AND league_id = 20853;

    SELECT COUNT(*)
    INTO v_provider_map_rows
    FROM public.match_provider_map;

    IF v_team_pairs <> 21 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Týmových dvojic je % místo 21.',
            v_team_pairs;
    END IF;

    IF v_history_rows <> 2214 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Historických zápasů je % místo 2214.',
            v_history_rows;
    END IF;

    IF v_api_rows <> 960 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: API-Football zápasů je % místo 960.',
            v_api_rows;
    END IF;

    IF v_provider_map_rows <> 121908 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: match_provider_map obsahuje % řádků místo 121908.',
            v_provider_map_rows;
    END IF;

    RAISE NOTICE
        'OK INPUT: týmové dvojice %, historie %, API zápasy %, provider map %.',
        v_team_pairs,
        v_history_rows,
        v_api_rows,
        v_provider_map_rows;
END
$input_check$;

-------------------------------------------------------------------------------
-- 7. PŘEVOD HISTORICKÝCH TÝMOVÝCH ID NA CÍLOVÉ KANDIDÁTY
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_history_transformed
ON COMMIT DROP
AS
SELECT
    h.match_id AS historical_match_id,
    h.match_day,

    h.home_team_id AS historical_home_team_id,
    h.away_team_id AS historical_away_team_id,

    COALESCE(home_map.api_team_id, h.home_team_id)
        AS target_home_team_id,

    COALESCE(away_map.api_team_id, h.away_team_id)
        AS target_away_team_id,

    h.home_score AS historical_home_score,
    h.away_score AS historical_away_score,

    h.provider_match_id AS historical_provider_match_id,

    (home_map.api_team_id IS NOT NULL) AS home_team_mapped,
    (away_map.api_team_id IS NOT NULL) AS away_team_mapped

FROM mm_be_matches_base h

LEFT JOIN mm_be_team_map home_map
  ON home_map.historical_team_id = h.home_team_id

LEFT JOIN mm_be_team_map away_map
  ON away_map.historical_team_id = h.away_team_id

WHERE h.provider = 'football_data_uk'
  AND h.league_id = 4;

-------------------------------------------------------------------------------
-- 8. POKRYTÍ TÝMOVÉHO MAPOVÁNÍ
-------------------------------------------------------------------------------

SELECT
    CASE
        WHEN home_team_mapped AND away_team_mapped
            THEN 'BOTH_TEAMS_MAPPED'
        WHEN home_team_mapped OR away_team_mapped
            THEN 'ONE_TEAM_MAPPED'
        ELSE 'NO_TEAM_MAPPED'
    END AS team_mapping_state,
    COUNT(*) AS match_count
FROM mm_be_history_transformed
GROUP BY 1
ORDER BY match_count DESC;

-------------------------------------------------------------------------------
-- 9. VYTVOŘENÍ MIGRAČNÍHO PLÁNU
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_migration_plan
ON COMMIT DROP
AS
SELECT
    h.*,

    api.api_candidate_count,
    api.api_match_id,
    api.api_home_score,
    api.api_away_score,
    api.api_match_ids,

    CASE
        WHEN api.api_candidate_count = 0
            THEN 'UNIQUE_HISTORY'

        WHEN api.api_candidate_count > 1
            THEN 'AMBIGUOUS_API_MATCH'

        WHEN h.historical_home_score IS NULL
          OR h.historical_away_score IS NULL
          OR api.api_home_score IS NULL
          OR api.api_away_score IS NULL
            THEN 'REVIEW_INCOMPLETE_SCORE'

        WHEN h.historical_home_score = api.api_home_score
         AND h.historical_away_score = api.api_away_score
            THEN 'OVERLAP_SAME_SCORE'

        ELSE 'REVIEW_SCORE_CONFLICT'
    END AS migration_class

FROM mm_be_history_transformed h

LEFT JOIN LATERAL
(
    SELECT
        COUNT(*)::integer AS api_candidate_count,
        MIN(a.match_id) AS api_match_id,
        MIN(a.home_score) AS api_home_score,
        MIN(a.away_score) AS api_away_score,
        array_agg(a.match_id ORDER BY a.match_id) AS api_match_ids

    FROM mm_be_matches_base a

    WHERE a.provider = 'api_football'
      AND a.league_id = 20853
      AND a.match_day = h.match_day
      AND a.home_team_id = h.target_home_team_id
      AND a.away_team_id = h.target_away_team_id
) api
ON true;

-------------------------------------------------------------------------------
-- 10. KLASIFIKACE PLÁNU
-------------------------------------------------------------------------------

SELECT
    migration_class,
    COUNT(*) AS match_count
FROM mm_be_migration_plan
GROUP BY migration_class
ORDER BY
    CASE migration_class
        WHEN 'UNIQUE_HISTORY' THEN 1
        WHEN 'OVERLAP_SAME_SCORE' THEN 2
        WHEN 'REVIEW_INCOMPLETE_SCORE' THEN 3
        WHEN 'REVIEW_SCORE_CONFLICT' THEN 4
        WHEN 'AMBIGUOUS_API_MATCH' THEN 5
        ELSE 6
    END;

-------------------------------------------------------------------------------
-- 11. POVINNÁ KONTROLA OČEKÁVANÝCH POČTŮ
-------------------------------------------------------------------------------

DO $classification_check$
DECLARE
    v_total bigint;
    v_unique bigint;
    v_same bigint;
    v_incomplete bigint;
    v_conflict bigint;
    v_ambiguous bigint;
BEGIN
    SELECT COUNT(*)
    INTO v_total
    FROM mm_be_migration_plan;

    SELECT COUNT(*)
    INTO v_unique
    FROM mm_be_migration_plan
    WHERE migration_class = 'UNIQUE_HISTORY';

    SELECT COUNT(*)
    INTO v_same
    FROM mm_be_migration_plan
    WHERE migration_class = 'OVERLAP_SAME_SCORE';

    SELECT COUNT(*)
    INTO v_incomplete
    FROM mm_be_migration_plan
    WHERE migration_class = 'REVIEW_INCOMPLETE_SCORE';

    SELECT COUNT(*)
    INTO v_conflict
    FROM mm_be_migration_plan
    WHERE migration_class = 'REVIEW_SCORE_CONFLICT';

    SELECT COUNT(*)
    INTO v_ambiguous
    FROM mm_be_migration_plan
    WHERE migration_class = 'AMBIGUOUS_API_MATCH';

    IF v_total <> 2214
       OR v_unique <> 1284
       OR v_same <> 927
       OR v_incomplete <> 1
       OR v_conflict <> 2
       OR v_ambiguous <> 0 THEN

        RAISE EXCEPTION
            'VALIDATION_FAILED: total %, unique %, same %, incomplete %, conflict %, ambiguous %.',
            v_total,
            v_unique,
            v_same,
            v_incomplete,
            v_conflict,
            v_ambiguous;
    END IF;

    RAISE NOTICE
        'OK CLASSIFICATION: total %, unique %, same %, incomplete %, conflict %, ambiguous %.',
        v_total,
        v_unique,
        v_same,
        v_incomplete,
        v_conflict,
        v_ambiguous;
END
$classification_check$;

-------------------------------------------------------------------------------
-- 12. TŘI PŘÍPADY K RUČNÍMU POSOUZENÍ
-------------------------------------------------------------------------------

SELECT
    migration_class,
    match_day,

    historical_match_id,
    api_match_id,

    historical_home_team_id,
    historical_away_team_id,

    target_home_team_id,
    target_away_team_id,

    historical_home_score,
    historical_away_score,

    api_home_score,
    api_away_score

FROM mm_be_migration_plan

WHERE migration_class IN
(
    'REVIEW_INCOMPLETE_SCORE',
    'REVIEW_SCORE_CONFLICT',
    'AMBIGUOUS_API_MATCH'
)

ORDER BY
    match_day,
    historical_match_id;

-------------------------------------------------------------------------------
-- 13. PROVIDEROVÉ IDENTITY PŘED ZKUŠEBNÍM PŘEVODEM
-------------------------------------------------------------------------------

DO $identity_precheck$
DECLARE
    v_history_identity_rows bigint;
    v_api_identity_rows bigint;
    v_safe_overlap_rows bigint;
BEGIN
    SELECT COUNT(*)
    INTO v_history_identity_rows
    FROM mm_be_migration_plan plan
    JOIN public.match_provider_map identity
      ON identity.match_id = plan.historical_match_id
     AND identity.provider = 'football_data_uk'
     AND identity.provider_match_id =
         plan.historical_provider_match_id;

    SELECT COUNT(*)
    INTO v_api_identity_rows
    FROM mm_be_migration_plan plan
    JOIN public.match_provider_map identity
      ON identity.match_id = plan.api_match_id
     AND identity.provider = 'api_football'
    WHERE plan.api_match_id IS NOT NULL;

    SELECT COUNT(*)
    INTO v_safe_overlap_rows
    FROM mm_be_migration_plan
    WHERE migration_class = 'OVERLAP_SAME_SCORE';

    IF v_history_identity_rows <> 2214 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Historických identit nalezeno % místo 2214.',
            v_history_identity_rows;
    END IF;

    IF v_api_identity_rows <> 930 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: API identit překryvů nalezeno % místo 930.',
            v_api_identity_rows;
    END IF;

    IF v_safe_overlap_rows <> 927 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Bezpečných překryvů je % místo 927.',
            v_safe_overlap_rows;
    END IF;

    RAISE NOTICE
        'OK IDENTITIES BEFORE: historie %, API překryvy %, bezpečné překryvy %.',
        v_history_identity_rows,
        v_api_identity_rows,
        v_safe_overlap_rows;
END
$identity_precheck$;

-------------------------------------------------------------------------------
-- 14. ZKUŠEBNÍ PŘEVOD 927 HISTORICKÝCH IDENTIT
--
-- Historická identita:
-- - přejde z duplicitního historical_match_id na API canonical match_id,
-- - přestane být primární,
-- - API-Football identita zůstane jedinou primární identitou.
-------------------------------------------------------------------------------

DO $simulate_transfer$
DECLARE
    v_updated_rows bigint;
BEGIN
    UPDATE public.match_provider_map identity
    SET
        match_id = plan.api_match_id,
        is_primary = false,
        metadata =
            identity.metadata ||
            jsonb_build_object(
                'belgium_migration_validation',
                true,
                'previous_match_id',
                plan.historical_match_id,
                'target_match_id',
                plan.api_match_id,
                'validation_class',
                plan.migration_class
            )

    FROM mm_be_migration_plan plan

    WHERE plan.migration_class = 'OVERLAP_SAME_SCORE'
      AND identity.match_id = plan.historical_match_id
      AND identity.provider = 'football_data_uk'
      AND identity.provider_match_id =
          plan.historical_provider_match_id;

    GET DIAGNOSTICS v_updated_rows = ROW_COUNT;

    IF v_updated_rows <> 927 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Přesunuto % identit místo 927.',
            v_updated_rows;
    END IF;

    RAISE NOTICE
        'OK TRANSFER: Zkušebně přesunuto 927 historických identit.';
END
$simulate_transfer$;

-------------------------------------------------------------------------------
-- 15. KONTROLA MULTI-PROVIDER KANONICKÝCH ZÁPASŮ
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_overlap_identity_check
ON COMMIT DROP
AS
SELECT
    plan.api_match_id AS canonical_match_id,

    COUNT(identity.id) AS identity_count,

    COUNT(*) FILTER (
        WHERE identity.is_primary = true
          AND identity.mapping_status = 'ACTIVE'
    ) AS active_primary_count,

    COUNT(*) FILTER (
        WHERE identity.provider = 'api_football'
    ) AS api_football_identity_count,

    COUNT(*) FILTER (
        WHERE identity.provider = 'football_data_uk'
    ) AS football_data_uk_identity_count

FROM mm_be_migration_plan plan

JOIN public.match_provider_map identity
  ON identity.match_id = plan.api_match_id

WHERE plan.migration_class = 'OVERLAP_SAME_SCORE'

GROUP BY plan.api_match_id;

SELECT
    COUNT(*) AS canonical_matches_checked,

    COUNT(*) FILTER (
        WHERE identity_count = 2
    ) AS matches_with_two_identities,

    COUNT(*) FILTER (
        WHERE active_primary_count = 1
    ) AS matches_with_one_primary,

    COUNT(*) FILTER (
        WHERE api_football_identity_count = 1
          AND football_data_uk_identity_count = 1
    ) AS matches_with_both_providers

FROM mm_be_overlap_identity_check;

-------------------------------------------------------------------------------
-- 16. POVINNÁ KONTROLA PO ZKUŠEBNÍM PŘEVODU
-------------------------------------------------------------------------------

DO $post_transfer_check$
DECLARE
    v_checked bigint;
    v_two_identities bigint;
    v_one_primary bigint;
    v_both_providers bigint;
    v_total_map_rows bigint;
BEGIN
    SELECT
        COUNT(*),
        COUNT(*) FILTER (
            WHERE identity_count = 2
        ),
        COUNT(*) FILTER (
            WHERE active_primary_count = 1
        ),
        COUNT(*) FILTER (
            WHERE api_football_identity_count = 1
              AND football_data_uk_identity_count = 1
        )
    INTO
        v_checked,
        v_two_identities,
        v_one_primary,
        v_both_providers
    FROM mm_be_overlap_identity_check;

    SELECT COUNT(*)
    INTO v_total_map_rows
    FROM public.match_provider_map;

    IF v_checked <> 927
       OR v_two_identities <> 927
       OR v_one_primary <> 927
       OR v_both_providers <> 927
       OR v_total_map_rows <> 121908 THEN

        RAISE EXCEPTION
            'VALIDATION_FAILED: checked %, two %, primary %, providers %, total map %.',
            v_checked,
            v_two_identities,
            v_one_primary,
            v_both_providers,
            v_total_map_rows;
    END IF;

    RAISE NOTICE
        'OK POST TRANSFER: 927 zápasů má dvě identity, jednu primární a oba providery.';
END
$post_transfer_check$;

-------------------------------------------------------------------------------
-- 17. SOUHRNNÝ STAV PŘED ROLLBACKEM
-------------------------------------------------------------------------------

SELECT
    'BELGIUM_HISTORY_TOTAL' AS check_name,
    COUNT(*)::text AS result
FROM mm_be_migration_plan

UNION ALL

SELECT
    'UNIQUE_HISTORY',
    COUNT(*)::text
FROM mm_be_migration_plan
WHERE migration_class = 'UNIQUE_HISTORY'

UNION ALL

SELECT
    'SAFE_OVERLAPS',
    COUNT(*)::text
FROM mm_be_migration_plan
WHERE migration_class = 'OVERLAP_SAME_SCORE'

UNION ALL

SELECT
    'REVIEW_INCOMPLETE_SCORE',
    COUNT(*)::text
FROM mm_be_migration_plan
WHERE migration_class = 'REVIEW_INCOMPLETE_SCORE'

UNION ALL

SELECT
    'REVIEW_SCORE_CONFLICT',
    COUNT(*)::text
FROM mm_be_migration_plan
WHERE migration_class = 'REVIEW_SCORE_CONFLICT'

UNION ALL

SELECT
    'MULTI_PROVIDER_MATCHES_VALIDATED',
    COUNT(*)::text
FROM mm_be_overlap_identity_check

UNION ALL

SELECT
    'MATCH_PROVIDER_MAP_ROWS',
    COUNT(*)::text
FROM public.match_provider_map;

SELECT
    'VALIDATE_ONLY_BELGIUM_PROVIDER_TRANSFER_OK – PŘIPRAVENO PRO DALŠÍ MIGRAČNÍ VRSTVU'
        AS validation_status;

-------------------------------------------------------------------------------
-- 18. POVINNÝ ROLLBACK
-------------------------------------------------------------------------------

ROLLBACK;

-------------------------------------------------------------------------------
-- 19. KONEČNÁ KONTROLA PO ROLLBACKU
-------------------------------------------------------------------------------

SELECT
    CASE
        WHEN COUNT(*) = 121908
         AND COUNT(*) FILTER (
                WHERE is_primary = true
                  AND mapping_status = 'ACTIVE'
             ) = 121908
        THEN
            'ROLLBACK_OK – PROVIDEROVÁ MAPA VRÁCENA DO PŮVODNÍHO STAVU'
        ELSE
            'ROLLBACK_FAILED – KONTROLNÍ POČTY SE NESHODUJÍ'
    END AS final_status,

    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE is_primary = true
          AND mapping_status = 'ACTIVE'
    ) AS active_primary_rows

FROM public.match_provider_map;