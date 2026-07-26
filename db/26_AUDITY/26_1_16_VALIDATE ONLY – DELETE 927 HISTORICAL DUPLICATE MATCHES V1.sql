/*
===============================================================================
MATCHMATRIX – BELGIUM JUPILER PRO LEAGUE
VALIDATE ONLY – DELETE 927 HISTORICAL DUPLICATE MATCHES V1
===============================================================================

CO:
- Zkušebně odstraní 927 historických zápasů football_data_uk,
  jejichž identita a downstream data již byly převedeny na kanonické
  zápasy API-Football.

NEMAŽE:
- 1284 unikátních historických zápasů,
- 3 případy k ruční revizi,
- žádný API-Football zápas,
- žádnou providerovou identitu,
- žádná downstream data.

BEZPEČNOST:
- Úplná transakce.
- Kontrola všech deklarovaných foreign key vazeb.
- Kontrola měkkých match_id vazeb.
- Kontrola počtů všech FK tabulek před a po DELETE.
- Povinný ROLLBACK.
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

    IF to_regclass('public.match_provider_map') IS NULL THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: public.match_provider_map neexistuje.';
    END IF;

    IF to_regclass('public.match_features') IS NULL THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: public.match_features neexistuje.';
    END IF;

    IF to_regclass('public.mm_match_ratings') IS NULL THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: public.mm_match_ratings neexistuje.';
    END IF;

    RAISE NOTICE
        'OK OBJECTS: Povinné tabulky existují.';
END
$objects$;

-------------------------------------------------------------------------------
-- 3. OCHRANA PROTI SOUBĚŽNÝM ZMĚNÁM
-------------------------------------------------------------------------------

LOCK TABLE public.matches
IN SHARE ROW EXCLUSIVE MODE;

LOCK TABLE public.match_provider_map
IN SHARE MODE;

LOCK TABLE
    public.article_match_map,
    public.generated_ticket_fixed,
    public.lineups,
    public.match_events,
    public.match_features,
    public.match_officials,
    public.match_weather,
    public.ml_predictions,
    public.mm_ticket_scenario_block_matches,
    public.odds,
    public.player_match_statistics,
    public.selection_items,
    public.team_match_statistics,
    public.template_block_matches,
    public.template_fixed_picks,
    public.ticket_block_matches,
    public.ticket_constants,
    public.ticket_variant_matches,
    public.mm_match_ratings
IN SHARE ROW EXCLUSIVE MODE;

-------------------------------------------------------------------------------
-- 4. PLÁN MAZÁNÍ
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_delete_plan
ON COMMIT DROP
AS
SELECT DISTINCT
    (metadata ->> 'previous_match_id')::integer
        AS previous_match_id,

    (metadata ->> 'target_match_id')::integer
        AS target_match_id

FROM public.match_provider_map

WHERE metadata ->> 'belgium_identity_transfer'
      = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1';

CREATE UNIQUE INDEX mm_be_delete_plan_previous_uq
    ON mm_be_delete_plan(previous_match_id);

CREATE UNIQUE INDEX mm_be_delete_plan_target_uq
    ON mm_be_delete_plan(target_match_id);

-------------------------------------------------------------------------------
-- 5. KATALOG FOREIGN KEY VAZEB NA public.matches(id)
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_match_fk_catalog
ON COMMIT DROP
AS
SELECT
    constraint_object.oid AS constraint_oid,
    constraint_object.conname AS constraint_name,

    child_namespace.nspname AS schema_name,
    child_table.relname AS table_name,
    child_column.attname AS fk_column,

    pg_get_constraintdef(
        constraint_object.oid,
        true
    ) AS constraint_definition

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

  AND constraint_object.confrelid =
      'public.matches'::regclass

  AND array_length(
          constraint_object.conkey,
          1
      ) = 1

  AND array_length(
          constraint_object.confkey,
          1
      ) = 1

  AND parent_column.attname = 'id';

-------------------------------------------------------------------------------
-- 6. SNAPSHOT POČTŮ VŠECH FK TABULEK
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_fk_table_counts_before
(
    schema_name text NOT NULL,
    table_name text NOT NULL,
    row_count bigint NOT NULL,
    PRIMARY KEY (schema_name, table_name)
)
ON COMMIT DROP;

DO $snapshot_fk_tables$
DECLARE
    table_record record;
    v_row_count bigint;
BEGIN
    FOR table_record IN
        SELECT DISTINCT
            schema_name,
            table_name
        FROM mm_be_match_fk_catalog
        ORDER BY schema_name, table_name
    LOOP
        EXECUTE format(
            'SELECT COUNT(*) FROM %I.%I',
            table_record.schema_name,
            table_record.table_name
        )
        INTO v_row_count;

        INSERT INTO mm_be_fk_table_counts_before
        (
            schema_name,
            table_name,
            row_count
        )
        VALUES
        (
            table_record.schema_name,
            table_record.table_name,
            v_row_count
        );
    END LOOP;
END
$snapshot_fk_tables$;

-------------------------------------------------------------------------------
-- 7. VÝCHOZÍ SOUHRN
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_delete_baseline
ON COMMIT DROP
AS
SELECT
    (
        SELECT COUNT(*)
        FROM public.matches
    ) AS total_matches,

    (
        SELECT COUNT(*)
        FROM public.matches
        WHERE league_id = 4
          AND btrim(ext_source::text) = 'football_data_uk'
    ) AS belgium_history_matches,

    (
        SELECT COUNT(*)
        FROM public.matches
        WHERE league_id = 20853
          AND btrim(ext_source::text) = 'api_football'
    ) AS belgium_api_matches,

    (
        SELECT COUNT(*)
        FROM public.match_provider_map
    ) AS provider_map_rows,

    (
        SELECT COUNT(DISTINCT match_id)
        FROM public.match_provider_map
    ) AS provider_map_distinct_matches,

    (
        SELECT COUNT(*)
        FROM public.match_features
    ) AS match_features_rows,

    (
        SELECT COUNT(*)
        FROM public.mm_match_ratings
    ) AS match_ratings_rows,

    (
        SELECT COUNT(*)
        FROM public.mm_match_ratings ratings
        LEFT JOIN public.matches match
          ON match.id = ratings.match_id
        WHERE match.id IS NULL
    ) AS match_ratings_orphans;

-------------------------------------------------------------------------------
-- 8. AUDIT DECLAROVANÝCH FK VAZEB NA PŮVODNÍ ZÁPASY
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_fk_reference_audit
(
    schema_name text NOT NULL,
    table_name text NOT NULL,
    fk_column text NOT NULL,
    reference_rows bigint NOT NULL
)
ON COMMIT DROP;

DO $audit_fk_references$
DECLARE
    fk_record record;
    v_reference_rows bigint;
BEGIN
    FOR fk_record IN
        SELECT
            schema_name,
            table_name,
            fk_column
        FROM mm_be_match_fk_catalog
        ORDER BY schema_name, table_name, fk_column
    LOOP
        EXECUTE format(
            $query$
            SELECT COUNT(*)
            FROM %1$I.%2$I child
            JOIN mm_be_delete_plan plan
              ON child.%3$I = plan.previous_match_id
            $query$,
            fk_record.schema_name,
            fk_record.table_name,
            fk_record.fk_column
        )
        INTO v_reference_rows;

        INSERT INTO mm_be_fk_reference_audit
        (
            schema_name,
            table_name,
            fk_column,
            reference_rows
        )
        VALUES
        (
            fk_record.schema_name,
            fk_record.table_name,
            fk_record.fk_column,
            v_reference_rows
        );
    END LOOP;
END
$audit_fk_references$;

-------------------------------------------------------------------------------
-- 9. AUDIT MĚKKÝCH VAZEB BEZ FOREIGN KEY
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_soft_reference_audit
(
    schema_name text NOT NULL,
    table_name text NOT NULL,
    column_name text NOT NULL,
    reference_rows bigint NOT NULL
)
ON COMMIT DROP;

DO $audit_soft_references$
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
              FROM mm_be_match_fk_catalog fk
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
            $query$
            SELECT COUNT(*)
            FROM %1$I.%2$I child
            JOIN mm_be_delete_plan plan
              ON child.%3$I::text =
                 plan.previous_match_id::text
            $query$,
            column_record.schema_name,
            column_record.table_name,
            column_record.column_name
        )
        INTO v_reference_rows;

        INSERT INTO mm_be_soft_reference_audit
        (
            schema_name,
            table_name,
            column_name,
            reference_rows
        )
        VALUES
        (
            column_record.schema_name,
            column_record.table_name,
            column_record.column_name,
            v_reference_rows
        );
    END LOOP;
END
$audit_soft_references$;

-------------------------------------------------------------------------------
-- 10. POVINNÁ KONTROLA PŘED DELETE
-------------------------------------------------------------------------------

DO $precheck$
DECLARE
    v_plan_rows bigint;
    v_previous_ids bigint;
    v_target_ids bigint;

    v_previous_matches bigint;
    v_target_matches bigint;

    v_previous_history_rows bigint;
    v_target_api_rows bigint;

    v_provider_identities_previous bigint;
    v_provider_identities_target bigint;

    v_features_previous bigint;
    v_features_target bigint;

    v_ratings_previous bigint;
    v_ratings_target bigint;

    v_fk_references bigint;
    v_soft_references bigint;

    v_review_cases bigint;
BEGIN
    SELECT
        COUNT(*),
        COUNT(DISTINCT previous_match_id),
        COUNT(DISTINCT target_match_id)
    INTO
        v_plan_rows,
        v_previous_ids,
        v_target_ids
    FROM mm_be_delete_plan;

    SELECT COUNT(*)
    INTO v_previous_matches
    FROM public.matches match
    JOIN mm_be_delete_plan plan
      ON match.id = plan.previous_match_id;

    SELECT COUNT(*)
    INTO v_target_matches
    FROM public.matches match
    JOIN mm_be_delete_plan plan
      ON match.id = plan.target_match_id;

    SELECT COUNT(*)
    INTO v_previous_history_rows
    FROM public.matches match
    JOIN mm_be_delete_plan plan
      ON match.id = plan.previous_match_id
    WHERE match.league_id = 4
      AND btrim(match.ext_source::text) =
          'football_data_uk';

    SELECT COUNT(*)
    INTO v_target_api_rows
    FROM public.matches match
    JOIN mm_be_delete_plan plan
      ON match.id = plan.target_match_id
    WHERE match.league_id = 20853
      AND btrim(match.ext_source::text) =
          'api_football';

    SELECT COUNT(*)
    INTO v_provider_identities_previous
    FROM public.match_provider_map identity
    JOIN mm_be_delete_plan plan
      ON identity.match_id = plan.previous_match_id;

    SELECT COUNT(*)
    INTO v_provider_identities_target
    FROM public.match_provider_map identity
    JOIN mm_be_delete_plan plan
      ON identity.match_id = plan.target_match_id;

    SELECT COUNT(*)
    INTO v_features_previous
    FROM public.match_features features
    JOIN mm_be_delete_plan plan
      ON features.match_id = plan.previous_match_id;

    SELECT COUNT(*)
    INTO v_features_target
    FROM public.match_features features
    JOIN mm_be_delete_plan plan
      ON features.match_id = plan.target_match_id;

    SELECT COUNT(*)
    INTO v_ratings_previous
    FROM public.mm_match_ratings ratings
    JOIN mm_be_delete_plan plan
      ON ratings.match_id = plan.previous_match_id;

    SELECT COUNT(*)
    INTO v_ratings_target
    FROM public.mm_match_ratings ratings
    JOIN mm_be_delete_plan plan
      ON ratings.match_id = plan.target_match_id;

    SELECT COALESCE(SUM(reference_rows), 0)
    INTO v_fk_references
    FROM mm_be_fk_reference_audit;

    SELECT COALESCE(SUM(reference_rows), 0)
    INTO v_soft_references
    FROM mm_be_soft_reference_audit;

    SELECT COUNT(*)
    INTO v_review_cases
    FROM public.matches
    WHERE id IN (
        7545,
        7569,
        6865
    );

    IF v_plan_rows <> 927
       OR v_previous_ids <> 927
       OR v_target_ids <> 927 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: plán %, previous %, target %.',
            v_plan_rows,
            v_previous_ids,
            v_target_ids;
    END IF;

    IF v_previous_matches <> 927
       OR v_target_matches <> 927 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: previous matches %, target matches %.',
            v_previous_matches,
            v_target_matches;
    END IF;

    IF v_previous_history_rows <> 927
       OR v_target_api_rows <> 927 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: history %, API %.',
            v_previous_history_rows,
            v_target_api_rows;
    END IF;

    IF v_provider_identities_previous <> 0 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Na původních zápasech je % providerových identit.',
            v_provider_identities_previous;
    END IF;

    IF v_provider_identities_target <> 1854 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Na cílových zápasech je % identit místo 1854.',
            v_provider_identities_target;
    END IF;

    IF v_features_previous <> 0
       OR v_features_target <> 927 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: features previous %, target %.',
            v_features_previous,
            v_features_target;
    END IF;

    IF v_ratings_previous <> 0
       OR v_ratings_target <> 927 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: ratings previous %, target %.',
            v_ratings_previous,
            v_ratings_target;
    END IF;

    IF v_fk_references <> 0 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Deklarované FK obsahují % vazeb.',
            v_fk_references;
    END IF;

    IF v_soft_references <> 0 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Měkké vazby obsahují % odkazů.',
            v_soft_references;
    END IF;

    IF v_review_cases <> 3 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Případů k revizi existuje % místo 3.',
            v_review_cases;
    END IF;

    RAISE NOTICE
        'OK PRECHECK: plán 927, previous 927, target 927, provider identity previous 0, FK 0, soft references 0, review cases 3.';
END
$precheck$;

-------------------------------------------------------------------------------
-- 11. ZKUŠEBNÍ DELETE 927 HISTORICKÝCH DUPLICIT
-------------------------------------------------------------------------------

DO $simulate_delete$
DECLARE
    v_deleted_rows bigint;
BEGIN
    DELETE FROM public.matches match

    USING mm_be_delete_plan plan

    WHERE match.id = plan.previous_match_id;

    GET DIAGNOSTICS v_deleted_rows = ROW_COUNT;

    IF v_deleted_rows <> 927 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Odstraněno % zápasů místo 927.',
            v_deleted_rows;
    END IF;

    RAISE NOTICE
        'OK DELETE: Zkušebně odstraněno 927 historických duplicit.';
END
$simulate_delete$;

-------------------------------------------------------------------------------
-- 12. KONTROLA, ŽE DELETE NESPUSTIL CASCADE
-------------------------------------------------------------------------------

DO $cascade_check$
DECLARE
    table_record record;
    v_after_count bigint;
BEGIN
    FOR table_record IN
        SELECT
            schema_name,
            table_name,
            row_count
        FROM mm_be_fk_table_counts_before
        ORDER BY schema_name, table_name
    LOOP
        EXECUTE format(
            'SELECT COUNT(*) FROM %I.%I',
            table_record.schema_name,
            table_record.table_name
        )
        INTO v_after_count;

        IF v_after_count <> table_record.row_count THEN
            RAISE EXCEPTION
                'VALIDATION_FAILED: Tabulka %.% změnila počet z % na %.',
                table_record.schema_name,
                table_record.table_name,
                table_record.row_count,
                v_after_count;
        END IF;
    END LOOP;

    RAISE NOTICE
        'OK CASCADE CHECK: Počty všech FK tabulek zůstaly beze změny.';
END
$cascade_check$;

-------------------------------------------------------------------------------
-- 13. ÚPLNÁ KONTROLA PO DELETE
-------------------------------------------------------------------------------

DO $postcheck$
DECLARE
    v_baseline_total_matches bigint;
    v_baseline_provider_rows bigint;
    v_baseline_provider_matches bigint;
    v_baseline_features_rows bigint;
    v_baseline_ratings_rows bigint;
    v_baseline_ratings_orphans bigint;

    v_total_matches bigint;
    v_previous_matches bigint;
    v_target_matches bigint;

    v_history_matches bigint;
    v_api_matches bigint;
    v_review_cases bigint;

    v_provider_rows bigint;
    v_provider_matches bigint;
    v_provider_previous bigint;

    v_features_rows bigint;
    v_features_target bigint;

    v_ratings_rows bigint;
    v_ratings_target bigint;
    v_ratings_orphans bigint;
BEGIN
    SELECT
        total_matches,
        provider_map_rows,
        provider_map_distinct_matches,
        match_features_rows,
        match_ratings_rows,
        match_ratings_orphans
    INTO
        v_baseline_total_matches,
        v_baseline_provider_rows,
        v_baseline_provider_matches,
        v_baseline_features_rows,
        v_baseline_ratings_rows,
        v_baseline_ratings_orphans
    FROM mm_be_delete_baseline;

    SELECT COUNT(*)
    INTO v_total_matches
    FROM public.matches;

    SELECT COUNT(*)
    INTO v_previous_matches
    FROM public.matches match
    JOIN mm_be_delete_plan plan
      ON match.id = plan.previous_match_id;

    SELECT COUNT(*)
    INTO v_target_matches
    FROM public.matches match
    JOIN mm_be_delete_plan plan
      ON match.id = plan.target_match_id;

    SELECT COUNT(*)
    INTO v_history_matches
    FROM public.matches
    WHERE league_id = 4
      AND btrim(ext_source::text) =
          'football_data_uk';

    SELECT COUNT(*)
    INTO v_api_matches
    FROM public.matches
    WHERE league_id = 20853
      AND btrim(ext_source::text) =
          'api_football';

    SELECT COUNT(*)
    INTO v_review_cases
    FROM public.matches
    WHERE id IN (
        7545,
        7569,
        6865
    );

    SELECT
        COUNT(*),
        COUNT(DISTINCT match_id)
    INTO
        v_provider_rows,
        v_provider_matches
    FROM public.match_provider_map;

    SELECT COUNT(*)
    INTO v_provider_previous
    FROM public.match_provider_map identity
    JOIN mm_be_delete_plan plan
      ON identity.match_id = plan.previous_match_id;

    SELECT COUNT(*)
    INTO v_features_rows
    FROM public.match_features;

    SELECT COUNT(*)
    INTO v_features_target
    FROM public.match_features features
    JOIN mm_be_delete_plan plan
      ON features.match_id = plan.target_match_id;

    SELECT COUNT(*)
    INTO v_ratings_rows
    FROM public.mm_match_ratings;

    SELECT COUNT(*)
    INTO v_ratings_target
    FROM public.mm_match_ratings ratings
    JOIN mm_be_delete_plan plan
      ON ratings.match_id = plan.target_match_id;

    SELECT COUNT(*)
    INTO v_ratings_orphans
    FROM public.mm_match_ratings ratings
    LEFT JOIN public.matches match
      ON match.id = ratings.match_id
    WHERE match.id IS NULL;

    IF v_total_matches <>
       v_baseline_total_matches - 927 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Celkový počet zápasů je % místo %.',
            v_total_matches,
            v_baseline_total_matches - 927;
    END IF;

    IF v_previous_matches <> 0
       OR v_target_matches <> 927 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: previous %, target %.',
            v_previous_matches,
            v_target_matches;
    END IF;

    IF v_history_matches <> 1287 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Historických belgických zápasů je % místo 1287.',
            v_history_matches;
    END IF;

    IF v_api_matches <> 960 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: API belgických zápasů je % místo 960.',
            v_api_matches;
    END IF;

    IF v_review_cases <> 3 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Review případy % místo 3.',
            v_review_cases;
    END IF;

    IF v_provider_rows <> v_baseline_provider_rows
       OR v_provider_matches <> v_baseline_provider_matches
       OR v_provider_previous <> 0 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Providerová mapa změnila stav.';
    END IF;

    IF v_features_rows <> v_baseline_features_rows
       OR v_features_target <> 927 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: match_features změnila stav.';
    END IF;

    IF v_ratings_rows <> v_baseline_ratings_rows
       OR v_ratings_target <> 927
       OR v_ratings_orphans <> v_baseline_ratings_orphans THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: mm_match_ratings změnila stav.';
    END IF;

    RAISE NOTICE
        'OK POSTCHECK: previous 0, target 927, history 1287, API 960, review 3, provider mapa a downstream tabulky beze změny.';
END
$postcheck$;

-------------------------------------------------------------------------------
-- 14. SOUHRN PŘED ROLLBACKEM
-------------------------------------------------------------------------------

SELECT
    'MATCHES_TOTAL_AFTER_DELETE' AS check_name,
    COUNT(*)::text AS result
FROM public.matches

UNION ALL

SELECT
    'PREVIOUS_DUPLICATE_MATCHES',
    COUNT(*)::text
FROM public.matches match
JOIN mm_be_delete_plan plan
  ON match.id = plan.previous_match_id

UNION ALL

SELECT
    'TARGET_CANONICAL_MATCHES',
    COUNT(*)::text
FROM public.matches match
JOIN mm_be_delete_plan plan
  ON match.id = plan.target_match_id

UNION ALL

SELECT
    'BELGIUM_HISTORY_REMAINING',
    COUNT(*)::text
FROM public.matches
WHERE league_id = 4
  AND btrim(ext_source::text) =
      'football_data_uk'

UNION ALL

SELECT
    'BELGIUM_API_MATCHES',
    COUNT(*)::text
FROM public.matches
WHERE league_id = 20853
  AND btrim(ext_source::text) =
      'api_football'

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
    'VALIDATE_ONLY_DELETE_OK – 927 HISTORICKÝCH DUPLICIT BEZPEČNĚ ODSTRANĚNO'
        AS validation_status;

-------------------------------------------------------------------------------
-- 15. POVINNÝ ROLLBACK
-------------------------------------------------------------------------------

ROLLBACK;

-------------------------------------------------------------------------------
-- 16. KONTROLA OBNOVENÍ PŮVODNÍHO STAVU
-------------------------------------------------------------------------------

WITH delete_plan AS
(
    SELECT DISTINCT
        (metadata ->> 'previous_match_id')::integer
            AS previous_match_id,

        (metadata ->> 'target_match_id')::integer
            AS target_match_id

    FROM public.match_provider_map

    WHERE metadata ->> 'belgium_identity_transfer'
          = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1'
),
counts AS
(
    SELECT
        (
            SELECT COUNT(*)
            FROM public.matches
        ) AS total_matches,

        (
            SELECT COUNT(*)
            FROM public.matches match
            JOIN delete_plan plan
              ON match.id = plan.previous_match_id
        ) AS previous_matches,

        (
            SELECT COUNT(*)
            FROM public.matches match
            JOIN delete_plan plan
              ON match.id = plan.target_match_id
        ) AS target_matches,

        (
            SELECT COUNT(*)
            FROM public.match_features features
            JOIN delete_plan plan
              ON features.match_id = plan.target_match_id
        ) AS target_features,

        (
            SELECT COUNT(*)
            FROM public.mm_match_ratings ratings
            JOIN delete_plan plan
              ON ratings.match_id = plan.target_match_id
        ) AS target_ratings
)
SELECT
    CASE
        WHEN previous_matches = 927
         AND target_matches = 927
         AND target_features = 927
         AND target_ratings = 927
        THEN
            'ROLLBACK_OK – 927 DUPLICITNÍCH ZÁPASŮ OBNOVENO; DOWNSTREAM PŘEVODY ZACHOVÁNY'
        ELSE
            'ROLLBACK_FAILED – KONTROLNÍ POČTY SE NESHODUJÍ'
    END AS final_status,

    total_matches,
    previous_matches,
    target_matches,
    target_features,
    target_ratings

FROM counts;