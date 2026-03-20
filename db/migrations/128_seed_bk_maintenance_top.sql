ROLLBACK;
BEGIN;

-- =========================================================
-- 128_seed_bk_maintenance_top.sql
-- Vybrané BK targety přesuneme do BK_MAINTENANCE_TOP
-- =========================================================

UPDATE ops.ingest_targets
SET run_group = 'BK_MAINTENANCE_TOP'
WHERE id IN (
    939,   -- ABA League
    1945,  -- ACB
    2056,  -- BBL
    788,   -- Champions League
    1022,  -- Euroleague
    796,   -- Lega A
    799,   -- LKL
    3313,  -- NBA
    2406,  -- CBA
    1966   -- NBL Australia
);

COMMIT;