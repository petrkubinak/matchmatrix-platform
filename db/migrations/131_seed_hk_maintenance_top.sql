ROLLBACK;
BEGIN;

-- =========================================================
-- 131_seed_hk_maintenance_top.sql
-- Vybrané HK targety přesuneme do HK_MAINTENANCE_TOP
-- =========================================================

UPDATE ops.ingest_targets
SET run_group = 'HK_MAINTENANCE_TOP'
WHERE id IN (
    2124, -- Champions League
    2135, -- DEL
    2146, -- Extraliga Czech Republic
    2220, -- Hockey Allsvenskan
    2233, -- KHL
    2259, -- National League
    2140, -- NHL
    2299, -- SHL
    2213, -- Swiss League
    2230  -- Tipos Extraliga
);

COMMIT;