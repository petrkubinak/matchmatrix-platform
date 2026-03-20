ROLLBACK;
BEGIN;

-- =========================================================
-- 108_seed_ops_ingest_entity_plan_multisport.sql
-- Naplnění / rozšíření ops.ingest_entity_plan pro multisport
-- =========================================================

-- Bezpečnost: tabulka musí existovat
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'ops'
          AND table_name = 'ingest_entity_plan'
    ) THEN
        RAISE EXCEPTION 'Tabulka ops.ingest_entity_plan neexistuje.';
    END IF;
END $$;

-- Vložíme entity z ops.sport_entity_rules do ingest_entity_plan
-- Jen pokud tam daná kombinace sport_code + entity ještě není.
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
    COALESCE(ser.notes, 'multisport seed from ops.sport_entity_rules'),
    NOW(),
    NOW()
FROM ops.sport_entity_rules ser
JOIN ops.provider_sport_matrix psm
  ON psm.sport_code = ser.sport_code
 AND psm.is_enabled = TRUE
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.ingest_entity_plan iep
    WHERE iep.sport_code = ser.sport_code
      AND iep.entity = ser.entity
      AND iep.provider = psm.provider
);

COMMIT;