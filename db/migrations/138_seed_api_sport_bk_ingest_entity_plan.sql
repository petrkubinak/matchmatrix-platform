ROLLBACK;
BEGIN;

-- =========================================================
-- 138_seed_api_sport_bk_ingest_entity_plan.sql
-- Doplnění ingest_entity_plan pro provider=api_sport, sport_code=BK
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
    'api_sport' AS provider,
    ser.sport_code,
    ser.entity,
    ser.priority,
    ser.is_enabled,
    COALESCE(ser.notes, 'seed for api_sport basketball'),
    NOW(),
    NOW()
FROM ops.sport_entity_rules ser
WHERE ser.sport_code = 'BK'
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_entity_plan iep
      WHERE iep.provider = 'api_sport'
        AND iep.sport_code = ser.sport_code
        AND iep.entity = ser.entity
  );

COMMIT;