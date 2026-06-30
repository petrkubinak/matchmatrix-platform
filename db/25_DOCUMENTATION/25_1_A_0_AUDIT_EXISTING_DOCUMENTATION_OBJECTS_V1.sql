/*
===============================================================================
MATCHMATRIX
SOUBOR: 25_1_A_0_AUDIT_EXISTING_DOCUMENTATION_OBJECTS_V1.sql
SEKCE: 25 – DOCUMENTATION MANAGEMENT SYSTEM
VERZE: V1
DATUM: 2026-06-30

CO:
Provádí pouze čtecí audit databáze a hledá již existující objekty související
s dokumentací, znalostní bází, denními zápisy, navázáním, changelogem,
architektonickými rozhodnutími, slovníkem a snapshoty.

K ČEMU:
- zabránit vytvoření duplicitních tabulek a schémat,
- zjistit, zda již existuje základ Documentation Management System,
- dohledat starší nebo alternativně pojmenované objekty,
- připravit podklad pro návrh schématu `documentation`.

KDE:
C:\MatchMatrix-platform\db\25_DOCUMENTATION\
25_1_A_0_AUDIT_EXISTING_DOCUMENTATION_OBJECTS_V1.sql

JAK:
Spustit nad databází `matchmatrix` v DBeaveru.
Skript nic nevytváří, nemění ani nemaže.
===============================================================================
*/

-- 0. Identifikace databáze
SELECT
    current_database() AS database_name,
    current_user AS database_user,
    version() AS postgres_version,
    clock_timestamp() AS audited_at;

-- 1. Schémata související s dokumentací
SELECT
    n.nspname AS schema_name,
    pg_get_userbyid(n.nspowner) AS owner_name,
    obj_description(n.oid, 'pg_namespace') AS schema_comment
FROM pg_namespace n
WHERE n.nspname NOT LIKE 'pg_%'
  AND n.nspname <> 'information_schema'
  AND (
        lower(n.nspname) ~ '(document|docs|dms|knowledge|wiki|reference|glossary|history|audit)'
        OR n.nspname IN ('public', 'ops', 'runtime', 'staging')
      )
ORDER BY n.nspname;

-- 2. Tabulky, pohledy a materializované pohledy
WITH matching_relations AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS object_name,
        c.relkind,
        c.oid,
        c.reltuples::bigint AS estimated_rows,
        pg_get_userbyid(c.relowner) AS owner_name
    FROM pg_class c
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
    WHERE n.nspname NOT LIKE 'pg_%'
      AND n.nspname <> 'information_schema'
      AND (
            lower(n.nspname) ~ '(document|docs|dms|knowledge|wiki|reference|glossary)'
            OR lower(c.relname) ~
               '(document|doc_|docs|dms|daily.?log|denni|handoff|navaz|changelog|change.?log|architect.*decision|adr|snapshot|glossary|terminolog|term|reference|knowledge|metadata)'
          )
)
SELECT
    schema_name,
    object_name,
    CASE relkind
        WHEN 'r' THEN 'TABLE'
        WHEN 'p' THEN 'PARTITIONED TABLE'
        WHEN 'v' THEN 'VIEW'
        WHEN 'm' THEN 'MATERIALIZED VIEW'
        WHEN 'S' THEN 'SEQUENCE'
        WHEN 'f' THEN 'FOREIGN TABLE'
        ELSE relkind::text
    END AS object_type,
    estimated_rows,
    owner_name,
    obj_description(oid, 'pg_class') AS object_comment
FROM matching_relations
WHERE relkind IN ('r', 'p', 'v', 'm', 'S', 'f')
ORDER BY
    schema_name,
    object_type,
    object_name;

-- 3. Sloupce nalezených tabulek a pohledů
WITH matching_objects AS (
    SELECT DISTINCT
        n.nspname AS schema_name,
        c.relname AS object_name
    FROM pg_class c
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
    WHERE n.nspname NOT LIKE 'pg_%'
      AND n.nspname <> 'information_schema'
      AND c.relkind IN ('r', 'p', 'v', 'm', 'f')
      AND (
            lower(n.nspname) ~ '(document|docs|dms|knowledge|wiki|reference|glossary)'
            OR lower(c.relname) ~
               '(document|doc_|docs|dms|daily.?log|denni|handoff|navaz|changelog|change.?log|architect.*decision|adr|snapshot|glossary|terminolog|term|reference|knowledge|metadata)'
          )
)
SELECT
    c.table_schema AS schema_name,
    c.table_name AS object_name,
    c.ordinal_position,
    c.column_name,
    c.data_type,
    c.udt_name,
    c.is_nullable,
    c.column_default
FROM information_schema.columns c
JOIN matching_objects m
  ON m.schema_name = c.table_schema
 AND m.object_name = c.table_name
ORDER BY
    c.table_schema,
    c.table_name,
    c.ordinal_position;

-- 4. Klíče a omezení
WITH matching_tables AS (
    SELECT DISTINCT
        n.nspname AS schema_name,
        c.relname AS table_name
    FROM pg_class c
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
    WHERE n.nspname NOT LIKE 'pg_%'
      AND n.nspname <> 'information_schema'
      AND c.relkind IN ('r', 'p')
      AND (
            lower(n.nspname) ~ '(document|docs|dms|knowledge|wiki|reference|glossary)'
            OR lower(c.relname) ~
               '(document|doc_|docs|dms|daily.?log|denni|handoff|navaz|changelog|change.?log|architect.*decision|adr|snapshot|glossary|terminolog|term|reference|knowledge|metadata)'
          )
)
SELECT
    tc.table_schema,
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_schema AS referenced_schema,
    ccu.table_name AS referenced_table,
    ccu.column_name AS referenced_column
FROM information_schema.table_constraints tc
JOIN matching_tables mt
  ON mt.schema_name = tc.table_schema
 AND mt.table_name = tc.table_name
LEFT JOIN information_schema.key_column_usage kcu
  ON kcu.constraint_schema = tc.constraint_schema
 AND kcu.constraint_name = tc.constraint_name
 AND kcu.table_schema = tc.table_schema
 AND kcu.table_name = tc.table_name
LEFT JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_schema = tc.constraint_schema
 AND ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type IN (
    'PRIMARY KEY',
    'UNIQUE',
    'FOREIGN KEY'
)
ORDER BY
    tc.table_schema,
    tc.table_name,
    tc.constraint_type,
    tc.constraint_name;

-- 5. Indexy
SELECT
    schemaname AS schema_name,
    tablename AS table_name,
    indexname AS index_name,
    indexdef AS index_definition
FROM pg_indexes
WHERE schemaname NOT LIKE 'pg_%'
  AND schemaname <> 'information_schema'
  AND (
        lower(schemaname) ~ '(document|docs|dms|knowledge|wiki|reference|glossary)'
        OR lower(tablename) ~
           '(document|doc_|docs|dms|daily.?log|denni|handoff|navaz|changelog|change.?log|architect.*decision|adr|snapshot|glossary|terminolog|term|reference|knowledge|metadata)'
      )
ORDER BY
    schemaname,
    tablename,
    indexname;

-- 6. Funkce a procedury
SELECT
    n.nspname AS schema_name,
    p.proname AS routine_name,
    CASE p.prokind
        WHEN 'f' THEN 'FUNCTION'
        WHEN 'p' THEN 'PROCEDURE'
        WHEN 'a' THEN 'AGGREGATE'
        WHEN 'w' THEN 'WINDOW FUNCTION'
        ELSE p.prokind::text
    END AS routine_type,
    pg_get_function_identity_arguments(p.oid) AS arguments,
    pg_get_function_result(p.oid) AS result_type,
    obj_description(p.oid, 'pg_proc') AS routine_comment
FROM pg_proc p
JOIN pg_namespace n
  ON n.oid = p.pronamespace
WHERE n.nspname NOT LIKE 'pg_%'
  AND n.nspname <> 'information_schema'
  AND (
        lower(n.nspname) ~ '(document|docs|dms|knowledge|wiki|reference|glossary)'
        OR lower(p.proname) ~
           '(document|docs|dms|daily|handoff|navaz|changelog|decision|adr|snapshot|glossary|term|reference|knowledge|metadata)'
      )
ORDER BY
    n.nspname,
    p.proname;

-- 7. Kontrola konkrétních navrhovaných objektů
WITH expected_objects (
    schema_name,
    object_name,
    expected_type
) AS (
    VALUES
        ('documentation', 'documents', 'TABLE'),
        ('documentation', 'document_versions', 'TABLE'),
        ('documentation', 'document_sections', 'TABLE'),
        ('documentation', 'document_relations', 'TABLE'),
        ('documentation', 'document_import_runs', 'TABLE'),
        ('documentation', 'import_runs', 'TABLE'),
        ('documentation', 'document_status_history', 'TABLE'),
        ('documentation', 'daily_logs', 'TABLE'),
        ('documentation', 'handoffs', 'TABLE'),
        ('documentation', 'changelog_entries', 'TABLE'),
        ('documentation', 'architecture_decisions', 'TABLE'),
        ('documentation', 'project_snapshots', 'TABLE'),
        ('documentation', 'database_snapshots', 'TABLE')
)
SELECT
    e.schema_name,
    e.object_name,
    e.expected_type,
    CASE
        WHEN c.oid IS NULL THEN 'MISSING'
        ELSE 'EXISTS'
    END AS existence_status,
    CASE c.relkind
        WHEN 'r' THEN 'TABLE'
        WHEN 'p' THEN 'PARTITIONED TABLE'
        WHEN 'v' THEN 'VIEW'
        WHEN 'm' THEN 'MATERIALIZED VIEW'
        WHEN 'S' THEN 'SEQUENCE'
        WHEN 'f' THEN 'FOREIGN TABLE'
        ELSE NULL
    END AS actual_type
FROM expected_objects e
LEFT JOIN pg_namespace n
  ON n.nspname = e.schema_name
LEFT JOIN pg_class c
  ON c.relnamespace = n.oid
 AND c.relname = e.object_name
ORDER BY
    e.schema_name,
    e.object_name;

-- 8. Souhrn
WITH candidates AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS object_name,
        c.relkind
    FROM pg_class c
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
    WHERE n.nspname NOT LIKE 'pg_%'
      AND n.nspname <> 'information_schema'
      AND c.relkind IN ('r', 'p', 'v', 'm', 'f')
      AND (
            lower(n.nspname) ~ '(document|docs|dms|knowledge|wiki|reference|glossary)'
            OR lower(c.relname) ~
               '(document|doc_|docs|dms|daily.?log|denni|handoff|navaz|changelog|change.?log|architect.*decision|adr|snapshot|glossary|terminolog|term|reference|knowledge|metadata)'
          )
)
SELECT
    count(*) AS matching_objects_total,
    count(*) FILTER (
        WHERE relkind IN ('r', 'p', 'f')
    ) AS matching_tables,
    count(*) FILTER (
        WHERE relkind = 'v'
    ) AS matching_views,
    count(*) FILTER (
        WHERE relkind = 'm'
    ) AS matching_materialized_views,
    CASE
        WHEN count(*) = 0
            THEN 'NO_DOCUMENTATION_FOUND'
        WHEN count(*) BETWEEN 1 AND 5
            THEN 'FOUND_SMALL_FOUNDATION'
        ELSE 'FOUND_EXISTING_DOCUMENTATION_LAYER'
    END AS audit_result
FROM candidates;