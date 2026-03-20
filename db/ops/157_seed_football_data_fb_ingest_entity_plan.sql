ROLLBACK;
BEGIN;

-- =========================================================
-- 157_seed_football_data_fb_ingest_entity_plan.sql
-- Doplnění ingest_entity_plan pro provider=football_data, sport_code=FB
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
    'football_data' AS provider,
    ser.sport_code,
    ser.entity,
    ser.priority,
    ser.is_enabled,
    COALESCE(ser.notes, 'seed for football_data football'),
    NOW(),
    NOW()
FROM ops.sport_entity_rules ser
WHERE ser.sport_code = 'FB'
  AND ser.entity IN ('leagues', 'teams', 'fixtures', 'odds')
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_entity_plan iep
      WHERE iep.provider = 'football_data'
        AND iep.sport_code = ser.sport_code
        AND iep.entity = ser.entity
  );

COMMIT;

-- kontrola
SELECT
    provider,
    sport_code,
    entity,
    enabled
FROM ops.ingest_entity_plan
WHERE sport_code = 'FB'
  AND provider IN ('api_football', 'football_data')
ORDER BY provider, entity;