/*
===============================================================================
MATCHMATRIX – BELGIUM JUPILER PRO LEAGUE
REVIEW CASE 1
APPLY – STANDARD LIÈGE × ANDERLECHT CONTROLLED MERGE V1
===============================================================================

HISTORICKÝ ZÁPAS:
- match_id: 7545
- football_data_uk
- výsledek 5:0
- stav FINISHED

KANONICKÝ ZÁPAS:
- match_id: 344386
- api_football
- původní stav CANCELLED
- původní skóre NULL:NULL

TRVALÉ ŘEŠENÍ:
1. Kanonický zápas bude mít oficiální výsledek 5:0 a stav FINISHED.
2. API-Football zůstane primární identitou.
3. football_data_uk bude sekundární identitou stejného zápasu.
4. match_features a mm_match_ratings se převedou.
5. Historická duplicita 7545 se odstraní.
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
    clock_timestamp() AS apply_started_at;

-------------------------------------------------------------------------------
-- 2. POVINNÉ OBJEKTY
-------------------------------------------------------------------------------

DO $objects$
BEGIN
    IF to_regclass('public.matches') IS NULL
       OR to_regclass('public.match_provider_map') IS NULL
       OR to_regclass('public.match_features') IS NULL
       OR to_regclass('public.mm_match_ratings') IS NULL THEN

        RAISE EXCEPTION
            'APPLY_FAILED: Některá povinná tabulka neexistuje.';
    END IF;

    RAISE NOTICE
        'OK OBJECTS: Povinné tabulky existují.';
END
$objects$;

-------------------------------------------------------------------------------
-- 3. PLÁN PŘÍPADU
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_case1_plan
ON COMMIT DROP
AS
SELECT
    historical.id AS historical_match_id,
    target.id AS target_match_id,

    historical.league_id AS historical_league_id,
    historical.kickoff AS historical_kickoff,
    historical.home_team_id AS historical_home_team_id,
    historical.away_team_id AS historical_away_team_id,

    target.league_id AS target_league_id,
    target.kickoff AS target_kickoff,
    target.home_team_id AS target_home_team_id,
    target.away_team_id AS target_away_team_id

FROM public.matches historical
CROSS JOIN public.matches target

WHERE historical.id = 7545
  AND target.id = 344386;

-------------------------------------------------------------------------------
-- 4. KATALOG FOREIGN KEY VAZEB
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_case1_fk_catalog
ON COMMIT DROP
AS
SELECT
    child_namespace.nspname AS schema_name,
    child_table.relname AS table_name,
    child_column.attname AS fk_column,
    constraint_object.conname AS constraint_name

FROM pg_constraint constraint_object

JOIN pg_class child_table
  ON child_table.oid = constraint_object.conrelid

JOIN pg_namespace child_namespace
  ON child_namespace.oid = child_table.relnamespace

JOIN pg_attribute child_column
  ON child_column.attrelid = constraint_object.conrelid
 AND child_column.attnum = constraint_object.conkey[1]

JOIN pg_attribute parent_column
  ON parent_column.attrelid = constraint_object.confrelid
 AND parent_column.attnum = constraint_object.confkey[1]

WHERE constraint_object.contype = 'f'
  AND constraint_object.confrelid = 'public.matches'::regclass
  AND array_length(constraint_object.conkey, 1) = 1
  AND array_length(constraint_object.confkey, 1) = 1
  AND parent_column.attname = 'id';

-------------------------------------------------------------------------------
-- 5. ZAMKNUTÍ TABULEK
-------------------------------------------------------------------------------

LOCK TABLE public.matches
IN SHARE ROW EXCLUSIVE MODE;

LOCK TABLE public.match_provider_map
IN SHARE ROW EXCLUSIVE MODE;

LOCK TABLE public.match_features
IN SHARE ROW EXCLUSIVE MODE;

LOCK TABLE public.mm_match_ratings
IN SHARE ROW EXCLUSIVE MODE;

DO $lock_fk_tables$
DECLARE
    table_record record;
BEGIN
    FOR table_record IN
        SELECT DISTINCT
            schema_name,
            table_name
        FROM mm_be_case1_fk_catalog
        ORDER BY schema_name, table_name
    LOOP
        EXECUTE format(
            'LOCK TABLE %I.%I IN SHARE ROW EXCLUSIVE MODE',
            table_record.schema_name,
            table_record.table_name
        );
    END LOOP;

    RAISE NOTICE
        'OK LOCKS: Hlavní a FK tabulky uzamčeny.';
END
$lock_fk_tables$;

-------------------------------------------------------------------------------
-- 6. VÝCHOZÍ POČTY
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_case1_baseline
ON COMMIT DROP
AS
SELECT
    (SELECT COUNT(*) FROM public.matches)
        AS matches_total,

    (SELECT COUNT(*) FROM public.match_provider_map)
        AS provider_map_total,

    (SELECT COUNT(DISTINCT match_id) FROM public.match_provider_map)
        AS provider_map_distinct_matches,

    (SELECT COUNT(*) FROM public.match_features)
        AS features_total,

    (SELECT COUNT(*) FROM public.mm_match_ratings)
        AS ratings_total,

    (
        SELECT COUNT(*)
        FROM public.mm_match_ratings ratings
        LEFT JOIN public.matches match
          ON match.id = ratings.match_id
        WHERE match.id IS NULL
    ) AS ratings_orphans;

-------------------------------------------------------------------------------
-- 7. SNAPSHOT HODNOT, KTERÉ SE NESMĚJÍ ZMĚNIT
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_case1_target_match_snapshot
ON COMMIT DROP
AS
SELECT
    to_jsonb(match)
        - ARRAY[
            'home_score',
            'away_score',
            'status',
            'updated_at'
          ]::text[] AS preserved_payload

FROM public.matches match
WHERE match.id = 344386;

CREATE TEMP TABLE mm_be_case1_feature_snapshot
ON COMMIT DROP
AS
SELECT
    to_jsonb(features)
        - ARRAY[
            'match_id',
            'updated_at'
          ]::text[] AS preserved_payload

FROM public.match_features features
WHERE features.match_id = 7545;

CREATE TEMP TABLE mm_be_case1_rating_snapshot
ON COMMIT DROP
AS
SELECT
    to_jsonb(ratings)
        - ARRAY[
            'match_id',
            'league_id',
            'kickoff',
            'home_team_id',
            'away_team_id'
          ]::text[] AS preserved_payload

FROM public.mm_match_ratings ratings
WHERE ratings.match_id = 7545;

-------------------------------------------------------------------------------
-- 8. POVINNÁ KONTROLA PŘED APPLY
-------------------------------------------------------------------------------

DO $precheck$
DECLARE
    v_plan_rows bigint;

    v_historical_matches bigint;
    v_target_matches bigint;

    v_historical_identity bigint;
    v_target_identity bigint;

    v_historical_features bigint;
    v_target_features bigint;

    v_historical_ratings bigint;
    v_target_ratings bigint;

    v_target_snapshot bigint;
    v_feature_snapshot bigint;
    v_rating_snapshot bigint;

    v_review_cases bigint;
BEGIN
    SELECT COUNT(*)
    INTO v_plan_rows
    FROM mm_be_case1_plan;

    SELECT COUNT(*)
    INTO v_historical_matches
    FROM public.matches
    WHERE id = 7545
      AND league_id = 4
      AND kickoff::date = DATE '2022-10-23'
      AND home_team_id = 971
      AND away_team_id = 972
      AND home_score = 5
      AND away_score = 0
      AND status = 'FINISHED'
      AND btrim(ext_source::text) = 'football_data_uk';

    SELECT COUNT(*)
    INTO v_target_matches
    FROM public.matches
    WHERE id = 344386
      AND league_id = 20853
      AND kickoff::date = DATE '2022-10-23'
      AND home_team_id = 13537
      AND away_team_id = 12940
      AND home_score IS NULL
      AND away_score IS NULL
      AND status = 'CANCELLED'
      AND btrim(ext_source::text) = 'api_football';

    SELECT COUNT(*)
    INTO v_historical_identity
    FROM public.match_provider_map
    WHERE match_id = 7545
      AND provider = 'football_data_uk'
      AND provider_match_id =
          '4|2223|23/10/2022|Standard|Anderlecht'
      AND is_primary = true
      AND mapping_status = 'ACTIVE';

    SELECT COUNT(*)
    INTO v_target_identity
    FROM public.match_provider_map
    WHERE match_id = 344386
      AND provider = 'api_football'
      AND provider_match_id = '874845'
      AND is_primary = true
      AND mapping_status = 'ACTIVE';

    SELECT COUNT(*)
    INTO v_historical_features
    FROM public.match_features
    WHERE match_id = 7545;

    SELECT COUNT(*)
    INTO v_target_features
    FROM public.match_features
    WHERE match_id = 344386;

    SELECT COUNT(*)
    INTO v_historical_ratings
    FROM public.mm_match_ratings
    WHERE match_id = 7545;

    SELECT COUNT(*)
    INTO v_target_ratings
    FROM public.mm_match_ratings
    WHERE match_id = 344386;

    SELECT COUNT(*)
    INTO v_target_snapshot
    FROM mm_be_case1_target_match_snapshot;

    SELECT COUNT(*)
    INTO v_feature_snapshot
    FROM mm_be_case1_feature_snapshot;

    SELECT COUNT(*)
    INTO v_rating_snapshot
    FROM mm_be_case1_rating_snapshot;

    SELECT COUNT(*)
    INTO v_review_cases
    FROM public.matches
    WHERE id IN (
        7545,
        7569,
        6865
    );

    IF v_plan_rows <> 1
       OR v_historical_matches <> 1
       OR v_target_matches <> 1 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Základní data případu se neshodují.';
    END IF;

    IF v_historical_identity <> 1
       OR v_target_identity <> 1 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Providerové identity se neshodují.';
    END IF;

    IF v_historical_features <> 1
       OR v_target_features <> 0
       OR v_historical_ratings <> 1
       OR v_target_ratings <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Downstream vazby nejsou v očekávaném stavu.';
    END IF;

    IF v_target_snapshot <> 1
       OR v_feature_snapshot <> 1
       OR v_rating_snapshot <> 1 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Snapshoty nejsou úplné.';
    END IF;

    IF v_review_cases <> 3 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Případů k revizi je % místo 3.',
            v_review_cases;
    END IF;

    RAISE NOTICE
        'OK PRECHECK: oba zápasy, dvě identity, features 1/0, ratings 1/0 a review případy 3.';
END
$precheck$;

-------------------------------------------------------------------------------
-- 9. DOPLNĚNÍ OFICIÁLNÍHO VÝSLEDKU
-------------------------------------------------------------------------------

DO $update_match$
DECLARE
    v_updated_rows bigint;
BEGIN
    UPDATE public.matches
    SET
        home_score = 5,
        away_score = 0,
        status = 'FINISHED',
        updated_at = clock_timestamp()
    WHERE id = 344386;

    GET DIAGNOSTICS v_updated_rows = ROW_COUNT;

    IF v_updated_rows <> 1 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Kanonický zápas nebyl aktualizován.';
    END IF;

    RAISE NOTICE
        'OK MATCH APPLY: Kanonický výsledek nastaven na 5:0 / FINISHED.';
END
$update_match$;

-------------------------------------------------------------------------------
-- 10. PROVENIENCE KANONICKÉ IDENTITY
-------------------------------------------------------------------------------

DO $update_target_identity$
DECLARE
    v_updated_rows bigint;
BEGIN
    UPDATE public.match_provider_map
    SET
        metadata =
            COALESCE(metadata, '{}'::jsonb)
            ||
            jsonb_build_object(
                'canonical_result_resolution',
                jsonb_build_object(
                    'resolution_code',
                    'DISCIPLINARY_FORFEIT_5_0',

                    'official_home_score',
                    5,

                    'official_away_score',
                    0,

                    'on_field_score_at_abandonment',
                    '3-1',

                    'original_provider_status',
                    'CANCELLED',

                    'decision_date',
                    '2022-12-22',

                    'source_confirmation_date',
                    '2022-12-23',

                    'resolution_source',
                    'RSC Anderlecht official disciplinary statement',

                    'matchmatrix_review_case',
                    'BELGIUM_REVIEW_CASE_1',

                    'applied_at',
                    clock_timestamp()
                )
            ),

        updated_at = clock_timestamp(),
        updated_by = 'BELGIUM_REVIEW_CASE_1_APPLY'

    WHERE match_id = 344386
      AND provider = 'api_football';

    GET DIAGNOSTICS v_updated_rows = ROW_COUNT;

    IF v_updated_rows <> 1 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Kanonická providerová identita nebyla aktualizována.';
    END IF;
END
$update_target_identity$;

-------------------------------------------------------------------------------
-- 11. PŘESUN HISTORICKÉ IDENTITY
-------------------------------------------------------------------------------

DO $move_historical_identity$
DECLARE
    v_updated_rows bigint;
BEGIN
    UPDATE public.match_provider_map
    SET
        match_id = 344386,
        is_primary = false,

        metadata =
            COALESCE(metadata, '{}'::jsonb)
            ||
            jsonb_build_object(
                'review_case_merge',
                jsonb_build_object(
                    'merge_code',
                    'BELGIUM_REVIEW_CASE_1',

                    'previous_match_id',
                    7545,

                    'target_match_id',
                    344386,

                    'official_result',
                    '5-0',

                    'on_field_score_at_abandonment',
                    '3-1',

                    'resolution_type',
                    'DISCIPLINARY_FORFEIT',

                    'canonical_provider',
                    'api_football',

                    'secondary_source',
                    'football_data_uk',

                    'reversible',
                    true,

                    'applied_at',
                    clock_timestamp()
                )
            ),

        updated_at = clock_timestamp(),
        updated_by = 'BELGIUM_REVIEW_CASE_1_APPLY'

    WHERE match_id = 7545
      AND provider = 'football_data_uk';

    GET DIAGNOSTICS v_updated_rows = ROW_COUNT;

    IF v_updated_rows <> 1 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Historická identita nebyla přesunuta.';
    END IF;

    RAISE NOTICE
        'OK IDENTITY APPLY: football_data_uk přesunuta jako sekundární identita.';
END
$move_historical_identity$;

-------------------------------------------------------------------------------
-- 12. PŘEVOD match_features
-------------------------------------------------------------------------------

DO $move_features$
DECLARE
    v_updated_rows bigint;
BEGIN
    UPDATE public.match_features
    SET
        match_id = 344386,
        updated_at = clock_timestamp()
    WHERE match_id = 7545;

    GET DIAGNOSTICS v_updated_rows = ROW_COUNT;

    IF v_updated_rows <> 1 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: match_features nebyla převedena.';
    END IF;

    RAISE NOTICE
        'OK FEATURES APPLY: Převeden 1 řádek.';
END
$move_features$;

-------------------------------------------------------------------------------
-- 13. PŘEVOD mm_match_ratings
-------------------------------------------------------------------------------

DO $move_ratings$
DECLARE
    v_updated_rows bigint;
BEGIN
    UPDATE public.mm_match_ratings ratings
    SET
        match_id = 344386,
        league_id = target.league_id,

        kickoff =
            target.kickoff::timestamp
            AT TIME ZONE 'UTC',

        home_team_id = target.home_team_id,
        away_team_id = target.away_team_id

    FROM public.matches target

    WHERE ratings.match_id = 7545
      AND target.id = 344386;

    GET DIAGNOSTICS v_updated_rows = ROW_COUNT;

    IF v_updated_rows <> 1 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: mm_match_ratings nebyla převedena.';
    END IF;

    RAISE NOTICE
        'OK RATINGS APPLY: Převeden a rozměrově sjednocen 1 řádek.';
END
$move_ratings$;

-------------------------------------------------------------------------------
-- 14. KONTROLA ZBÝVAJÍCÍCH FK VAZEB NA HISTORICKÝ ZÁPAS
-------------------------------------------------------------------------------

DO $remaining_fk_check$
DECLARE
    fk_record record;
    v_reference_rows bigint;
BEGIN
    FOR fk_record IN
        SELECT *
        FROM mm_be_case1_fk_catalog
        ORDER BY schema_name, table_name, fk_column
    LOOP
        EXECUTE format(
            'SELECT COUNT(*) FROM %I.%I WHERE %I = $1',
            fk_record.schema_name,
            fk_record.table_name,
            fk_record.fk_column
        )
        INTO v_reference_rows
        USING 7545;

        IF v_reference_rows <> 0 THEN
            RAISE EXCEPTION
                'APPLY_FAILED: Tabulka %.% stále obsahuje % vazeb na zápas 7545.',
                fk_record.schema_name,
                fk_record.table_name,
                v_reference_rows;
        END IF;
    END LOOP;

    RAISE NOTICE
        'OK FK CHECK: Na historický zápas nezůstala žádná FK vazba.';
END
$remaining_fk_check$;

-------------------------------------------------------------------------------
-- 15. KONTROLA MĚKKÝCH VAZEB
-------------------------------------------------------------------------------

DO $remaining_soft_check$
DECLARE
    column_record record;
    v_reference_rows bigint;
BEGIN
    FOR column_record IN
        SELECT
            namespace_object.nspname AS schema_name,
            table_object.relname AS table_name,
            column_object.attname AS column_name

        FROM pg_attribute column_object

        JOIN pg_class table_object
          ON table_object.oid = column_object.attrelid

        JOIN pg_namespace namespace_object
          ON namespace_object.oid = table_object.relnamespace

        WHERE table_object.relkind IN ('r', 'p')
          AND column_object.attnum > 0
          AND NOT column_object.attisdropped

          AND column_object.attname IN (
              'match_id',
              'canonical_match_id'
          )

          AND namespace_object.nspname NOT IN (
              'pg_catalog',
              'information_schema'
          )

          AND namespace_object.nspname !~ '^pg_toast'
          AND namespace_object.nspname !~ '^pg_temp'

          AND NOT (
              namespace_object.nspname = 'public'
              AND table_object.relname IN (
                  'matches',
                  'match_provider_map'
              )
          )

          AND NOT EXISTS
          (
              SELECT 1
              FROM mm_be_case1_fk_catalog fk
              WHERE fk.schema_name =
                    namespace_object.nspname
                AND fk.table_name =
                    table_object.relname
                AND fk.fk_column =
                    column_object.attname
          )

        ORDER BY
            namespace_object.nspname,
            table_object.relname,
            column_object.attname
    LOOP
        EXECUTE format(
            'SELECT COUNT(*) FROM %I.%I WHERE %I::text = $1',
            column_record.schema_name,
            column_record.table_name,
            column_record.column_name
        )
        INTO v_reference_rows
        USING '7545';

        IF v_reference_rows <> 0 THEN
            RAISE EXCEPTION
                'APPLY_FAILED: Tabulka %.% stále obsahuje % měkkých vazeb na zápas 7545.',
                column_record.schema_name,
                column_record.table_name,
                v_reference_rows;
        END IF;
    END LOOP;

    RAISE NOTICE
        'OK SOFT CHECK: Na historický zápas nezůstala žádná měkká vazba.';
END
$remaining_soft_check$;

-------------------------------------------------------------------------------
-- 16. ODSTRANĚNÍ HISTORICKÉ DUPLICITY
-------------------------------------------------------------------------------

DO $delete_historical_match$
DECLARE
    v_deleted_rows bigint;
BEGIN
    DELETE FROM public.matches
    WHERE id = 7545;

    GET DIAGNOSTICS v_deleted_rows = ROW_COUNT;

    IF v_deleted_rows <> 1 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Historický zápas 7545 nebyl odstraněn.';
    END IF;

    RAISE NOTICE
        'OK DELETE APPLY: Historická duplicita 7545 odstraněna.';
END
$delete_historical_match$;

-------------------------------------------------------------------------------
-- 17. ÚPLNÁ KONTROLA PŘED COMMIT
-------------------------------------------------------------------------------

DO $postcheck$
DECLARE
    v_baseline_matches bigint;
    v_baseline_provider bigint;
    v_baseline_provider_matches bigint;
    v_baseline_features bigint;
    v_baseline_ratings bigint;
    v_baseline_rating_orphans bigint;

    v_matches_total bigint;
    v_provider_total bigint;
    v_provider_matches bigint;
    v_features_total bigint;
    v_ratings_total bigint;
    v_rating_orphans bigint;

    v_historical_match bigint;
    v_target_match bigint;

    v_target_identities bigint;
    v_target_primary bigint;
    v_api_identity bigint;
    v_history_identity bigint;

    v_previous_features bigint;
    v_target_features bigint;

    v_previous_ratings bigint;
    v_target_ratings bigint;
    v_aligned_ratings bigint;

    v_target_payload_mismatch bigint;
    v_feature_payload_mismatch bigint;
    v_rating_payload_mismatch bigint;

    v_provider_orphans bigint;
    v_review_cases bigint;
BEGIN
    SELECT
        matches_total,
        provider_map_total,
        provider_map_distinct_matches,
        features_total,
        ratings_total,
        ratings_orphans
    INTO
        v_baseline_matches,
        v_baseline_provider,
        v_baseline_provider_matches,
        v_baseline_features,
        v_baseline_ratings,
        v_baseline_rating_orphans
    FROM mm_be_case1_baseline;

    SELECT COUNT(*)
    INTO v_historical_match
    FROM public.matches
    WHERE id = 7545;

    SELECT COUNT(*)
    INTO v_target_match
    FROM public.matches
    WHERE id = 344386
      AND home_score = 5
      AND away_score = 0
      AND status = 'FINISHED';

    SELECT
        COUNT(*),

        COUNT(*) FILTER (
            WHERE is_primary = true
              AND mapping_status = 'ACTIVE'
        ),

        COUNT(*) FILTER (
            WHERE provider = 'api_football'
        ),

        COUNT(*) FILTER (
            WHERE provider = 'football_data_uk'
        )
    INTO
        v_target_identities,
        v_target_primary,
        v_api_identity,
        v_history_identity
    FROM public.match_provider_map
    WHERE match_id = 344386;

    SELECT COUNT(*)
    INTO v_previous_features
    FROM public.match_features
    WHERE match_id = 7545;

    SELECT COUNT(*)
    INTO v_target_features
    FROM public.match_features
    WHERE match_id = 344386;

    SELECT COUNT(*)
    INTO v_previous_ratings
    FROM public.mm_match_ratings
    WHERE match_id = 7545;

    SELECT COUNT(*)
    INTO v_target_ratings
    FROM public.mm_match_ratings
    WHERE match_id = 344386;

    SELECT COUNT(*)
    INTO v_aligned_ratings
    FROM public.mm_match_ratings ratings
    JOIN public.matches target
      ON target.id = ratings.match_id
    WHERE ratings.match_id = 344386
      AND ratings.league_id = target.league_id
      AND ratings.kickoff =
          target.kickoff::timestamp
          AT TIME ZONE 'UTC'
      AND ratings.home_team_id = target.home_team_id
      AND ratings.away_team_id = target.away_team_id;

    SELECT COUNT(*)
    INTO v_target_payload_mismatch
    FROM public.matches match
    CROSS JOIN mm_be_case1_target_match_snapshot snapshot
    WHERE match.id = 344386
      AND (
          to_jsonb(match)
              - ARRAY[
                  'home_score',
                  'away_score',
                  'status',
                  'updated_at'
                ]::text[]
      ) IS DISTINCT FROM snapshot.preserved_payload;

    SELECT COUNT(*)
    INTO v_feature_payload_mismatch
    FROM public.match_features features
    CROSS JOIN mm_be_case1_feature_snapshot snapshot
    WHERE features.match_id = 344386
      AND (
          to_jsonb(features)
              - ARRAY[
                  'match_id',
                  'updated_at'
                ]::text[]
      ) IS DISTINCT FROM snapshot.preserved_payload;

    SELECT COUNT(*)
    INTO v_rating_payload_mismatch
    FROM public.mm_match_ratings ratings
    CROSS JOIN mm_be_case1_rating_snapshot snapshot
    WHERE ratings.match_id = 344386
      AND (
          to_jsonb(ratings)
              - ARRAY[
                  'match_id',
                  'league_id',
                  'kickoff',
                  'home_team_id',
                  'away_team_id'
                ]::text[]
      ) IS DISTINCT FROM snapshot.preserved_payload;

    SELECT COUNT(*)
    INTO v_provider_orphans
    FROM public.match_provider_map identity
    LEFT JOIN public.matches match
      ON match.id = identity.match_id
    WHERE match.id IS NULL;

    SELECT COUNT(*)
    INTO v_review_cases
    FROM public.matches
    WHERE id IN (
        7545,
        7569,
        6865
    );

    SELECT COUNT(*)
    INTO v_matches_total
    FROM public.matches;

    SELECT
        COUNT(*),
        COUNT(DISTINCT match_id)
    INTO
        v_provider_total,
        v_provider_matches
    FROM public.match_provider_map;

    SELECT COUNT(*)
    INTO v_features_total
    FROM public.match_features;

    SELECT COUNT(*)
    INTO v_ratings_total
    FROM public.mm_match_ratings;

    SELECT COUNT(*)
    INTO v_rating_orphans
    FROM public.mm_match_ratings ratings
    LEFT JOIN public.matches match
      ON match.id = ratings.match_id
    WHERE match.id IS NULL;

    IF v_historical_match <> 0
       OR v_target_match <> 1 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Kanonický nebo historický zápas má nesprávný stav.';
    END IF;

    IF v_target_identities <> 2
       OR v_target_primary <> 1
       OR v_api_identity <> 1
       OR v_history_identity <> 1 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Providerové identity nejsou správně sloučeny.';
    END IF;

    IF v_previous_features <> 0
       OR v_target_features <> 1
       OR v_previous_ratings <> 0
       OR v_target_ratings <> 1
       OR v_aligned_ratings <> 1 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Downstream data nejsou správně převedena.';
    END IF;

    IF v_target_payload_mismatch <> 0
       OR v_feature_payload_mismatch <> 0
       OR v_rating_payload_mismatch <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Neočekávaná změna zachovávaných dat.';
    END IF;

    IF v_provider_orphans <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Nalezeny osiřelé providerové identity.';
    END IF;

    IF v_review_cases <> 2 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Zbývajících případů k revizi je % místo 2.',
            v_review_cases;
    END IF;

    IF v_matches_total <> v_baseline_matches - 1
       OR v_provider_total <> v_baseline_provider
       OR v_provider_matches <> v_baseline_provider_matches - 1
       OR v_features_total <> v_baseline_features
       OR v_ratings_total <> v_baseline_ratings
       OR v_rating_orphans <> v_baseline_rating_orphans THEN

        RAISE EXCEPTION
            'APPLY_FAILED: Neočekávaná změna celkových počtů.';
    END IF;

    RAISE NOTICE
        'OK POSTCHECK: výsledek 5:0, FINISHED, dvě identity, jedna primární, downstream data převedena, duplicita odstraněna a review případy 2.';
END
$postcheck$;

-------------------------------------------------------------------------------
-- 18. SOUHRN PŘED COMMIT
-------------------------------------------------------------------------------

SELECT
    'HISTORICAL_MATCH_REMAINING' AS check_name,
    COUNT(*)::text AS result
FROM public.matches
WHERE id = 7545

UNION ALL

SELECT
    'CANONICAL_MATCH_OFFICIAL_RESULT',
    CONCAT(
        home_score,
        ':',
        away_score,
        ' / ',
        status
    )
FROM public.matches
WHERE id = 344386

UNION ALL

SELECT
    'CANONICAL_PROVIDER_IDENTITIES',
    COUNT(*)::text
FROM public.match_provider_map
WHERE match_id = 344386

UNION ALL

SELECT
    'CANONICAL_ACTIVE_PRIMARY_IDENTITIES',
    COUNT(*)::text
FROM public.match_provider_map
WHERE match_id = 344386
  AND is_primary = true
  AND mapping_status = 'ACTIVE'

UNION ALL

SELECT
    'CANONICAL_MATCH_FEATURES',
    COUNT(*)::text
FROM public.match_features
WHERE match_id = 344386

UNION ALL

SELECT
    'CANONICAL_MATCH_RATINGS',
    COUNT(*)::text
FROM public.mm_match_ratings
WHERE match_id = 344386

UNION ALL

SELECT
    'REVIEW_CASES_REMAINING',
    COUNT(*)::text
FROM public.matches
WHERE id IN (
    7545,
    7569,
    6865
);

SELECT
    'APPLY_VALIDATED – REVIEW CASE 1 PŘIPRAVEN K COMMIT'
        AS pre_commit_status;

-------------------------------------------------------------------------------
-- 19. TRVALÉ ULOŽENÍ
-------------------------------------------------------------------------------

COMMIT;

-------------------------------------------------------------------------------
-- 20. AKTUALIZACE STATISTIK
-------------------------------------------------------------------------------

ANALYZE public.matches;
ANALYZE public.match_provider_map;
ANALYZE public.match_features;
ANALYZE public.mm_match_ratings;

-------------------------------------------------------------------------------
-- 21. KONEČNÝ POST-COMMIT AUDIT
-------------------------------------------------------------------------------

WITH final_counts AS
(
    SELECT
        (
            SELECT COUNT(*)
            FROM public.matches
        ) AS total_matches,

        (
            SELECT COUNT(*)
            FROM public.matches
            WHERE id = 7545
        ) AS historical_matches,

        (
            SELECT COUNT(*)
            FROM public.matches
            WHERE id = 344386
              AND home_score = 5
              AND away_score = 0
              AND status = 'FINISHED'
        ) AS canonical_matches,

        (
            SELECT COUNT(*)
            FROM public.match_provider_map
            WHERE match_id = 344386
        ) AS canonical_identities,

        (
            SELECT COUNT(*)
            FROM public.match_provider_map
            WHERE match_id = 344386
              AND is_primary = true
              AND mapping_status = 'ACTIVE'
        ) AS canonical_primary_identities,

        (
            SELECT COUNT(*)
            FROM public.match_features
            WHERE match_id = 344386
        ) AS canonical_features,

        (
            SELECT COUNT(*)
            FROM public.mm_match_ratings ratings
            JOIN public.matches match
              ON match.id = ratings.match_id
            WHERE ratings.match_id = 344386
              AND ratings.league_id = match.league_id
              AND ratings.kickoff =
                  match.kickoff::timestamp
                  AT TIME ZONE 'UTC'
              AND ratings.home_team_id = match.home_team_id
              AND ratings.away_team_id = match.away_team_id
        ) AS canonical_ratings,

        (
            SELECT COUNT(*)
            FROM public.matches
            WHERE id IN (
                7545,
                7569,
                6865
            )
        ) AS remaining_review_cases,

        (
            SELECT COUNT(*)
            FROM public.match_provider_map identity
            LEFT JOIN public.matches match
              ON match.id = identity.match_id
            WHERE match.id IS NULL
        ) AS provider_orphans
)
SELECT
    CASE
        WHEN total_matches = 120983
         AND historical_matches = 0
         AND canonical_matches = 1
         AND canonical_identities = 2
         AND canonical_primary_identities = 1
         AND canonical_features = 1
         AND canonical_ratings = 1
         AND remaining_review_cases = 2
         AND provider_orphans = 0
        THEN
            'APPLY_OK – REVIEW CASE 1 TRVALE SLOUČEN'

        ELSE
            'APPLY_POST_COMMIT_WARNING – KONTROLNÍ POČTY SE NESHODUJÍ'
    END AS final_status,

    total_matches,
    historical_matches,
    canonical_matches,
    canonical_identities,
    canonical_primary_identities,
    canonical_features,
    canonical_ratings,
    remaining_review_cases,
    provider_orphans

FROM final_counts;