/*
===============================================================================
MATCHMATRIX – BELGIUM JUPILER PRO LEAGUE
READ ONLY – DOWNSTREAM TABLE DETAIL AUDIT V1
===============================================================================

CO:
- Detailně prověří:
    public.match_features
    public.mm_match_ratings

K ČEMU:
- Ověření přesné struktury před VALIDATE ONLY převodem 927 vazeb.
- Kontrola datových typů, klíčů, indexů, triggerů a možných kolizí.

BEZPEČNOST:
- Produkční data se nemění.
- Používají se pouze dočasné tabulky.
- Transakce končí ROLLBACK.
===============================================================================
*/

ROLLBACK;

BEGIN ISOLATION LEVEL REPEATABLE READ;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '180s';
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
    clock_timestamp() AS audit_started_at;

-------------------------------------------------------------------------------
-- 2. OBNOVENÍ 927 MIGRAČNÍCH DVOJIC
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_transfer_plan
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

DO $plan_check$
DECLARE
    v_rows bigint;
    v_previous bigint;
    v_target bigint;
BEGIN
    SELECT
        COUNT(*),
        COUNT(DISTINCT previous_match_id),
        COUNT(DISTINCT target_match_id)
    INTO
        v_rows,
        v_previous,
        v_target
    FROM mm_be_transfer_plan;

    IF v_rows <> 927
       OR v_previous <> 927
       OR v_target <> 927 THEN
        RAISE EXCEPTION
            'AUDIT_FAILED: plán %, previous %, target %.',
            v_rows,
            v_previous,
            v_target;
    END IF;

    RAISE NOTICE
        'OK PLAN: 927 unikátních migračních dvojic.';
END
$plan_check$;

-------------------------------------------------------------------------------
-- 3. SLOUPCE OBOU TABULEK
-------------------------------------------------------------------------------

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type,
    udt_name,
    is_nullable,
    column_default

FROM information_schema.columns

WHERE table_schema = 'public'
  AND table_name IN (
      'match_features',
      'mm_match_ratings'
  )

ORDER BY
    table_name,
    ordinal_position;

-------------------------------------------------------------------------------
-- 4. CONSTRAINTS
-------------------------------------------------------------------------------

SELECT
    namespace_object.nspname AS schema_name,
    table_object.relname AS table_name,
    constraint_object.conname AS constraint_name,

    CASE constraint_object.contype
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'f' THEN 'FOREIGN KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 'c' THEN 'CHECK'
        WHEN 'x' THEN 'EXCLUSION'
        ELSE constraint_object.contype::text
    END AS constraint_type,

    pg_get_constraintdef(
        constraint_object.oid,
        true
    ) AS constraint_definition

FROM pg_constraint constraint_object

JOIN pg_class table_object
  ON table_object.oid = constraint_object.conrelid

JOIN pg_namespace namespace_object
  ON namespace_object.oid = table_object.relnamespace

WHERE namespace_object.nspname = 'public'
  AND table_object.relname IN (
      'match_features',
      'mm_match_ratings'
  )

ORDER BY
    table_object.relname,
    constraint_type,
    constraint_object.conname;

-------------------------------------------------------------------------------
-- 5. INDEXY
-------------------------------------------------------------------------------

SELECT
    schemaname,
    tablename,
    indexname,
    indexdef

FROM pg_indexes

WHERE schemaname = 'public'
  AND tablename IN (
      'match_features',
      'mm_match_ratings'
  )

ORDER BY
    tablename,
    indexname;

-------------------------------------------------------------------------------
-- 6. TRIGGERY
-------------------------------------------------------------------------------

SELECT
    namespace_object.nspname AS schema_name,
    table_object.relname AS table_name,
    trigger_object.tgname AS trigger_name,

    pg_get_triggerdef(
        trigger_object.oid,
        true
    ) AS trigger_definition

FROM pg_trigger trigger_object

JOIN pg_class table_object
  ON table_object.oid = trigger_object.tgrelid

JOIN pg_namespace namespace_object
  ON namespace_object.oid = table_object.relnamespace

WHERE namespace_object.nspname = 'public'
  AND table_object.relname IN (
      'match_features',
      'mm_match_ratings'
  )
  AND NOT trigger_object.tgisinternal

ORDER BY
    table_object.relname,
    trigger_object.tgname;

-------------------------------------------------------------------------------
-- 7. ZÁKLADNÍ POČTY OBOU TABULEK
-------------------------------------------------------------------------------

SELECT
    'public.match_features' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE match_id IS NULL
    ) AS null_match_ids,
    COUNT(DISTINCT match_id) AS distinct_match_ids
FROM public.match_features

UNION ALL

SELECT
    'public.mm_match_ratings',
    COUNT(*),
    COUNT(*) FILTER (
        WHERE match_id IS NULL
    ),
    COUNT(DISTINCT match_id)
FROM public.mm_match_ratings;

-------------------------------------------------------------------------------
-- 8. BELGICKÉ VAZBY – PŮVODNÍ A CÍLOVÉ ZÁPASY
-------------------------------------------------------------------------------

SELECT
    'public.match_features' AS table_name,

    COUNT(*) FILTER (
        WHERE plan.previous_match_id IS NOT NULL
    ) AS previous_reference_rows,

    COUNT(DISTINCT features.match_id) FILTER (
        WHERE plan.previous_match_id IS NOT NULL
    ) AS previous_distinct_matches,

    COUNT(*) FILTER (
        WHERE target_plan.target_match_id IS NOT NULL
    ) AS target_reference_rows,

    COUNT(DISTINCT features.match_id) FILTER (
        WHERE target_plan.target_match_id IS NOT NULL
    ) AS target_distinct_matches

FROM public.match_features features

LEFT JOIN mm_be_transfer_plan plan
  ON features.match_id = plan.previous_match_id

LEFT JOIN mm_be_transfer_plan target_plan
  ON features.match_id = target_plan.target_match_id

UNION ALL

SELECT
    'public.mm_match_ratings',

    COUNT(*) FILTER (
        WHERE plan.previous_match_id IS NOT NULL
    ),

    COUNT(DISTINCT ratings.match_id) FILTER (
        WHERE plan.previous_match_id IS NOT NULL
    ),

    COUNT(*) FILTER (
        WHERE target_plan.target_match_id IS NOT NULL
    ),

    COUNT(DISTINCT ratings.match_id) FILTER (
        WHERE target_plan.target_match_id IS NOT NULL
    )

FROM public.mm_match_ratings ratings

LEFT JOIN mm_be_transfer_plan plan
  ON ratings.match_id = plan.previous_match_id

LEFT JOIN mm_be_transfer_plan target_plan
  ON ratings.match_id = target_plan.target_match_id;

-------------------------------------------------------------------------------
-- 9. VÍCE ŘÁDKŮ PRO JEDEN MATCH_ID
-------------------------------------------------------------------------------

SELECT
    'public.match_features' AS table_name,
    COUNT(*) AS duplicate_match_id_groups,
    COALESCE(SUM(row_count), 0) AS rows_in_duplicate_groups

FROM
(
    SELECT
        match_id,
        COUNT(*) AS row_count
    FROM public.match_features
    GROUP BY match_id
    HAVING COUNT(*) > 1
) duplicates

UNION ALL

SELECT
    'public.mm_match_ratings',
    COUNT(*),
    COALESCE(SUM(row_count), 0)

FROM
(
    SELECT
        match_id,
        COUNT(*) AS row_count
    FROM public.mm_match_ratings
    GROUP BY match_id
    HAVING COUNT(*) > 1
) duplicates;

-------------------------------------------------------------------------------
-- 10. KOLIZE PŮVODNÍHO A CÍLOVÉHO MATCH_ID
--
-- Výsledek musí být 0 pro obě tabulky.
-------------------------------------------------------------------------------

SELECT
    'public.match_features' AS table_name,
    COUNT(*) AS pairs_with_both_previous_and_target_rows

FROM mm_be_transfer_plan plan

WHERE EXISTS
(
    SELECT 1
    FROM public.match_features previous_row
    WHERE previous_row.match_id = plan.previous_match_id
)
AND EXISTS
(
    SELECT 1
    FROM public.match_features target_row
    WHERE target_row.match_id = plan.target_match_id
)

UNION ALL

SELECT
    'public.mm_match_ratings',
    COUNT(*)

FROM mm_be_transfer_plan plan

WHERE EXISTS
(
    SELECT 1
    FROM public.mm_match_ratings previous_row
    WHERE previous_row.match_id = plan.previous_match_id
)
AND EXISTS
(
    SELECT 1
    FROM public.mm_match_ratings target_row
    WHERE target_row.match_id = plan.target_match_id
);

-------------------------------------------------------------------------------
-- 11. OSIŘELÉ MATCH_ID V OBOU TABULKÁCH
-------------------------------------------------------------------------------

SELECT
    'public.match_features' AS table_name,
    COUNT(*) AS orphan_rows

FROM public.match_features child

LEFT JOIN public.matches parent
  ON parent.id = child.match_id

WHERE parent.id IS NULL

UNION ALL

SELECT
    'public.mm_match_ratings',
    COUNT(*)

FROM public.mm_match_ratings child

LEFT JOIN public.matches parent
  ON parent.id = child.match_id

WHERE parent.id IS NULL;

-------------------------------------------------------------------------------
-- 12. KONTROLNÍ VZOREK 20 DVOJIC
-------------------------------------------------------------------------------

SELECT
    plan.previous_match_id,
    plan.target_match_id,

    EXISTS
    (
        SELECT 1
        FROM public.match_features features
        WHERE features.match_id = plan.previous_match_id
    ) AS match_features_previous,

    EXISTS
    (
        SELECT 1
        FROM public.match_features features
        WHERE features.match_id = plan.target_match_id
    ) AS match_features_target,

    EXISTS
    (
        SELECT 1
        FROM public.mm_match_ratings ratings
        WHERE ratings.match_id = plan.previous_match_id
    ) AS ratings_previous,

    EXISTS
    (
        SELECT 1
        FROM public.mm_match_ratings ratings
        WHERE ratings.match_id = plan.target_match_id
    ) AS ratings_target

FROM mm_be_transfer_plan plan

ORDER BY plan.previous_match_id

LIMIT 20;

-------------------------------------------------------------------------------
-- 13. SOUHRN PŘIPRAVENOSTI
-------------------------------------------------------------------------------

WITH checks AS
(
    SELECT
        (
            SELECT COUNT(*)
            FROM public.match_features features
            JOIN mm_be_transfer_plan plan
              ON plan.previous_match_id = features.match_id
        ) AS features_previous,

        (
            SELECT COUNT(*)
            FROM public.match_features features
            JOIN mm_be_transfer_plan plan
              ON plan.target_match_id = features.match_id
        ) AS features_target,

        (
            SELECT COUNT(*)
            FROM public.mm_match_ratings ratings
            JOIN mm_be_transfer_plan plan
              ON plan.previous_match_id = ratings.match_id
        ) AS ratings_previous,

        (
            SELECT COUNT(*)
            FROM public.mm_match_ratings ratings
            JOIN mm_be_transfer_plan plan
              ON plan.target_match_id = ratings.match_id
        ) AS ratings_target
)
SELECT
    features_previous,
    features_target,
    ratings_previous,
    ratings_target,

    CASE
        WHEN features_previous = 927
         AND features_target = 0
         AND ratings_previous = 927
         AND ratings_target = 0
        THEN
            'DETAIL_AUDIT_OK – OBOUSTRANNÝ PŘEVOD 927 VAZEB JE DATOVĚ PŘIPRAVEN'

        ELSE
            'DETAIL_AUDIT_REVIEW_REQUIRED – KONTROLNÍ POČTY SE NESHODUJÍ'
    END AS audit_status

FROM checks;

ROLLBACK;