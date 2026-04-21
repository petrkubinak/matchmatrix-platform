-- 732_audit_hb_stg_provider_leagues_structure.sql
-- Cíl: zjistit realnou strukturu staging.stg_provider_leagues
-- a teprve potom auditovat HB leagues staging

-- 1) struktura tabulky
SELECT
    c.ordinal_position,
    c.column_name,
    c.data_type
FROM information_schema.columns c
WHERE c.table_schema = 'staging'
  AND c.table_name = 'stg_provider_leagues'
ORDER BY c.ordinal_position;

-- 2) rychly nahled na posledni radky
SELECT *
FROM staging.stg_provider_leagues
ORDER BY created_at DESC
LIMIT 20;