-- ============================================
-- MATCHMATRIX - HOCKEY RUN GROUPS (HK) FIX
-- ============================================

-- 1) Nejprve všechno vyčistit
UPDATE ops.ingest_targets
SET run_group = NULL
WHERE sport_code = 'HK';

-- --------------------------------------------

-- 2) HK_CORE = základ (všechno)
UPDATE ops.ingest_targets
SET run_group = 'HK_CORE'
WHERE sport_code = 'HK';

-- --------------------------------------------

-- 3) HK_TOP (ručně omezíme malý subset)
-- zatím vezmeme prvních 20 lig jako TOP test vrstvu

UPDATE ops.ingest_targets
SET run_group = 'HK_TOP'
WHERE id IN (
    SELECT id
    FROM ops.ingest_targets
    WHERE sport_code = 'HK'
    ORDER BY id
    LIMIT 20
);

-- --------------------------------------------

-- 4) Kontrola
SELECT
    sport_code,
    run_group,
    COUNT(*) AS target_count
FROM ops.ingest_targets
WHERE sport_code = 'HK'
GROUP BY sport_code, run_group
ORDER BY run_group;