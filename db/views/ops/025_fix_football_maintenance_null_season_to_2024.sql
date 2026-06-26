BEGIN;

UPDATE ops.ingest_targets
SET
    season = '2024',
    updated_at = NOW(),
    notes = COALESCE(notes, '') || ' | season auto-set to 2024 for FREE maintenance mode'
WHERE provider = 'api_football'
  AND sport_code = 'football'
  AND run_group = 'FOOTBALL_MAINTENANCE'
  AND enabled = TRUE
  AND COALESCE(TRIM(season), '') = '';

COMMIT;