/*
CO:
  G4D-3 / STEP 4 – PHYSICAL TARGET CONTRACT PRECHECK V1

K ČEMU:
  Ověření fyzických předpokladů před VALIDATE_ONLY migrací.
  Bez vytváření tabulek, změn dat nebo routing approval.

KDE:
  PC2 / PostgreSQL / matchmatrix / DBeaver.

JAK:
  Spustit celý skript jako SQL script.
  Vrátit výslednou tabulku včetně DETAIL.
  BLOCKER nebo SQL chyba = STOP a vyhodnocení.
  EXPECTED_CHANGE = očekávaná úprava pro budoucí migraci.
*/

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;

SET LOCAL statement_timeout = '60s';
SET LOCAL lock_timeout = '5s';

-- Zabrání tichému podhodnocení počtu přes row-level security.
-- Pokud role nemůže přečíst všechny řádky, dotaz skončí chybou.
SET LOCAL row_security = off;

WITH
target_names(object_name) AS (
    VALUES
        ('source_master'),
        ('source_alias'),
        ('source_sport'),
        ('source_entity_time_coverage'),
        ('source_audit_evidence'),
        ('runtime_adapter'),
        ('source_adapter_binding')
),
required_sports(code) AS (
    VALUES
        ('AFB'), ('BK'), ('BSB'), ('CK'), ('FB'),
        ('HB'), ('HK'), ('MMA'), ('TN'), ('VB')
),
routing_object AS (
    SELECT c.oid, c.relkind, c.relrowsecurity
    FROM pg_catalog.pg_class c
    JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'ops'
      AND c.relname = 'data_acquisition_source_routing'
),
routing_columns AS (
    SELECT
        a.attnum,
        a.attname::text AS column_name,
        pg_catalog.format_type(a.atttypid, a.atttypmod) AS data_type,
        a.attnotnull AS not_null,
        a.attidentity::text AS identity_kind,
        a.attgenerated::text AS generated_kind,
        pg_catalog.pg_get_expr(d.adbin, d.adrelid) AS default_expression
    FROM pg_catalog.pg_attribute a
    JOIN routing_object r ON r.oid = a.attrelid
    LEFT JOIN pg_catalog.pg_attrdef d
        ON d.adrelid = a.attrelid AND d.adnum = a.attnum
    WHERE a.attnum > 0
      AND NOT a.attisdropped
),
routing_constraints AS (
    SELECT
        k.conname::text AS constraint_name,
        k.contype::text AS constraint_type,
        k.convalidated,
        k.conkey,
        pg_catalog.pg_get_constraintdef(k.oid, true) AS definition
    FROM pg_catalog.pg_constraint k
    JOIN routing_object r ON r.oid = k.conrelid
),
routing_count AS (
    SELECT count(*) AS row_count
    FROM ops.data_acquisition_source_routing
),
sport_counts AS (
    SELECT s.code::text AS code, count(*) AS row_count
    FROM public.sports s
    JOIN required_sports r ON r.code = s.code::text
    GROUP BY s.code::text
),
checks AS (
    SELECT
        10 AS sort_order,
        'ENVIRONMENT'::text AS section,
        'DATABASE'::text AS check_name,
        CASE WHEN current_database() = 'matchmatrix'
             THEN 'PASS' ELSE 'BLOCKER' END::text AS status,
        format('database=%s; user=%s; server=%s; port=%s',
            current_database(), current_user,
            inet_server_addr(), inet_server_port()) AS detail

    UNION ALL
    SELECT 11, 'ENVIRONMENT', 'READ_ONLY',
        CASE WHEN current_setting('transaction_read_only') = 'on'
             THEN 'PASS' ELSE 'BLOCKER' END,
        current_setting('transaction_read_only')

    UNION ALL
    SELECT 12, 'ENVIRONMENT', 'POSTGRES_CAPABILITIES',
        CASE WHEN current_setting('server_version_num')::integer >= 150000
             THEN 'PASS' ELSE 'BLOCKER' END,
        format(
            'server=%s; kontrolovaný práh PG15+: identity, '
            'partial indexes, UNIQUE NULLS NOT DISTINCT',
            current_setting('server_version')
        )

    UNION ALL
    SELECT 13, 'ENVIRONMENT', 'OPS_SCHEMA',
        CASE WHEN EXISTS (
            SELECT 1 FROM pg_catalog.pg_namespace WHERE nspname = 'ops'
        ) THEN 'PASS' ELSE 'BLOCKER' END,
        'Požadované cílové schéma: ops'

    UNION ALL
    SELECT 20, 'TARGET_OBJECT', 'ops.' || t.object_name,
        CASE WHEN
            to_regclass('ops.' || t.object_name) IS NULL
            AND to_regtype('ops.' || t.object_name) IS NULL
        THEN 'PASS' ELSE 'BLOCKER' END,
        format('relation=%s; type=%s',
            coalesce(to_regclass('ops.' || t.object_name)::text, 'NONE'),
            coalesce(to_regtype('ops.' || t.object_name)::text, 'NONE'))
    FROM target_names t

    UNION ALL
    SELECT 30, 'SPORT_CODE', r.code,
        CASE WHEN coalesce(s.row_count, 0) = 1
             THEN 'PASS' ELSE 'BLOCKER' END,
        format('public.sports.code: exact matches=%s',
               coalesce(s.row_count, 0))
    FROM required_sports r
    LEFT JOIN sport_counts s ON s.code = r.code

    UNION ALL
    SELECT 40, 'ROUTING', 'TABLE_EXISTS',
        CASE WHEN EXISTS (
            SELECT 1 FROM routing_object WHERE relkind IN ('r', 'p')
        ) THEN 'PASS' ELSE 'BLOCKER' END,
        coalesce((
            SELECT format('relkind=%s; RLS=%s', relkind, relrowsecurity)
            FROM routing_object
        ), 'MISSING')

    UNION ALL
    SELECT 41, 'ROUTING', 'CURRENT_ROWS',
        CASE WHEN row_count = 0 THEN 'PASS' ELSE 'BLOCKER' END,
        format('expected=0; actual=%s', row_count)
    FROM routing_count

    UNION ALL
    SELECT 42, 'ROUTING', 'CANONICAL_SOURCE_ID_COLUMN',
        CASE WHEN EXISTS (
            SELECT 1 FROM routing_columns WHERE column_name = 'source_id'
        ) THEN 'BLOCKER' ELSE 'EXPECTED_CHANGE' END,
        CASE WHEN EXISTS (
            SELECT 1 FROM routing_columns WHERE column_name = 'source_id'
        )
        THEN 'source_id již existuje: odchylka od baseline, nutná kontrola.'
        ELSE 'source_id chybí: očekávané budoucí aditivní rozšíření.'
        END

    UNION ALL
    SELECT 43, 'ROUTING', 'LEGACY_' || upper(v.column_name),
        CASE WHEN c.column_name IS NOT NULL
             THEN 'EXPECTED_CHANGE' ELSE 'BLOCKER' END,
        CASE WHEN c.column_name IS NULL
             THEN 'Chybí očekávaný legacy sloupec.'
             ELSE format('type=%s; not_null=%s; default=%s',
                 c.data_type, c.not_null,
                 coalesce(c.default_expression, 'NONE'))
        END
    FROM (
        VALUES ('source_ref_id'), ('source_origin'), ('source_name')
    ) AS v(column_name)
    LEFT JOIN routing_columns c USING (column_name)

    UNION ALL
    SELECT 44, 'ROUTING', upper(v.column_name) || '_CONSTRAINT',
        CASE
            WHEN c.column_name IS NULL THEN 'BLOCKER'
            WHEN NOT EXISTS (
                SELECT 1
                FROM routing_constraints k
                WHERE k.constraint_type = 'c'
                  AND c.attnum = ANY(k.conkey)
            ) THEN 'BLOCKER'
            ELSE 'EXPECTED_CHANGE'
        END,
        coalesce((
            SELECT string_agg(
                k.constraint_name || ': ' || k.definition,
                E'\n' ORDER BY k.constraint_name
            )
            FROM routing_constraints k
            WHERE k.constraint_type = 'c'
              AND c.attnum = ANY(k.conkey)
        ), 'CHECK constraint nenalezen; vyhodnotit typ sloupce a kontrakt.')
    FROM (VALUES ('source_role'), ('source_origin')) AS v(column_name)
    LEFT JOIN routing_columns c USING (column_name)

    UNION ALL
    SELECT 50, 'ROUTING_COLUMN', column_name, 'INFO',
        format(
            'type=%s; not_null=%s; identity=%s; generated=%s; default=%s',
            data_type, not_null,
            coalesce(nullif(identity_kind, ''), 'NONE'),
            coalesce(nullif(generated_kind, ''), 'NONE'),
            coalesce(default_expression, 'NONE')
        )
    FROM routing_columns

    UNION ALL
    SELECT 60, 'ROUTING_CONSTRAINT', constraint_name, 'INFO',
        format('type=%s; validated=%s; definition=%s',
               constraint_type, convalidated, definition)
    FROM routing_constraints
),
report AS (
    SELECT * FROM checks

    UNION ALL
    SELECT
        99,
        'SUMMARY',
        'STEP_4_PRECHECK',
        CASE WHEN count(*) FILTER (WHERE status = 'BLOCKER') > 0
             THEN 'BLOCKER'
             ELSE 'READY_FOR_CONTRACT_REVIEW'
        END,
        format(
            'PASS=%s; EXPECTED_CHANGE=%s; BLOCKER=%s. '
            'Před uzavřením STEP 4 vyhodnotit přesné definice '
            'routing sloupců a constraints.',
            count(*) FILTER (WHERE status = 'PASS'),
            count(*) FILTER (WHERE status = 'EXPECTED_CHANGE'),
            count(*) FILTER (WHERE status = 'BLOCKER')
        )
    FROM checks
)
SELECT section, check_name, status, detail
FROM report
ORDER BY sort_order, check_name;

ROLLBACK;