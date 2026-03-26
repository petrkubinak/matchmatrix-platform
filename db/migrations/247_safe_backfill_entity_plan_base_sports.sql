-- Safe backfill for base sports in ops.ingest_entity_plan
-- Fills only missing source_endpoint / target_table
-- Does NOT overwrite already populated values.

UPDATE ops.ingest_entity_plan
SET
    source_endpoint = COALESCE(source_endpoint, entity),
    target_table = COALESCE(
        target_table,
        CASE entity
            WHEN 'leagues'  THEN 'staging.stg_provider_leagues'
            WHEN 'teams'    THEN 'staging.stg_provider_teams'
            WHEN 'fixtures' THEN 'staging.stg_provider_fixtures'
            ELSE target_table
        END
    ),
    updated_at = NOW()
WHERE enabled = true
  AND sport_code IN ('FB', 'HK', 'BK', 'VB', 'HB', 'BSB', 'RGB', 'CK', 'FH', 'AFB')
  AND entity IN ('leagues', 'teams', 'fixtures')
  AND (
        source_endpoint IS NULL
     OR target_table IS NULL
  );