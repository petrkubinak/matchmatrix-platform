ROLLBACK;
BEGIN;

-- =========================================================
-- 117_fix_ingest_targets_sport_codes.sql
-- Sjednocení starých sport_code v ops.ingest_targets
-- =========================================================

UPDATE ops.ingest_targets
SET sport_code = CASE
    WHEN sport_code = 'football'   THEN 'FB'
    WHEN sport_code = 'basketball' THEN 'BK'
    WHEN sport_code = 'hockey'     THEN 'HK'
    ELSE sport_code
END
WHERE sport_code IN ('football', 'basketball', 'hockey');

COMMIT;