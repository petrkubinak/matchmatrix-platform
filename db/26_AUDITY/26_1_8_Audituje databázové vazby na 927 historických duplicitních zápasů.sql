/*
===============================================================================
MATCHMATRIX – BELGIUM JUPILER PRO LEAGUE
READ ONLY – DOWNSTREAM MATCH REFERENCE AUDIT V1
===============================================================================

CO:
- Audituje databázové vazby na 927 historických duplicitních zápasů.
- Zjišťuje, které downstream tabulky bude nutné převést na kanonické zápasy.

ZDROJ MIGRAČNÍHO PLÁNU:
- public.match_provider_map.metadata.previous_match_id
- public.match_provider_map.metadata.target_match_id
- belgium_identity_transfer = BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1

BEZPEČNOST:
- READ ONLY nad trvalými objekty.
- Používají se pouze dočasné tabulky.
- Žádné produkční INSERT, UPDATE, DELETE ani DDL.
- Na konci proběhne ROLLBACK.
===============================================================================
*/

ROLLBACK;

BEGIN ISOLATION LEVEL REPEATABLE READ;

SET LOCAL lock_timeout = '5s';
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
    clock_timestamp() AS audit_started_at;

-------------------------------------------------------------------------------
-- 2. POVINNÉ OBJEKTY
-------------------------------------------------------------------------------

DO $objects$
BEGIN
    IF to_regclass('public.matches') IS NULL THEN
        RAISE EXCEPTION
            'AUDIT_FAILED: public.matches neexistuje.';
    END IF;

    IF to_regclass('public.match_provider_map') IS NULL THEN
        RAISE EXCEPTION
            'AUDIT_FAILED: public.match_provider_map neexistuje.';
    END IF;

    RAISE NOTICE
        'OK OBJECTS: Povinné tabulky existují.';
END
$objects$;

-------------------------------------------------------------------------------
-- 3. OBNOVENÍ MIGRAČNÍHO PLÁNU Z ULOŽENÝCH METADAT
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_transfer_plan
ON COMMIT DROP
AS
SELECT
    id AS mapping_id,

    (metadata ->> 'previous_match_id')::integer
        AS previous_match_id,

    (metadata ->> 'target_match_id')::integer
        AS target_match_id,

    match_id AS current_match_id,

    provider,
    provider_match_id,
    is_primary,
    mapping_status

FROM public.match_provider_map

WHERE metadata ->> 'belgium_identity_transfer'
      = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1';

CREATE UNIQUE INDEX mm_be_transfer_plan_previous_uq
    ON mm_be_transfer_plan(previous_match_id);

CREATE UNIQUE INDEX mm_be_transfer_plan_target_uq
    ON mm_be_transfer_plan(target_match_id);

-------------------------------------------------------------------------------
-- 4. KONTROLA MIGRAČNÍHO PLÁNU
-------------------------------------------------------------------------------

DO $plan_check$
DECLARE
    v_rows bigint;
    v_previous_ids bigint;
    v_target_ids bigint;
    v_current_matches_ok bigint;
    v_previous_matches_exist bigint;
    v_target_matches_exist bigint;
    v_invalid_same_id bigint;
BEGIN
    SELECT
        COUNT(*),
        COUNT(DISTINCT previous_match_id),
        COUNT(DISTINCT target_match_id),

        COUNT(*) FILTER (
            WHERE current_match_id = target_match_id
        ),

        COUNT(*) FILTER (
            WHERE previous_match_id = target_match_id
        )
    INTO
        v_rows,
        v_previous_ids,
        v_target_ids,
        v_current_matches_ok,
        v_invalid_same_id
    FROM mm_be_transfer_plan;

    SELECT COUNT(*)
    INTO v_previous_matches_exist
    FROM mm_be_transfer_plan plan
    JOIN public.matches match
      ON match.id = plan.previous_match_id;

    SELECT COUNT(*)
    INTO v_target_matches_exist
    FROM mm_be_transfer_plan plan
    JOIN public.matches match
      ON match.id = plan.target_match_id;

    IF v_rows <> 927 THEN
        RAISE EXCEPTION
            'AUDIT_FAILED: Migrační plán obsahuje % řádků místo 927.',
            v_rows;
    END IF;

    IF v_previous_ids <> 927 OR v_target_ids <> 927 THEN
        RAISE EXCEPTION
            'AUDIT_FAILED: Neunikátní dvojice – previous %, target %.',
            v_previous_ids,
            v_target_ids;
    END IF;

    IF v_current_matches_ok <> 927 THEN
        RAISE EXCEPTION
            'AUDIT_FAILED: Pouze % identit ukazuje na cílový zápas.',
            v_current_matches_ok;
    END IF;

    IF v_previous_matches_exist <> 927
       OR v_target_matches_exist <> 927 THEN
        RAISE EXCEPTION
            'AUDIT_FAILED: Existující previous %, target %.',
            v_previous_matches_exist,
            v_target_matches_exist;
    END IF;

    IF v_invalid_same_id <> 0 THEN
        RAISE EXCEPTION
            'AUDIT_FAILED: % párů má stejné původní a cílové ID.',
            v_invalid_same_id;
    END IF;

    RAISE NOTICE
        'OK PLAN: 927 unikátních dvojic, všechny zápasy existují a identity ukazují na cíle.';
END
$plan_check$;

-------------------------------------------------------------------------------
-- 5. KONTROLA PROVIDEROVÉ MAPY PO PŘEVODU
-------------------------------------------------------------------------------

SELECT
    COUNT(*) AS transferred_rows,

    COUNT(DISTINCT previous_match_id)
        AS distinct_previous_matches,

    COUNT(DISTINCT target_match_id)
        AS distinct_target_matches

FROM mm_be_transfer_plan;

SELECT
    COUNT(*) FILTER (
        WHERE identity.match_id = plan.previous_match_id
    ) AS identities_still_on_previous_matches,

    COUNT(*) FILTER (
        WHERE identity.match_id = plan.target_match_id
    ) AS identities_on_target_matches

FROM mm_be_transfer_plan plan

JOIN public.match_provider_map identity
  ON identity.match_id IN (
      plan.previous_match_id,
      plan.target_match_id
  );

-------------------------------------------------------------------------------
-- 6. SEZNAM DECLAROVANÝCH CIZÍCH KLÍČŮ NA public.matches(id)
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_match_fk_catalog
ON COMMIT DROP
AS
SELECT
    constraint_object.oid AS constraint_oid,
    constraint_object.conname AS constraint_name,

    child_namespace.nspname AS schema_name,
    child_table.relname AS table_name,
    child_column.attname AS fk_column,

    constraint_object.conrelid AS table_oid,
    child_column.attnum AS fk_attnum,

    constraint_object.confupdtype AS update_action_code,
    constraint_object.confdeltype AS delete_action_code,

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

  AND constraint_object.confrelid
      = 'public.matches'::regclass

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
-- 7. KONTROLA PŘÍPADNÝCH KOMPOZITNÍCH FK
-------------------------------------------------------------------------------

SELECT
    constraint_object.conname AS constraint_name,
    child_namespace.nspname AS schema_name,
    child_table.relname AS table_name,
    pg_get_constraintdef(
        constraint_object.oid,
        true
    ) AS constraint_definition

FROM pg_constraint constraint_object

JOIN pg_class child_table
  ON child_table.oid = constraint_object.conrelid

JOIN pg_namespace child_namespace
  ON child_namespace.oid = child_table.relnamespace

WHERE constraint_object.contype = 'f'

  AND constraint_object.confrelid
      = 'public.matches'::regclass

  AND (
      array_length(constraint_object.conkey, 1) <> 1
      OR array_length(constraint_object.confkey, 1) <> 1
  )

ORDER BY
    child_namespace.nspname,
    child_table.relname,
    constraint_object.conname;

-------------------------------------------------------------------------------
-- 8. DYNAMICKÝ AUDIT VŠECH FK TABULEK
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_downstream_fk_audit
(
    schema_name text NOT NULL,
    table_name text NOT NULL,
    fk_column text NOT NULL,
    constraint_name text NOT NULL,

    previous_reference_rows bigint NOT NULL,
    previous_distinct_matches bigint NOT NULL,

    target_reference_rows bigint NOT NULL,
    target_distinct_matches bigint NOT NULL,

    constraint_definition text NOT NULL
)
ON COMMIT DROP;

DO $audit_fk_tables$
DECLARE
    relation_record record;

    v_previous_rows bigint;
    v_previous_matches bigint;

    v_target_rows bigint;
    v_target_matches bigint;
BEGIN
    FOR relation_record IN
        SELECT *
        FROM mm_match_fk_catalog
        WHERE NOT (
            schema_name = 'public'
            AND table_name = 'match_provider_map'
        )
        ORDER BY
            schema_name,
            table_name,
            fk_column
    LOOP
        EXECUTE format(
            $query$
            SELECT
                COUNT(*),
                COUNT(DISTINCT child.%1$I)
            FROM %2$I.%3$I child
            JOIN mm_be_transfer_plan plan
              ON child.%1$I = plan.previous_match_id
            $query$,
            relation_record.fk_column,
            relation_record.schema_name,
            relation_record.table_name
        )
        INTO
            v_previous_rows,
            v_previous_matches;

        EXECUTE format(
            $query$
            SELECT
                COUNT(*),
                COUNT(DISTINCT child.%1$I)
            FROM %2$I.%3$I child
            JOIN mm_be_transfer_plan plan
              ON child.%1$I = plan.target_match_id
            $query$,
            relation_record.fk_column,
            relation_record.schema_name,
            relation_record.table_name
        )
        INTO
            v_target_rows,
            v_target_matches;

        INSERT INTO mm_be_downstream_fk_audit
        (
            schema_name,
            table_name,
            fk_column,
            constraint_name,

            previous_reference_rows,
            previous_distinct_matches,

            target_reference_rows,
            target_distinct_matches,

            constraint_definition
        )
        VALUES
        (
            relation_record.schema_name,
            relation_record.table_name,
            relation_record.fk_column,
            relation_record.constraint_name,

            v_previous_rows,
            v_previous_matches,

            v_target_rows,
            v_target_matches,

            relation_record.constraint_definition
        );
    END LOOP;
END
$audit_fk_tables$;

-------------------------------------------------------------------------------
-- 9. VÝSLEDKY FK AUDITU
-------------------------------------------------------------------------------

SELECT
    schema_name,
    table_name,
    fk_column,
    constraint_name,

    previous_reference_rows,
    previous_distinct_matches,

    target_reference_rows,
    target_distinct_matches,

    constraint_definition

FROM mm_be_downstream_fk_audit

ORDER BY
    previous_reference_rows DESC,
    schema_name,
    table_name,
    fk_column;

-------------------------------------------------------------------------------
-- 10. SOUHRN FK VAZEB
-------------------------------------------------------------------------------

SELECT
    COUNT(*) AS discovered_fk_constraints,

    COUNT(*) FILTER (
        WHERE previous_reference_rows > 0
    ) AS fk_constraints_with_previous_references,

    COALESCE(
        SUM(previous_reference_rows),
        0
    ) AS total_previous_reference_rows,

    COALESCE(
        SUM(target_reference_rows),
        0
    ) AS total_target_reference_rows

FROM mm_be_downstream_fk_audit;

-------------------------------------------------------------------------------
-- 11. TABULKY SKUTEČNĚ VYŽADUJÍCÍ DALŠÍ MIGRACI
-------------------------------------------------------------------------------

SELECT
    schema_name,
    table_name,
    fk_column,

    previous_reference_rows,
    previous_distinct_matches,

    target_reference_rows,
    target_distinct_matches

FROM mm_be_downstream_fk_audit

WHERE previous_reference_rows > 0

ORDER BY
    previous_reference_rows DESC,
    schema_name,
    table_name;

-------------------------------------------------------------------------------
-- 12. UNIKÁTNÍ INDEXY DOTÝKAJÍCÍ SE MATCH FK SLOUPCŮ
--
-- Tyto indexy mohou při prostém UPDATE původního match_id na cílové match_id
-- způsobit kolizi s již existujícím řádkem cílového zápasu.
-------------------------------------------------------------------------------

SELECT DISTINCT
    fk.schema_name,
    fk.table_name,
    fk.fk_column,

    index_object.relname AS unique_index_name,

    pg_get_indexdef(
        index_definition.indexrelid
    ) AS unique_index_definition

FROM mm_match_fk_catalog fk

JOIN pg_index index_definition
  ON index_definition.indrelid = fk.table_oid
 AND index_definition.indisunique = true
 AND fk.fk_attnum = ANY(index_definition.indkey)

JOIN pg_class index_object
  ON index_object.oid = index_definition.indexrelid

WHERE NOT (
    fk.schema_name = 'public'
    AND fk.table_name = 'match_provider_map'
)

ORDER BY
    fk.schema_name,
    fk.table_name,
    fk.fk_column,
    index_object.relname;

-------------------------------------------------------------------------------
-- 13. MOŽNÉ MĚKKÉ VAZBY BEZ FOREIGN KEY
--
-- Jde pouze o kandidáty podle názvu sloupce.
-- Výsledek ještě neznamená, že jde skutečně o kanonické match_id.
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_soft_reference_audit
(
    schema_name text NOT NULL,
    table_name text NOT NULL,
    column_name text NOT NULL,

    previous_reference_rows bigint NOT NULL,
    previous_distinct_matches bigint NOT NULL,

    target_reference_rows bigint NOT NULL,
    target_distinct_matches bigint NOT NULL
)
ON COMMIT DROP;

DO $audit_soft_references$
DECLARE
    column_record record;

    v_previous_rows bigint;
    v_previous_matches bigint;

    v_target_rows bigint;
    v_target_matches bigint;
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
              FROM mm_match_fk_catalog fk
              WHERE fk.schema_name
                    = namespace_object.nspname
                AND fk.table_name
                    = table_object.relname
                AND fk.fk_column
                    = column_object.attname
          )

        ORDER BY
            namespace_object.nspname,
            table_object.relname,
            column_object.attname
    LOOP
        EXECUTE format(
            $query$
            SELECT
                COUNT(*),
                COUNT(DISTINCT child.%1$I)
            FROM %2$I.%3$I child
            JOIN mm_be_transfer_plan plan
              ON child.%1$I::text
                 = plan.previous_match_id::text
            $query$,
            column_record.column_name,
            column_record.schema_name,
            column_record.table_name
        )
        INTO
            v_previous_rows,
            v_previous_matches;

        EXECUTE format(
            $query$
            SELECT
                COUNT(*),
                COUNT(DISTINCT child.%1$I)
            FROM %2$I.%3$I child
            JOIN mm_be_transfer_plan plan
              ON child.%1$I::text
                 = plan.target_match_id::text
            $query$,
            column_record.column_name,
            column_record.schema_name,
            column_record.table_name
        )
        INTO
            v_target_rows,
            v_target_matches;

        IF v_previous_rows > 0 OR v_target_rows > 0 THEN
            INSERT INTO mm_be_soft_reference_audit
            (
                schema_name,
                table_name,
                column_name,

                previous_reference_rows,
                previous_distinct_matches,

                target_reference_rows,
                target_distinct_matches
            )
            VALUES
            (
                column_record.schema_name,
                column_record.table_name,
                column_record.column_name,

                v_previous_rows,
                v_previous_matches,

                v_target_rows,
                v_target_matches
            );
        END IF;
    END LOOP;
END
$audit_soft_references$;

-------------------------------------------------------------------------------
-- 14. VÝSLEDKY MOŽNÝCH MĚKKÝCH VAZEB
-------------------------------------------------------------------------------

SELECT
    schema_name,
    table_name,
    column_name,

    previous_reference_rows,
    previous_distinct_matches,

    target_reference_rows,
    target_distinct_matches

FROM mm_be_soft_reference_audit

ORDER BY
    previous_reference_rows DESC,
    schema_name,
    table_name,
    column_name;

-------------------------------------------------------------------------------
-- 15. KONTROLA MATCH_PROVIDER_MAP
-------------------------------------------------------------------------------

SELECT
    COUNT(*) FILTER (
        WHERE identity.match_id = plan.previous_match_id
    ) AS provider_identities_on_previous_matches,

    COUNT(*) FILTER (
        WHERE identity.match_id = plan.target_match_id
    ) AS provider_identities_on_target_matches,

    COUNT(DISTINCT identity.match_id) FILTER (
        WHERE identity.match_id = plan.target_match_id
    ) AS target_matches_with_provider_identity

FROM mm_be_transfer_plan plan

JOIN public.match_provider_map identity
  ON identity.match_id IN (
      plan.previous_match_id,
      plan.target_match_id
  );

-------------------------------------------------------------------------------
-- 16. KONEČNÝ SOUHRN
-------------------------------------------------------------------------------

SELECT
    'TRANSFER_PLAN_ROWS' AS check_name,
    COUNT(*)::text AS result
FROM mm_be_transfer_plan

UNION ALL

SELECT
    'DISCOVERED_MATCH_FK_CONSTRAINTS',
    COUNT(*)::text
FROM mm_be_downstream_fk_audit

UNION ALL

SELECT
    'FK_CONSTRAINTS_WITH_PREVIOUS_REFERENCES',
    COUNT(*)::text
FROM mm_be_downstream_fk_audit
WHERE previous_reference_rows > 0

UNION ALL

SELECT
    'TOTAL_PREVIOUS_FK_REFERENCE_ROWS',
    COALESCE(
        SUM(previous_reference_rows),
        0
    )::text
FROM mm_be_downstream_fk_audit

UNION ALL

SELECT
    'SOFT_REFERENCE_CANDIDATES_WITH_MATCHES',
    COUNT(*)::text
FROM mm_be_soft_reference_audit

UNION ALL

SELECT
    'PROVIDER_IDENTITIES_STILL_ON_PREVIOUS',
    COUNT(*)::text
FROM mm_be_transfer_plan plan
JOIN public.match_provider_map identity
  ON identity.match_id = plan.previous_match_id;

-------------------------------------------------------------------------------
-- 17. FINÁLNÍ STAV
-------------------------------------------------------------------------------

SELECT
    CASE
        WHEN (
            SELECT COUNT(*)
            FROM mm_be_transfer_plan
        ) <> 927
        THEN
            'AUDIT_FAILED – NESPRÁVNÝ POČET MIGRAČNÍCH DVOJIC'

        WHEN EXISTS
        (
            SELECT 1
            FROM mm_be_transfer_plan plan
            JOIN public.match_provider_map identity
              ON identity.match_id = plan.previous_match_id
        )
        THEN
            'AUDIT_FAILED – NĚKTERÉ PROVIDEROVÉ IDENTITY ZŮSTALY NA PŮVODNÍCH ZÁPASECH'

        ELSE
            'READ_ONLY_DOWNSTREAM_AUDIT_OK – PŘIPRAVENO K NÁVRHU MIGRACE VAZEB'
    END AS final_status;

ROLLBACK;