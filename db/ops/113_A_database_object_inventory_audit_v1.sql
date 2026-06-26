/*
===============================================================================
MATCHMATRIX SQL 113_A
DATABASE OBJECT INVENTORY AUDIT V1
===============================================================================

CO TO JE:
- Audit všech tabulek a view v databázi.
- Najde hlavně objekty typu v1/v2/v3/v4/v5, které mohou být staré verze.

K ČEMU TO JE:
- Abychom zjistili, co je aktivní, co je historické a co se duplikuje.

KDE TO UVIDÍME:
- Výsledek v DBeaveru jako přehled DB objektů.

JAK SE TO VYUŽIJE:
- Další krok bude rozdělení objektů na KEEP / ARCHIVE / DROP_CANDIDATE.
- Zatím nic nemažeme.

===============================================================================
*/

WITH objects AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS object_name,
        CASE c.relkind
            WHEN 'r' THEN 'TABLE'
            WHEN 'v' THEN 'VIEW'
            WHEN 'm' THEN 'MATERIALIZED_VIEW'
            ELSE c.relkind::text
        END AS object_type,
        regexp_replace(c.relname, '_v[0-9]+$', '_vX') AS version_group,
        COALESCE(c.reltuples::bigint, 0) AS estimated_rows
    FROM pg_class c
    JOIN pg_namespace n
        ON n.oid = c.relnamespace
    WHERE n.nspname IN ('ops', 'public', 'staging', 'work')
      AND c.relkind IN ('r', 'v', 'm')
),
cols AS (
    SELECT
        table_schema,
        table_name,
        COUNT(*) AS column_count
    FROM information_schema.columns
    WHERE table_schema IN ('ops', 'public', 'staging', 'work')
    GROUP BY table_schema, table_name
),
grouped AS (
    SELECT
        version_group,
        COUNT(*) AS objects_in_group
    FROM objects
    GROUP BY version_group
)
SELECT
    o.schema_name,
    o.object_type,
    o.object_name,
    o.version_group,
    g.objects_in_group,
    COALESCE(c.column_count, 0) AS column_count,
    o.estimated_rows,
    CASE
        WHEN g.objects_in_group > 1 THEN 'CHECK_DUPLICATE_VERSION'
        WHEN o.object_name ILIKE '%old%' THEN 'CHECK_OLD'
        WHEN o.object_name ILIKE '%tmp%' THEN 'CHECK_TEMP'
        WHEN o.object_name ILIKE '%backup%' THEN 'CHECK_BACKUP'
        ELSE 'OK'
    END AS audit_flag
FROM objects o
LEFT JOIN cols c
    ON c.table_schema = o.schema_name
   AND c.table_name = o.object_name
LEFT JOIN grouped g
    ON g.version_group = o.version_group
ORDER BY
    audit_flag DESC,
    o.schema_name,
    o.version_group,
    o.object_name;