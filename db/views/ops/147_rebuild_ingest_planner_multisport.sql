-- ============================================
-- 147_rebuild_ingest_planner_multisport.sql
-- FULL REBUILD ingest_planner z ingest_entity_plan
-- ============================================

BEGIN;

-- 1) vyčistíme planner
DELETE FROM ops.ingest_planner;

-- 2) rebuild planneru
INSERT INTO ops.ingest_planner (
    provider,
    sport_code,
    entity,
    season,
    priority,
    status,
    created_at,
    updated_at
)
SELECT
    iep.provider,
    iep.sport_code,
    iep.entity,

    -- sezóna logika (FREE MODE)
    CASE 
        WHEN iep.sport_code = 'FB' THEN 2022
        ELSE NULL
    END AS season,

    iep.priority,
    'pending' AS status,
    NOW(),
    NOW()
FROM ops.ingest_entity_plan iep
WHERE iep.enabled = TRUE;

COMMIT;