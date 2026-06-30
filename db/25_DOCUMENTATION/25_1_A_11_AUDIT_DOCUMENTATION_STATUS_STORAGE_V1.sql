/*
===============================================================================
MATCHMATRIX STANDARDNÍ HLAVIČKA
===============================================================================

CO:
Provádí read-only audit databázových objektů vhodných pro dlouhodobé ukládání
stavových snapshotů dokumentační vrstvy MatchMatrix.

K ČEMU:
- ověří, zda již existuje tabulka nebo view pro documentation status snapshot,
- vyhledá související objekty ve schématech documentation, ops a runtime,
- zobrazí strukturu nalezených tabulek a view,
- ověří primární klíče, cizí klíče, unikátní omezení a indexy,
- zkontroluje možné názvové kolize,
- poskytne podklady pro návrh A12 bez vytváření duplicitních objektů,
- databázi nijak nemění.

KDE:
db/25_DOCUMENTATION/25_1_A_11_AUDIT_DOCUMENTATION_STATUS_STORAGE_V1.sql

JAK:
Spustit celý skript v DBeaveru nad databází matchmatrix.

OČEKÁVANÝ VÝSLEDEK:
Skript vrátí několik samostatných result setů:
1. kandidátní objekty,
2. sloupce kandidátních objektů,
3. omezení,
4. indexy,
5. závislosti view,
6. doporučení dalšího kroku.

BEZPEČNOST:
Pouze SELECT. Neobsahuje CREATE, ALTER, INSERT, UPDATE, DELETE ani DROP.
===============================================================================
*/

BEGIN TRANSACTION READ ONLY;

/*
-------------------------------------------------------------------------------
1. KANDIDÁTNÍ OBJEKTY
-------------------------------------------------------------------------------
Vyhledává tabulky, partitioned tables, view a materialized view, jejichž názvy
nebo komentáře souvisejí s dokumentací, stavem, snapshotem, health nebo KPI.
*/

WITH object_inventory AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS object_name,
        CASE c.relkind
            WHEN 'r' THEN 'TABLE'
            WHEN 'p' THEN 'PARTITIONED_TABLE'
            WHEN 'v' THEN 'VIEW'
            WHEN 'm' THEN 'MATERIALIZED_VIEW'
            ELSE c.relkind::text
        END AS object_type,
        obj_description(c.oid, 'pg_class') AS object_comment,
        c.oid AS object_oid
    FROM pg_class AS c
    JOIN pg_namespace AS n
      ON n.oid = c.relnamespace
    WHERE n.nspname IN ('documentation', 'ops', 'runtime')
      AND c.relkind IN ('r', 'p', 'v', 'm')
)
SELECT
    schema_name,
    object_name,
    object_type,
    object_comment,
    CASE
        WHEN lower(object_name) ~ '(documentation|document).*(status|health|snapshot|kpi)'
          OR lower(object_name) ~ '(status|health|snapshot|kpi).*(documentation|document)'
        THEN 'STRONG_NAME_MATCH'
        WHEN lower(coalesce(object_comment, '')) ~
             '(documentation|document).*(status|health|snapshot|kpi)'
        THEN 'COMMENT_MATCH'
        WHEN lower(object_name) ~ '(status|health|snapshot|kpi)'
        THEN 'GENERIC_STATUS_MATCH'
        ELSE 'RELATED_DOCUMENTATION_OBJECT'
    END AS match_reason
FROM object_inventory
WHERE lower(object_name) ~
          '(documentation|document|status|health|snapshot|kpi)'
   OR lower(coalesce(object_comment, '')) ~
          '(documentation|document|status|health|snapshot|kpi)'
ORDER BY
    CASE
        WHEN lower(object_name) ~ '(documentation|document).*(status|health|snapshot|kpi)'
          OR lower(object_name) ~ '(status|health|snapshot|kpi).*(documentation|document)'
        THEN 1
        WHEN lower(object_name) ~ '(status|health|snapshot|kpi)'
        THEN 2
        ELSE 3
    END,
    schema_name,
    object_name;


/*
-------------------------------------------------------------------------------
2. SLOUPCE KANDIDÁTNÍCH OBJEKTŮ
-------------------------------------------------------------------------------
Vrací sloupce objektů, jejichž názvy odpovídají potenciálnímu úložišti
snapshotů nebo KPI.
*/

WITH candidate_objects AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS object_name
    FROM pg_class AS c
    JOIN pg_namespace AS n
      ON n.oid = c.relnamespace
    WHERE n.nspname IN ('documentation', 'ops', 'runtime')
      AND c.relkind IN ('r', 'p', 'v', 'm')
      AND (
            lower(c.relname) ~
                '(documentation|document|status|health|snapshot|kpi)'
         OR lower(coalesce(obj_description(c.oid, 'pg_class'), '')) ~
                '(documentation|document|status|health|snapshot|kpi)'
      )
)
SELECT
    cols.table_schema AS schema_name,
    cols.table_name AS object_name,
    cols.ordinal_position,
    cols.column_name,
    cols.data_type,
    cols.udt_name,
    cols.is_nullable,
    cols.column_default,
    cols.character_maximum_length,
    cols.numeric_precision,
    cols.numeric_scale
FROM information_schema.columns AS cols
JOIN candidate_objects AS candidates
  ON candidates.schema_name = cols.table_schema
 AND candidates.object_name = cols.table_name
ORDER BY
    cols.table_schema,
    cols.table_name,
    cols.ordinal_position;


/*
-------------------------------------------------------------------------------
3. OMEZENÍ KANDIDÁTNÍCH TABULEK
-------------------------------------------------------------------------------
*/

WITH candidate_tables AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS table_name,
        c.oid AS table_oid
    FROM pg_class AS c
    JOIN pg_namespace AS n
      ON n.oid = c.relnamespace
    WHERE n.nspname IN ('documentation', 'ops', 'runtime')
      AND c.relkind IN ('r', 'p')
      AND (
            lower(c.relname) ~
                '(documentation|document|status|health|snapshot|kpi)'
         OR lower(coalesce(obj_description(c.oid, 'pg_class'), '')) ~
                '(documentation|document|status|health|snapshot|kpi)'
      )
)
SELECT
    candidates.schema_name,
    candidates.table_name,
    constraints.conname AS constraint_name,
    CASE constraints.contype
        WHEN 'p' THEN 'PRIMARY_KEY'
        WHEN 'f' THEN 'FOREIGN_KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 'c' THEN 'CHECK'
        WHEN 'x' THEN 'EXCLUSION'
        ELSE constraints.contype::text
    END AS constraint_type,
    pg_get_constraintdef(constraints.oid, true) AS constraint_definition
FROM candidate_tables AS candidates
JOIN pg_constraint AS constraints
  ON constraints.conrelid = candidates.table_oid
ORDER BY
    candidates.schema_name,
    candidates.table_name,
    constraint_type,
    constraint_name;


/*
-------------------------------------------------------------------------------
4. INDEXY KANDIDÁTNÍCH TABULEK A MATERIALIZED VIEW
-------------------------------------------------------------------------------
*/

WITH candidate_objects AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS object_name
    FROM pg_class AS c
    JOIN pg_namespace AS n
      ON n.oid = c.relnamespace
    WHERE n.nspname IN ('documentation', 'ops', 'runtime')
      AND c.relkind IN ('r', 'p', 'm')
      AND (
            lower(c.relname) ~
                '(documentation|document|status|health|snapshot|kpi)'
         OR lower(coalesce(obj_description(c.oid, 'pg_class'), '')) ~
                '(documentation|document|status|health|snapshot|kpi)'
      )
)
SELECT
    indexes.schemaname AS schema_name,
    indexes.tablename AS object_name,
    indexes.indexname AS index_name,
    indexes.indexdef AS index_definition
FROM pg_indexes AS indexes
JOIN candidate_objects AS candidates
  ON candidates.schema_name = indexes.schemaname
 AND candidates.object_name = indexes.tablename
ORDER BY
    indexes.schemaname,
    indexes.tablename,
    indexes.indexname;


/*
-------------------------------------------------------------------------------
5. ZÁVISLOSTI VIEW
-------------------------------------------------------------------------------
Zobrazuje, zda již některé OPS nebo documentation view čte ze současných
dokumentačních tabulek.
*/

SELECT DISTINCT
    dependent_ns.nspname AS dependent_schema,
    dependent_view.relname AS dependent_view,
    source_ns.nspname AS source_schema,
    source_table.relname AS source_object
FROM pg_rewrite AS rewrite_rule
JOIN pg_class AS dependent_view
  ON dependent_view.oid = rewrite_rule.ev_class
JOIN pg_namespace AS dependent_ns
  ON dependent_ns.oid = dependent_view.relnamespace
JOIN pg_depend AS dependency
  ON dependency.objid = rewrite_rule.oid
JOIN pg_class AS source_table
  ON source_table.oid = dependency.refobjid
JOIN pg_namespace AS source_ns
  ON source_ns.oid = source_table.relnamespace
WHERE dependent_ns.nspname IN ('documentation', 'ops')
  AND dependent_view.relkind IN ('v', 'm')
  AND source_ns.nspname = 'documentation'
  AND source_table.relname IN (
        'documents',
        'document_versions',
        'document_sections',
        'document_relations',
        'document_status_history',
        'import_runs'
  )
ORDER BY
    dependent_schema,
    dependent_view,
    source_schema,
    source_object;


/*
-------------------------------------------------------------------------------
6. AKTUÁLNÍ DOKUMENTAČNÍ VIEW
-------------------------------------------------------------------------------
*/

SELECT
    table_schema AS schema_name,
    table_name AS view_name,
    view_definition
FROM information_schema.views
WHERE table_schema IN ('documentation', 'ops')
  AND (
        lower(table_name) LIKE '%document%'
     OR lower(table_name) LIKE '%status%'
     OR lower(table_name) LIKE '%health%'
     OR lower(table_name) LIKE '%snapshot%'
     OR lower(table_name) LIKE '%kpi%'
  )
ORDER BY
    table_schema,
    table_name;


/*
-------------------------------------------------------------------------------
7. SHRNUTÍ A DOPORUČENÍ
-------------------------------------------------------------------------------
Logika doporučení:
- REUSE_EXISTING_OBJECT: existuje silně odpovídající fyzická tabulka,
- REVIEW_GENERIC_STATUS_OBJECTS: existují pouze obecné status/snapshot tabulky,
- CREATE_DOCUMENTATION_STATUS_STORAGE: vhodná tabulka nebyla nalezena.
*/

WITH physical_objects AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS object_name,
        obj_description(c.oid, 'pg_class') AS object_comment
    FROM pg_class AS c
    JOIN pg_namespace AS n
      ON n.oid = c.relnamespace
    WHERE n.nspname IN ('documentation', 'ops', 'runtime')
      AND c.relkind IN ('r', 'p')
),
classified AS (
    SELECT
        schema_name,
        object_name,
        object_comment,
        CASE
            WHEN lower(object_name) ~
                 '(documentation|document).*(status|health|snapshot|kpi)'
              OR lower(object_name) ~
                 '(status|health|snapshot|kpi).*(documentation|document)'
            THEN 'STRONG'
            WHEN lower(object_name) ~ '(status|health|snapshot|kpi)'
            THEN 'GENERIC'
            ELSE 'NONE'
        END AS match_level
    FROM physical_objects
)
SELECT
    COUNT(*) FILTER (WHERE match_level = 'STRONG') AS strong_candidate_tables,
    COUNT(*) FILTER (WHERE match_level = 'GENERIC') AS generic_candidate_tables,
    CASE
        WHEN COUNT(*) FILTER (WHERE match_level = 'STRONG') > 0
        THEN 'REUSE_EXISTING_OBJECT'
        WHEN COUNT(*) FILTER (WHERE match_level = 'GENERIC') > 0
        THEN 'REVIEW_GENERIC_STATUS_OBJECTS'
        ELSE 'CREATE_DOCUMENTATION_STATUS_STORAGE'
    END AS recommended_next_step,
    CASE
        WHEN COUNT(*) FILTER (WHERE match_level = 'STRONG') > 0
        THEN 'Nejprve vyhodnotit existující silně odpovídající tabulku.'
        WHEN COUNT(*) FILTER (WHERE match_level = 'GENERIC') > 0
        THEN 'Prověřit, zda některá obecná status tabulka může být bezpečně rozšířena.'
        ELSE 'Je možné navrhnout nové úložiště snapshotů ve schématu documentation.'
    END AS recommendation
FROM classified;

ROLLBACK;
