-- 711_audit_hb_runtime_start_fix1.sql
-- KROK 1: zjistit skutečné sloupce v ops tabulkách

-- =========================================================
-- A) provider_sport_matrix struktura
-- =========================================================
select
    'provider_sport_matrix' as table_name,
    column_name,
    data_type
from information_schema.columns
where table_schema = 'ops'
  and table_name = 'provider_sport_matrix'
order by ordinal_position;

-- =========================================================
-- B) provider_entity_coverage struktura
-- =========================================================
select
    'provider_entity_coverage' as table_name,
    column_name,
    data_type
from information_schema.columns
where table_schema = 'ops'
  and table_name = 'provider_entity_coverage'
order by ordinal_position;

-- =========================================================
-- C) ingest_entity_plan struktura
-- =========================================================
select
    'ingest_entity_plan' as table_name,
    column_name,
    data_type
from information_schema.columns
where table_schema = 'ops'
  and table_name = 'ingest_entity_plan'
order by ordinal_position;

-- =========================================================
-- D) ingest_targets struktura
-- =========================================================
select
    'ingest_targets' as table_name,
    column_name,
    data_type
from information_schema.columns
where table_schema = 'ops'
  and table_name = 'ingest_targets'
order by ordinal_position;

-- =========================================================
-- E) runtime_entity_audit struktura
-- =========================================================
select
    'runtime_entity_audit' as table_name,
    column_name,
    data_type
from information_schema.columns
where table_schema = 'ops'
  and table_name = 'runtime_entity_audit'
order by ordinal_position;