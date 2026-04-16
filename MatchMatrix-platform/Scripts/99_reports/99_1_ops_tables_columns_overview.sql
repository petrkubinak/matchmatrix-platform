-- ============================================================
-- 710_ops_key_tables_columns_overview.sql
-- MatchMatrix - OPS key tables columns overview
--
-- Kam ulozit:
-- C:\MatchMatrix-platform\db\audit\710_ops_key_tables_columns_overview.sql
--
-- Jak spustit:
-- DBeaver -> otevrit soubor -> spustit cely script
--
-- Co dela:
-- 1) vypise sloupce, datove typy a poradi pro nejcasteji pouzivane ops tabulky
-- 2) ukaze nullability a defaulty
-- 3) da rychly stabilni prehled, ze ktereho budeme pri dalsi praci vychazet
--
-- Poznamka:
-- Tento script je zamerne jen introspekcni / auditni.
-- Nic nemeni v databazi.
-- ============================================================

-- ------------------------------------------------------------
-- 1) seznam klicovych ops tabulek
--    sem budeme dlouhodobe davat hlavne tabulky,
--    se kterymi realne casto pracujeme
-- ------------------------------------------------------------
WITH key_tables AS (
    SELECT 'ingest_targets'::text         AS table_name, 1 AS sort_order
    UNION ALL SELECT 'runtime_entity_audit',      2
    UNION ALL SELECT 'sport_completion_audit',    3
    UNION ALL SELECT 'job_runs',                  4
    UNION ALL SELECT 'jobs',                      5
    UNION ALL SELECT 'provider_jobs',             6
    UNION ALL SELECT 'ingest_planner',            7
    UNION ALL SELECT 'ingest_runtime_config',     8
    UNION ALL SELECT 'scheduler_queue',           9
    UNION ALL SELECT 'worker_locks',             10
    UNION ALL SELECT 'provider_entity_coverage', 11
    UNION ALL SELECT 'provider_people_audit',    12
    UNION ALL SELECT 'sports_import_plan',       13
    UNION ALL SELECT 'league_import_plan',       14
    UNION ALL SELECT 'player_enrichment_plan',   15
    UNION ALL SELECT 'provider_sport_matrix',    16
    UNION ALL SELECT 'ingest_entity_plan',       17
    UNION ALL SELECT 'fb_entity_audit',          18
    UNION ALL SELECT 'provider_coaches_runtime_checklist', 19
)

-- ------------------------------------------------------------
-- 2) hlavni prehled sloupcu
-- ------------------------------------------------------------
SELECT
    kt.sort_order,
    c.table_schema,
    c.table_name,
    c.ordinal_position,
    c.column_name,
    c.data_type,
    c.udt_name,
    c.is_nullable,
    c.column_default
FROM information_schema.columns c
JOIN key_tables kt
  ON kt.table_name = c.table_name
WHERE c.table_schema = 'ops'
ORDER BY
    kt.sort_order,
    c.table_name,
    c.ordinal_position;

-- ------------------------------------------------------------
-- 3) zkraceny souhrn po tabulkach
--    rychly prehled kolik ma kazda tabulka sloupcu
-- ------------------------------------------------------------
WITH key_tables AS (
    SELECT 'ingest_targets'::text         AS table_name, 1 AS sort_order
    UNION ALL SELECT 'runtime_entity_audit',      2
    UNION ALL SELECT 'sport_completion_audit',    3
    UNION ALL SELECT 'job_runs',                  4
    UNION ALL SELECT 'jobs',                      5
    UNION ALL SELECT 'provider_jobs',             6
    UNION ALL SELECT 'ingest_planner',            7
    UNION ALL SELECT 'ingest_runtime_config',     8
    UNION ALL SELECT 'scheduler_queue',           9
    UNION ALL SELECT 'worker_locks',             10
    UNION ALL SELECT 'provider_entity_coverage', 11
    UNION ALL SELECT 'provider_people_audit',    12
    UNION ALL SELECT 'sports_import_plan',       13
    UNION ALL SELECT 'league_import_plan',       14
    UNION ALL SELECT 'player_enrichment_plan',   15
    UNION ALL SELECT 'provider_sport_matrix',    16
    UNION ALL SELECT 'ingest_entity_plan',       17
    UNION ALL SELECT 'fb_entity_audit',          18
    UNION ALL SELECT 'provider_coaches_runtime_checklist', 19
)
SELECT
    kt.sort_order,
    c.table_name,
    count(*) AS column_count
FROM information_schema.columns c
JOIN key_tables kt
  ON kt.table_name = c.table_name
WHERE c.table_schema = 'ops'
GROUP BY kt.sort_order, c.table_name
ORDER BY kt.sort_order, c.table_name;

-- ------------------------------------------------------------
-- 4) volitelne: primary key / unique / foreign key prehled
--    uzitecne, kdyz budeme potrebovat pochopit vazby
-- ------------------------------------------------------------
WITH key_tables AS (
    SELECT 'ingest_targets'::text         AS table_name, 1 AS sort_order
    UNION ALL SELECT 'runtime_entity_audit',      2
    UNION ALL SELECT 'sport_completion_audit',    3
    UNION ALL SELECT 'job_runs',                  4
    UNION ALL SELECT 'jobs',                      5
    UNION ALL SELECT 'provider_jobs',             6
    UNION ALL SELECT 'ingest_planner',            7
    UNION ALL SELECT 'ingest_runtime_config',     8
    UNION ALL SELECT 'scheduler_queue',           9
    UNION ALL SELECT 'worker_locks',             10
    UNION ALL SELECT 'provider_entity_coverage', 11
    UNION ALL SELECT 'provider_people_audit',    12
    UNION ALL SELECT 'sports_import_plan',       13
    UNION ALL SELECT 'league_import_plan',       14
    UNION ALL SELECT 'player_enrichment_plan',   15
    UNION ALL SELECT 'provider_sport_matrix',    16
    UNION ALL SELECT 'ingest_entity_plan',       17
    UNION ALL SELECT 'fb_entity_audit',          18
    UNION ALL SELECT 'provider_coaches_runtime_checklist', 19
)
SELECT
    kt.sort_order,
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name   AS foreign_table_name,
    ccu.column_name  AS foreign_column_name
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.key_column_usage kcu
       ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
      AND tc.table_name = kcu.table_name
LEFT JOIN information_schema.constraint_column_usage ccu
       ON tc.constraint_name = ccu.constraint_name
      AND tc.table_schema = ccu.table_schema
JOIN key_tables kt
  ON kt.table_name = tc.table_name
WHERE tc.table_schema = 'ops'
  AND tc.constraint_type IN ('PRIMARY KEY', 'UNIQUE', 'FOREIGN KEY')
ORDER BY
    kt.sort_order,
    tc.table_name,
    tc.constraint_type,
    tc.constraint_name,
    kcu.ordinal_position;