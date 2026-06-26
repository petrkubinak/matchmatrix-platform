-- ============================================
-- EXPAND ingest_entity_plan TO ALL SPORTS
-- (bez mazání existujících dat)
-- ============================================

BEGIN;

INSERT INTO ops.ingest_entity_plan (
    provider,
    sport_code,
    entity,
    priority,
    enabled,
    notes,
    created_at,
    updated_at
)
SELECT
    psm.provider,
    ser.sport_code,
    ser.entity,
    ser.priority,
    ser.is_enabled,
    'auto expand multisport',
    NOW(),
    NOW()
FROM ops.sport_entity_rules ser
JOIN ops.provider_sport_matrix psm
  ON psm.sport_code = ser.sport_code
 AND psm.is_enabled = TRUE
LEFT JOIN ops.ingest_entity_plan iep
  ON iep.provider   = psm.provider
 AND iep.sport_code = ser.sport_code
 AND iep.entity     = ser.entity
WHERE iep.provider IS NULL;  -- jen chybějící

COMMIT;