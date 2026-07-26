/*
===============================================================================
MATCHMATRIX – BELGIUM JUPILER PRO LEAGUE
REVIEW CASE 2 – CHARLEROI × MECHELEN
DETAIL AUDIT V1
===============================================================================

HISTORICKÝ ZÁPAS:
- match_id: 7569
- football_data_uk
- očekávané skóre: 0:5

KANONICKÝ CÍL:
- match_id: 344421
- api_football
- očekávané skóre: 1:0

ÚČEL:
- Potvrdit přesný rozsah konfliktu.
- Prověřit týmy, čas, stav, providerové identity a downstream vazby.
- Produkční data se nemění.
===============================================================================
*/

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
-- 2. EXISTENCE KONTROLNÍ DVOJICE
-------------------------------------------------------------------------------

DO $case_check$
DECLARE
    v_historical_exists bigint;
    v_target_exists bigint;
BEGIN
    SELECT COUNT(*)
    INTO v_historical_exists
    FROM public.matches
    WHERE id = 7569;

    SELECT COUNT(*)
    INTO v_target_exists
    FROM public.matches
    WHERE id = 344421;

    IF v_historical_exists <> 1 THEN
        RAISE EXCEPTION
            'AUDIT_FAILED: Historický zápas 7569 neexistuje.';
    END IF;

    IF v_target_exists <> 1 THEN
        RAISE EXCEPTION
            'AUDIT_FAILED: Cílový zápas 344421 neexistuje.';
    END IF;

    RAISE NOTICE
        'OK CASE: Zápasy 7569 a 344421 existují.';
END
$case_check$;

-------------------------------------------------------------------------------
-- 3. ZÁKLADNÍ POROVNÁNÍ
-------------------------------------------------------------------------------

SELECT
    CASE
        WHEN match.id = 7569
            THEN 'HISTORICAL_SOURCE'
        WHEN match.id = 344421
            THEN 'API_CANONICAL_TARGET'
    END AS match_role,

    match.id,
    match.league_id,
    match.season,
    match.kickoff,
    match.home_team_id,
    match.away_team_id,
    match.home_score,
    match.away_score,
    match.status,
    match.ext_source,
    match.ext_match_id,
    match.updated_at

FROM public.matches match

WHERE match.id IN (
    7569,
    344421
)

ORDER BY match.id;

-------------------------------------------------------------------------------
-- 4. ROZDÍLY VE VŠECH SLOUPCÍCH public.matches
-------------------------------------------------------------------------------

WITH historical_row AS
(
    SELECT to_jsonb(match) AS row_data
    FROM public.matches match
    WHERE match.id = 7569
),
target_row AS
(
    SELECT to_jsonb(match) AS row_data
    FROM public.matches match
    WHERE match.id = 344421
),
historical_values AS
(
    SELECT
        entry.key,
        entry.value
    FROM historical_row,
         LATERAL jsonb_each(historical_row.row_data) entry
),
target_values AS
(
    SELECT
        entry.key,
        entry.value
    FROM target_row,
         LATERAL jsonb_each(target_row.row_data) entry
)
SELECT
    COALESCE(
        historical_values.key,
        target_values.key
    ) AS column_name,

    historical_values.value AS historical_value,
    target_values.value AS target_value

FROM historical_values

FULL OUTER JOIN target_values
  ON target_values.key = historical_values.key

WHERE historical_values.value
      IS DISTINCT FROM target_values.value

ORDER BY column_name;

-------------------------------------------------------------------------------
-- 5. DOTČENÉ TÝMY
-------------------------------------------------------------------------------

WITH team_ids AS
(
    SELECT home_team_id AS team_id
    FROM public.matches
    WHERE id IN (7569, 344421)

    UNION

    SELECT away_team_id
    FROM public.matches
    WHERE id IN (7569, 344421)
)
SELECT
    team.id AS team_id,
    team.name,
    team.sport_id,
    team.ext_source,
    team.ext_team_id,
    team.logo_url

FROM public.teams team

JOIN team_ids
  ON team_ids.team_id = team.id

ORDER BY team.id;

-------------------------------------------------------------------------------
-- 6. PROVIDEROVÉ IDENTITY
-------------------------------------------------------------------------------

SELECT
    identity.id AS mapping_id,
    identity.match_id,
    identity.provider,
    identity.provider_match_id,
    identity.identity_origin,
    identity.external_id_kind,
    identity.mapping_status,
    identity.is_primary,
    identity.confidence_score,
    identity.metadata

FROM public.match_provider_map identity

WHERE identity.match_id IN (
    7569,
    344421
)

ORDER BY
    identity.match_id,
    identity.is_primary DESC,
    identity.provider;

-------------------------------------------------------------------------------
-- 7. KATALOG FOREIGN KEY VAZEB NA public.matches(id)
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_case2_fk_catalog
ON COMMIT DROP
AS
SELECT
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
  AND constraint_object.confrelid = 'public.matches'::regclass
  AND array_length(constraint_object.conkey, 1) = 1
  AND array_length(constraint_object.confkey, 1) = 1
  AND parent_column.attname = 'id';

-------------------------------------------------------------------------------
-- 8. AUDIT FOREIGN KEY VAZEB
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_case2_fk_audit
(
    schema_name text NOT NULL,
    table_name text NOT NULL,
    fk_column text NOT NULL,
    constraint_name text NOT NULL,
    historical_reference_rows bigint NOT NULL,
    target_reference_rows bigint NOT NULL,
    constraint_definition text NOT NULL
)
ON COMMIT DROP;

DO $audit_fk$
DECLARE
    fk_record record;
    v_historical_rows bigint;
    v_target_rows bigint;
BEGIN
    FOR fk_record IN
        SELECT *
        FROM mm_be_case2_fk_catalog
        ORDER BY schema_name, table_name, fk_column
    LOOP
        EXECUTE format(
            'SELECT COUNT(*) FROM %I.%I WHERE %I = $1',
            fk_record.schema_name,
            fk_record.table_name,
            fk_record.fk_column
        )
        INTO v_historical_rows
        USING 7569;

        EXECUTE format(
            'SELECT COUNT(*) FROM %I.%I WHERE %I = $1',
            fk_record.schema_name,
            fk_record.table_name,
            fk_record.fk_column
        )
        INTO v_target_rows
        USING 344421;

        INSERT INTO mm_be_case2_fk_audit
        (
            schema_name,
            table_name,
            fk_column,
            constraint_name,
            historical_reference_rows,
            target_reference_rows,
            constraint_definition
        )
        VALUES
        (
            fk_record.schema_name,
            fk_record.table_name,
            fk_record.fk_column,
            fk_record.constraint_name,
            v_historical_rows,
            v_target_rows,
            fk_record.constraint_definition
        );
    END LOOP;
END
$audit_fk$;

SELECT
    schema_name,
    table_name,
    fk_column,
    constraint_name,
    historical_reference_rows,
    target_reference_rows,
    constraint_definition

FROM mm_be_case2_fk_audit

WHERE historical_reference_rows > 0
   OR target_reference_rows > 0

ORDER BY
    historical_reference_rows DESC,
    target_reference_rows DESC,
    schema_name,
    table_name;

-------------------------------------------------------------------------------
-- 9. AUDIT MĚKKÝCH VAZEB BEZ FK
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_case2_soft_audit
(
    schema_name text NOT NULL,
    table_name text NOT NULL,
    column_name text NOT NULL,
    historical_reference_rows bigint NOT NULL,
    target_reference_rows bigint NOT NULL
)
ON COMMIT DROP;

DO $audit_soft$
DECLARE
    column_record record;
    v_historical_rows bigint;
    v_target_rows bigint;
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
              FROM mm_be_case2_fk_catalog fk
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
        INTO v_historical_rows
        USING '7569';

        EXECUTE format(
            'SELECT COUNT(*) FROM %I.%I WHERE %I::text = $1',
            column_record.schema_name,
            column_record.table_name,
            column_record.column_name
        )
        INTO v_target_rows
        USING '344421';

        IF v_historical_rows > 0
           OR v_target_rows > 0 THEN

            INSERT INTO mm_be_case2_soft_audit
            (
                schema_name,
                table_name,
                column_name,
                historical_reference_rows,
                target_reference_rows
            )
            VALUES
            (
                column_record.schema_name,
                column_record.table_name,
                column_record.column_name,
                v_historical_rows,
                v_target_rows
            );
        END IF;
    END LOOP;
END
$audit_soft$;

SELECT
    schema_name,
    table_name,
    column_name,
    historical_reference_rows,
    target_reference_rows

FROM mm_be_case2_soft_audit

ORDER BY
    historical_reference_rows DESC,
    target_reference_rows DESC,
    schema_name,
    table_name;

-------------------------------------------------------------------------------
-- 10. DETAIL match_features A mm_match_ratings
-------------------------------------------------------------------------------

SELECT
    'public.match_features' AS table_name,
    features.match_id,
    to_jsonb(features) AS row_data

FROM public.match_features features

WHERE features.match_id IN (
    7569,
    344421
)

UNION ALL

SELECT
    'public.mm_match_ratings',
    ratings.match_id,
    to_jsonb(ratings)

FROM public.mm_match_ratings ratings

WHERE ratings.match_id IN (
    7569,
    344421
)

ORDER BY
    table_name,
    match_id;

-------------------------------------------------------------------------------
-- 11. SOUHRN VAZEB
-------------------------------------------------------------------------------

SELECT
    'DECLARED_FK_HISTORICAL_REFERENCES' AS check_name,
    COALESCE(
        SUM(historical_reference_rows),
        0
    )::text AS result
FROM mm_be_case2_fk_audit

UNION ALL

SELECT
    'DECLARED_FK_TARGET_REFERENCES',
    COALESCE(
        SUM(target_reference_rows),
        0
    )::text
FROM mm_be_case2_fk_audit

UNION ALL

SELECT
    'SOFT_HISTORICAL_REFERENCES',
    COALESCE(
        SUM(historical_reference_rows),
        0
    )::text
FROM mm_be_case2_soft_audit

UNION ALL

SELECT
    'SOFT_TARGET_REFERENCES',
    COALESCE(
        SUM(target_reference_rows),
        0
    )::text
FROM mm_be_case2_soft_audit;

-------------------------------------------------------------------------------
-- 12. KONEČNÝ STAV AUDITU
-------------------------------------------------------------------------------

WITH case_data AS
(
    SELECT
        historical.home_score AS historical_home_score,
        historical.away_score AS historical_away_score,
        historical.status AS historical_status,

        target.home_score AS target_home_score,
        target.away_score AS target_away_score,
        target.status AS target_status,

        historical.kickoff::date AS historical_match_day,
        target.kickoff::date AS target_match_day

    FROM public.matches historical

    CROSS JOIN public.matches target

    WHERE historical.id = 7569
      AND target.id = 344421
),
identity_data AS
(
    SELECT
        COUNT(*) FILTER (
            WHERE match_id = 7569
              AND provider = 'football_data_uk'
        ) AS historical_identity_count,

        COUNT(*) FILTER (
            WHERE match_id = 344421
              AND provider = 'api_football'
        ) AS target_identity_count

    FROM public.match_provider_map
)
SELECT
    case_data.historical_home_score,
    case_data.historical_away_score,
    case_data.historical_status,

    case_data.target_home_score,
    case_data.target_away_score,
    case_data.target_status,

    case_data.historical_match_day,
    case_data.target_match_day,

    identity_data.historical_identity_count,
    identity_data.target_identity_count,

    CASE
        WHEN case_data.historical_home_score = 0
         AND case_data.historical_away_score = 5
         AND case_data.target_home_score = 1
         AND case_data.target_away_score = 0
         AND case_data.historical_match_day =
             case_data.target_match_day
         AND identity_data.historical_identity_count = 1
         AND identity_data.target_identity_count = 1
        THEN
            'REVIEW_CASE_2_SCORE_CONFLICT_CONFIRMED – NUTNÉ OVĚŘIT OFICIÁLNÍ VÝSLEDEK'

        ELSE
            'REVIEW_CASE_2_REQUIRES_MANUAL_ANALYSIS – KONTROLNÍ DATA SE NESHODUJÍ'
    END AS audit_status

FROM case_data
CROSS JOIN identity_data;

ROLLBACK;