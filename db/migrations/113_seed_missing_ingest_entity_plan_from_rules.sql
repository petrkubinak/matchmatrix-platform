ROLLBACK;
BEGIN;

-- =========================================================
-- 113_seed_missing_ingest_entity_plan_from_rules.sql
-- Dosypání chybějících kombinací do ops.ingest_entity_plan
-- z ops.sport_entity_rules × ops.provider_sport_matrix
-- =========================================================

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
    COALESCE(ser.notes, 'seed from ops.sport_entity_rules'),
    NOW(),
    NOW()
FROM ops.sport_entity_rules ser
JOIN ops.provider_sport_matrix psm
  ON psm.sport_code = ser.sport_code
 AND psm.is_enabled = TRUE
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.ingest_entity_plan iep
    WHERE iep.provider   = psm.provider
      AND iep.sport_code = ser.sport_code
      AND iep.entity     = ser.entity
);

COMMIT;