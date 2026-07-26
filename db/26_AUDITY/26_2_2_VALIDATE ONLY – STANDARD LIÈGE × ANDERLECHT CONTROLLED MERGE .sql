/*
===============================================================================
MATCHMATRIX – BELGIUM JUPILER PRO LEAGUE
REVIEW CASE 1
VALIDATE ONLY – STANDARD LIÈGE × ANDERLECHT CONTROLLED MERGE V1
===============================================================================

HISTORICKÝ ZÁPAS:
- match_id: 7545
- football_data_uk
- FINISHED
- oficiální kontumační výsledek 5:0

KANONICKÝ CÍL:
- match_id: 344386
- api_football
- aktuálně CANCELLED, skóre NULL:NULL

ŘÍZENÉ ŘEŠENÍ:
1. Kanonický zápas dostane výsledek 5:0 a stav FINISHED.
2. Událost ukončení při stavu 3:1 se zachová v metadata.
3. Identita football_data_uk se přesune na kanonický zápas jako sekundární.
4. match_features a mm_match_ratings se převedou na kanonický zápas.
5. Historický duplicitní zápas se zkušebně odstraní.
6. Na konci proběhne povinný ROLLBACK.
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
    IF to_regclass('public.matches') IS NULL
       OR to_regclass('public.match_provider_map') IS NULL
       OR to_regclass('public.match_features') IS NULL
       OR to_regclass('public.mm_match_ratings') IS NULL THEN

        RAISE EXCEPTION
            'VALIDATION_FAILED: Některá povinná tabulka neexistuje.';
    END IF;

    RAISE NOTICE
        'OK OBJECTS: Povinné tabulky existují.';
END
$objects$;

-------------------------------------------------------------------------------
-- 3. ZAMKNUTÍ HLAVNÍCH TABULEK
-------------------------------------------------------------------------------

LOCK TABLE public.matches
IN SHARE ROW EXCLUSIVE MODE;

LOCK TABLE public.match_provider_map
IN SHARE ROW EXCLUSIVE MODE;

LOCK TABLE public.match_features
IN SHARE ROW EXCLUSIVE MODE;

LOCK TABLE public.mm_match_ratings
IN SHARE ROW EXCLUSIVE MODE;

-------------------------------------------------------------------------------
-- 4. PLÁN PŘÍPADU
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
-- 5. KATALOG FK VAZEB
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
-- 6. ZAMKNUTÍ VŠECH FK TABULEK
-------------------------------------------------------------------------------

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
        'OK LOCKS: Všechny tabulky odkazující na public.matches byly uzamčeny.';
END
$lock_fk_tables$;

-------------------------------------------------------------------------------
-- 7. VÝCHOZÍ POČTY
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_case1_baseline
ON COMMIT DROP
AS
SELECT
    (SELECT COUNT(*) FROM public.matches)
        AS matches_total,

    (SELECT COUNT(*) FROM public.match_provider_map)
        AS provider_map_total,

    (SELECT COUNT(*) FROM public.match_features)
        AS features_total,

    (SELECT COUNT(*) FROM public.mm_match_ratings)
        AS ratings_total;

-------------------------------------------------------------------------------
-- 8. AUDIT FK VAZEB
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_case1_fk_audit
(
    schema_name text,
    table_name text,
    fk_column text,
    historical_rows bigint,
    target_rows bigint
)
ON COMMIT DROP;

DO $audit_fk$
DECLARE
    fk_record record;
    v_historical bigint;
    v_target bigint;
BEGIN
    FOR fk_record IN
        SELECT *
        FROM mm_be_case1_fk_catalog
        ORDER BY schema_name, table_name, fk_column
    LOOP
        EXECUTE format(
            'SELECT COUNT(*) FROM %I.%I WHERE %I = 7545',
            fk_record.schema_name,
            fk_record.table_name,
            fk_record.fk_column
        )
        INTO v_historical;

        EXECUTE format(
            'SELECT COUNT(*) FROM %I.%I WHERE %I = 344386',
            fk_record.schema_name,
            fk_record.table_name,
            fk_record.fk_column
        )
        INTO v_target;

        INSERT INTO mm_be_case1_fk_audit
        VALUES
        (
            fk_record.schema_name,
            fk_record.table_name,
            fk_record.fk_column,
            v_historical,
            v_target
        );
    END LOOP;
END
$audit_fk$;

-------------------------------------------------------------------------------
-- 9. POVINNÁ KONTROLA PŘED MIGRACÍ
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

    v_other_historical_fk bigint;
BEGIN
    SELECT COUNT(*)
    INTO v_plan_rows
    FROM mm_be_case1_plan;

    SELECT COUNT(*)
    INTO v_historical_matches
    FROM public.matches
    WHERE id = 7545
      AND league_id = 4
      AND home_team_id = 971
      AND away_team_id = 972
      AND home_score = 5
      AND away_score = 0
      AND status = 'FINISHED'
      AND btrim(ext_source) = 'football_data_uk';

    SELECT COUNT(*)
    INTO v_target_matches
    FROM public.matches
    WHERE id = 344386
      AND league_id = 20853
      AND home_team_id = 13537
      AND away_team_id = 12940
      AND home_score IS NULL
      AND away_score IS NULL
      AND status = 'CANCELLED'
      AND btrim(ext_source) = 'api_football';

    SELECT COUNT(*)
    INTO v_historical_identity
    FROM public.match_provider_map
    WHERE match_id = 7545
      AND provider = 'football_data_uk'
      AND is_primary = true
      AND mapping_status = 'ACTIVE';

    SELECT COUNT(*)
    INTO v_target_identity
    FROM public.match_provider_map
    WHERE match_id = 344386
      AND provider = 'api_football'
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

    SELECT COALESCE(SUM(historical_rows), 0)
    INTO v_other_historical_fk
    FROM mm_be_case1_fk_audit
    WHERE NOT (
        schema_name = 'public'
        AND table_name IN (
            'match_provider_map',
            'match_features'
        )
    );

    IF v_plan_rows <> 1
       OR v_historical_matches <> 1
       OR v_target_matches <> 1 THEN

        RAISE EXCEPTION
            'VALIDATION_FAILED: Základní data případu se neshodují.';
    END IF;

    IF v_historical_identity <> 1
       OR v_target_identity <> 1 THEN

        RAISE EXCEPTION
            'VALIDATION_FAILED: Providerové identity se neshodují.';
    END IF;

    IF v_historical_features <> 1
       OR v_target_features <> 0
       OR v_historical_ratings <> 1
       OR v_target_ratings <> 0 THEN

        RAISE EXCEPTION
            'VALIDATION_FAILED: Downstream vazby nejsou v očekávaném stavu.';
    END IF;

    IF v_other_historical_fk <> 0 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Nalezeno % dalších FK vazeb.',
            v_other_historical_fk;
    END IF;

    RAISE NOTICE
        'OK PRECHECK: oba zápasy, dvě identity, features 1/0, ratings 1/0 a žádné další FK vazby.';
END
$precheck$;

-------------------------------------------------------------------------------
-- 10. DOPLNĚNÍ OFICIÁLNÍHO VÝSLEDKU NA KANONICKÝ ZÁPAS
-------------------------------------------------------------------------------

UPDATE public.matches
SET
    home_score = 5,
    away_score = 0,
    status = 'FINISHED',
    updated_at = clock_timestamp()
WHERE id = 344386;

-------------------------------------------------------------------------------
-- 11. DOPLNĚNÍ PROVENIENCE K API-FOOTBALL IDENTITĚ
-------------------------------------------------------------------------------

UPDATE public.match_provider_map
SET
    metadata =
        metadata ||
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

                'validated_at',
                clock_timestamp()
            )
        )
WHERE match_id = 344386
  AND provider = 'api_football';

-------------------------------------------------------------------------------
-- 12. PŘESUN HISTORICKÉ IDENTITY
-------------------------------------------------------------------------------

UPDATE public.match_provider_map
SET
    match_id = 344386,
    is_primary = false,

    metadata =
        metadata ||
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

                'validated_at',
                clock_timestamp()
            )
        )

WHERE match_id = 7545
  AND provider = 'football_data_uk';

-------------------------------------------------------------------------------
-- 13. PŘEVOD match_features
-------------------------------------------------------------------------------

UPDATE public.match_features
SET
    match_id = 344386,
    updated_at = clock_timestamp()
WHERE match_id = 7545;

-------------------------------------------------------------------------------
-- 14. PŘEVOD mm_match_ratings A SROVNÁNÍ DIMENZÍ
-------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------
-- 15. ZKUŠEBNÍ ODSTRANĚNÍ HISTORICKÉ DUPLICITY
-------------------------------------------------------------------------------

DELETE FROM public.matches
WHERE id = 7545;

-------------------------------------------------------------------------------
-- 16. ÚPLNÁ KONTROLA PO MIGRACI
-------------------------------------------------------------------------------

DO $postcheck$
DECLARE
    v_historical_match bigint;
    v_target_match bigint;

    v_target_identities bigint;
    v_target_primary bigint;
    v_api_identity bigint;
    v_history_identity bigint;

    v_historical_features bigint;
    v_target_features bigint;

    v_historical_ratings bigint;
    v_target_ratings bigint;
    v_aligned_ratings bigint;

    v_provider_orphans bigint;

    v_matches_total bigint;
    v_provider_total bigint;
    v_features_total bigint;
    v_ratings_total bigint;

    v_baseline_matches bigint;
    v_baseline_provider bigint;
    v_baseline_features bigint;
    v_baseline_ratings bigint;
BEGIN
    SELECT
        matches_total,
        provider_map_total,
        features_total,
        ratings_total
    INTO
        v_baseline_matches,
        v_baseline_provider,
        v_baseline_features,
        v_baseline_ratings
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
    INTO v_aligned_ratings
    FROM public.mm_match_ratings ratings
    JOIN public.matches target
      ON target.id = 344386
    WHERE ratings.match_id = 344386
      AND ratings.league_id = target.league_id
      AND ratings.kickoff =
          target.kickoff::timestamp
          AT TIME ZONE 'UTC'
      AND ratings.home_team_id = target.home_team_id
      AND ratings.away_team_id = target.away_team_id;

    SELECT COUNT(*)
    INTO v_provider_orphans
    FROM public.match_provider_map identity
    LEFT JOIN public.matches match
      ON match.id = identity.match_id
    WHERE match.id IS NULL;

    SELECT COUNT(*) INTO v_matches_total
    FROM public.matches;

    SELECT COUNT(*) INTO v_provider_total
    FROM public.match_provider_map;

    SELECT COUNT(*) INTO v_features_total
    FROM public.match_features;

    SELECT COUNT(*) INTO v_ratings_total
    FROM public.mm_match_ratings;

    IF v_historical_match <> 0
       OR v_target_match <> 1 THEN

        RAISE EXCEPTION
            'VALIDATION_FAILED: Kanonický nebo historický zápas má nesprávný stav.';
    END IF;

    IF v_target_identities <> 2
       OR v_target_primary <> 1
       OR v_api_identity <> 1
       OR v_history_identity <> 1 THEN

        RAISE EXCEPTION
            'VALIDATION_FAILED: Providerové identity nejsou správně sloučeny.';
    END IF;

    IF v_historical_features <> 0
       OR v_target_features <> 1
       OR v_historical_ratings <> 0
       OR v_target_ratings <> 1
       OR v_aligned_ratings <> 1 THEN

        RAISE EXCEPTION
            'VALIDATION_FAILED: Downstream data nejsou správně převedena.';
    END IF;

    IF v_provider_orphans <> 0 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Nalezeny osiřelé providerové identity.';
    END IF;

    IF v_matches_total <> v_baseline_matches - 1
       OR v_provider_total <> v_baseline_provider
       OR v_features_total <> v_baseline_features
       OR v_ratings_total <> v_baseline_ratings THEN

        RAISE EXCEPTION
            'VALIDATION_FAILED: Neočekávaná změna celkových počtů.';
    END IF;

    RAISE NOTICE
        'OK POSTCHECK: výsledek 5:0, status FINISHED, dvě identity, jedna primární, downstream data převedena a historická duplicita odstraněna.';
END
$postcheck$;

-------------------------------------------------------------------------------
-- 17. SOUHRN PŘED ROLLBACKEM
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
WHERE match_id = 344386;

SELECT
    'VALIDATE_ONLY_REVIEW_CASE_1_OK – OFICIÁLNÍ VÝSLEDEK 5:0 A ÚPLNÉ SLOUČENÍ OVĚŘENO'
        AS validation_status;

-------------------------------------------------------------------------------
-- 18. POVINNÝ ROLLBACK
-------------------------------------------------------------------------------

ROLLBACK;

-------------------------------------------------------------------------------
-- 19. KONTROLA OBNOVENÍ PŮVODNÍHO STAVU
-------------------------------------------------------------------------------

SELECT
    CASE
        WHEN (
            SELECT COUNT(*)
            FROM public.matches
            WHERE id = 7545
              AND home_score = 5
              AND away_score = 0
              AND status = 'FINISHED'
        ) = 1

        AND (
            SELECT COUNT(*)
            FROM public.matches
            WHERE id = 344386
              AND home_score IS NULL
              AND away_score IS NULL
              AND status = 'CANCELLED'
        ) = 1

        AND (
            SELECT COUNT(*)
            FROM public.match_provider_map
            WHERE match_id = 7545
              AND provider = 'football_data_uk'
              AND is_primary = true
        ) = 1

        AND (
            SELECT COUNT(*)
            FROM public.match_features
            WHERE match_id = 7545
        ) = 1

        AND (
            SELECT COUNT(*)
            FROM public.mm_match_ratings
            WHERE match_id = 7545
        ) = 1

        THEN
            'ROLLBACK_OK – REVIEW CASE 1 VRÁCEN DO PŮVODNÍHO STAVU'

        ELSE
            'ROLLBACK_FAILED – KONTROLNÍ STAV SE NESHODUJE'
    END AS final_status;