-- ============================================
-- 228_fill_default_run_groups_multisport.sql
-- Napojení entity_plan → CORE/TOP vrstvy
-- ============================================

BEGIN;

-- =========================================================
-- FOOTBALL (NECHÁVÁME SPECIÁLNÍ)
-- =========================================================

UPDATE ops.ingest_entity_plan
SET default_run_group = 'FB_BOOTSTRAP_V1'
WHERE provider = 'api_football'
  AND sport_code = 'FB';

UPDATE ops.ingest_entity_plan
SET default_run_group = 'FB_FD_CORE'
WHERE provider = 'football_data'
  AND sport_code = 'FB';

-- =========================================================
-- HOCKEY
-- =========================================================

UPDATE ops.ingest_entity_plan
SET default_run_group = 'HK_TOP'
WHERE provider = 'api_hockey'
  AND sport_code = 'HK';

-- =========================================================
-- BASKETBALL
-- =========================================================

UPDATE ops.ingest_entity_plan
SET default_run_group = 'BK_TOP'
WHERE sport_code = 'BK';

-- =========================================================
-- MULTISPORT CORE (NOVÉ SPORTY)
-- =========================================================

UPDATE ops.ingest_entity_plan
SET default_run_group = 'TN_CORE'
WHERE sport_code = 'TN';

UPDATE ops.ingest_entity_plan
SET default_run_group = 'MMA_CORE'
WHERE sport_code = 'MMA';

UPDATE ops.ingest_entity_plan
SET default_run_group = 'VB_CORE'
WHERE sport_code = 'VB';

UPDATE ops.ingest_entity_plan
SET default_run_group = 'HB_CORE'
WHERE sport_code = 'HB';

UPDATE ops.ingest_entity_plan
SET default_run_group = 'BSB_CORE'
WHERE sport_code = 'BSB';

UPDATE ops.ingest_entity_plan
SET default_run_group = 'RGB_CORE'
WHERE sport_code = 'RGB';

UPDATE ops.ingest_entity_plan
SET default_run_group = 'CK_CORE'
WHERE sport_code = 'CK';

UPDATE ops.ingest_entity_plan
SET default_run_group = 'FH_CORE'
WHERE sport_code = 'FH';

UPDATE ops.ingest_entity_plan
SET default_run_group = 'AFB_CORE'
WHERE sport_code = 'AFB';

UPDATE ops.ingest_entity_plan
SET default_run_group = 'ESP_CORE'
WHERE sport_code = 'ESP';

UPDATE ops.ingest_entity_plan
SET default_run_group = 'DRT_CORE'
WHERE sport_code = 'DRT';

COMMIT;