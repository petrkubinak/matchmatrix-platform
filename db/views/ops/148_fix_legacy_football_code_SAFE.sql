BEGIN;

-- 1) smažeme legacy záznamy (football)
DELETE FROM ops.ingest_entity_plan
WHERE sport_code = 'football';

COMMIT;