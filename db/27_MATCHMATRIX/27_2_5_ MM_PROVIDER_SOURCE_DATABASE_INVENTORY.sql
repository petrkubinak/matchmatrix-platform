/* ============================================================================
CO:
    MM – PROVIDER / SOURCE DATABASE INVENTORY – READ ONLY

K ČEMU:
    Zjistí skutečný fyzický stav existujících Provider / Source tabulek,
    jejich typ, počet řádků, sloupce a klíčové vazby.

KDE:
    PostgreSQL databáze matchmatrix
    schema ops

JAK:
    Pouze READ ONLY.
    Nic nevytváří, nemaže ani neupravuje.
============================================================================ */

BEGIN;
SET TRANSACTION READ ONLY;


/* ============================================================================
1. EXISTENCE A TYP OBJEKTŮ
============================================================================ */

SELECT
    n.nspname AS schema_name,
    c.relname AS object_name,
    CASE c.relkind
        WHEN 'r' THEN 'TABLE'
        WHEN 'p' THEN 'PARTITIONED TABLE'
        WHEN 'v' THEN 'VIEW'
        WHEN 'm' THEN 'MATERIALIZED VIEW'
        WHEN 'f' THEN 'FOREIGN TABLE'
        ELSE c.relkind::text
    END AS object_type
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE n.nspname = 'ops'
  AND c.relname IN (
        'source_master',
        'source_alias',
        'source_sport',
        'source_entity_time_coverage',
        'source_audit_evidence',
        'runtime_adapter',
        'source_adapter_binding',
        'data_acquisition_source_routing',

        'source_intelligence_map',
        'source_discovery_audit_tracker',
        'source_commercial_model',
        'source_legal_audit',
        'source_quality_score',

        'provider_entity_coverage',
        'provider_sport_matrix',
        'provider_accounts',
        'provider_jobs',
        'provider_worker_registry'
  )
ORDER BY c.relname;


/* ============================================================================
2. POČTY ŘÁDKŮ
============================================================================ */

SELECT 'source_master' AS object_name,
       COUNT(*) AS row_count
FROM ops.source_master

UNION ALL
SELECT 'source_alias',
       COUNT(*)
FROM ops.source_alias

UNION ALL
SELECT 'source_sport',
       COUNT(*)
FROM ops.source_sport

UNION ALL
SELECT 'source_entity_time_coverage',
       COUNT(*)
FROM ops.source_entity_time_coverage

UNION ALL
SELECT 'source_audit_evidence',
       COUNT(*)
FROM ops.source_audit_evidence

UNION ALL
SELECT 'runtime_adapter',
       COUNT(*)
FROM ops.runtime_adapter

UNION ALL
SELECT 'source_adapter_binding',
       COUNT(*)
FROM ops.source_adapter_binding

UNION ALL
SELECT 'data_acquisition_source_routing',
       COUNT(*)
FROM ops.data_acquisition_source_routing

UNION ALL
SELECT 'source_intelligence_map',
       COUNT(*)
FROM ops.source_intelligence_map

UNION ALL
SELECT 'source_discovery_audit_tracker',
       COUNT(*)
FROM ops.source_discovery_audit_tracker

UNION ALL
SELECT 'source_commercial_model',
       COUNT(*)
FROM ops.source_commercial_model

UNION ALL
SELECT 'source_legal_audit',
       COUNT(*)
FROM ops.source_legal_audit

UNION ALL
SELECT 'source_quality_score',
       COUNT(*)
FROM ops.source_quality_score

UNION ALL
SELECT 'provider_entity_coverage',
       COUNT(*)
FROM ops.provider_entity_coverage

UNION ALL
SELECT 'provider_sport_matrix',
       COUNT(*)
FROM ops.provider_sport_matrix

UNION ALL
SELECT 'provider_accounts',
       COUNT(*)
FROM ops.provider_accounts

UNION ALL
SELECT 'provider_jobs',
       COUNT(*)
FROM ops.provider_jobs

UNION ALL
SELECT 'provider_worker_registry',
       COUNT(*)
FROM ops.provider_worker_registry

ORDER BY object_name;


/* ============================================================================
3. STRUKTURA SLOUPCŮ
============================================================================ */

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
WHERE table_schema = 'ops'
  AND table_name IN (
        'source_master',
        'source_alias',
        'source_sport',
        'source_entity_time_coverage',
        'source_audit_evidence',
        'runtime_adapter',
        'source_adapter_binding',
        'data_acquisition_source_routing',

        'source_intelligence_map',
        'source_discovery_audit_tracker',
        'source_commercial_model',
        'source_legal_audit',
        'source_quality_score',

        'provider_entity_coverage',
        'provider_sport_matrix',
        'provider_accounts',
        'provider_jobs',
        'provider_worker_registry'
  )
ORDER BY
    table_name,
    ordinal_position;


/* ============================================================================
4. PRIMARY KEY / FOREIGN KEY / UNIQUE / CHECK CONSTRAINTS
============================================================================ */

SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    con.conname AS constraint_name,
    CASE con.contype
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'f' THEN 'FOREIGN KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 'c' THEN 'CHECK'
        WHEN 'x' THEN 'EXCLUSION'
        ELSE con.contype::text
    END AS constraint_type,
    pg_get_constraintdef(con.oid) AS constraint_definition
FROM pg_constraint con
JOIN pg_class c
    ON c.oid = con.conrelid
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE n.nspname = 'ops'
  AND c.relname IN (
        'source_master',
        'source_alias',
        'source_sport',
        'source_entity_time_coverage',
        'source_audit_evidence',
        'runtime_adapter',
        'source_adapter_binding',
        'data_acquisition_source_routing',

        'source_intelligence_map',
        'source_discovery_audit_tracker',
        'source_commercial_model',
        'source_legal_audit',
        'source_quality_score',

        'provider_entity_coverage',
        'provider_sport_matrix',
        'provider_accounts',
        'provider_jobs',
        'provider_worker_registry'
  )
ORDER BY
    c.relname,
    constraint_type,
    con.conname;


/* ============================================================================
5. INDEXY
============================================================================ */

SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'ops'
  AND tablename IN (
        'source_master',
        'source_alias',
        'source_sport',
        'source_entity_time_coverage',
        'source_audit_evidence',
        'runtime_adapter',
        'source_adapter_binding',
        'data_acquisition_source_routing',

        'source_intelligence_map',
        'source_discovery_audit_tracker',
        'source_commercial_model',
        'source_legal_audit',
        'source_quality_score',

        'provider_entity_coverage',
        'provider_sport_matrix',
        'provider_accounts',
        'provider_jobs',
        'provider_worker_registry'
  )
ORDER BY
    tablename,
    indexname;


/* ============================================================================
6. DETAIL SOURCE × SPORT
   Tohle nám přesně ukáže, které zdroje jsou přiřazené k HB.
============================================================================ */

SELECT
    ss.source_sport_id,
    ss.source_id,
    sm.source_code,
    sm.canonical_name,
    ss.sport_code,
    ss.relationship_status,
    ss.sport_specific_url
FROM ops.source_sport ss
JOIN ops.source_master sm
    ON sm.source_id = ss.source_id
ORDER BY
    ss.sport_code,
    sm.canonical_name;


/* ============================================================================
7. POUZE HÁZENÁ
============================================================================ */

SELECT
    ss.source_sport_id,
    ss.source_id,
    sm.source_code,
    sm.canonical_name,
    sm.source_type,
    sm.canonical_domain,
    ss.sport_code,
    ss.relationship_status,
    ss.sport_specific_url
FROM ops.source_sport ss
JOIN ops.source_master sm
    ON sm.source_id = ss.source_id
WHERE ss.sport_code = 'HB'
ORDER BY
    sm.canonical_name;


/* ============================================================================
8. KONTROLA, ZDA STEJNÝ SOURCE MŮŽE MÍT VÍCE SPORTŮ
============================================================================ */

SELECT
    sm.source_id,
    sm.source_code,
    sm.canonical_name,
    COUNT(*) AS sport_count,
    STRING_AGG(
        ss.sport_code,
        ', '
        ORDER BY ss.sport_code
    ) AS sports
FROM ops.source_master sm
JOIN ops.source_sport ss
    ON ss.source_id = sm.source_id
GROUP BY
    sm.source_id,
    sm.source_code,
    sm.canonical_name
ORDER BY
    sport_count DESC,
    sm.canonical_name;


/* ============================================================================
9. SOURCE INTELLIGENCE / DISCOVERY – NÁHLED DAT
   Právě tyto tabulky jsou kandidáti pro náš budoucí seznam zdrojů.
============================================================================ */

SELECT *
FROM ops.source_intelligence_map
ORDER BY 1;

SELECT *
FROM ops.source_discovery_audit_tracker
ORDER BY 1;

SELECT *
FROM ops.source_commercial_model
ORDER BY 1;


/* ============================================================================
KONEC – ŽÁDNÉ ZMĚNY
============================================================================ */

ROLLBACK;