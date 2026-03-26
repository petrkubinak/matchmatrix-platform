--dotaz, zda je vytvořen instrukce pro worker
SELECT
    provider,
    sport_code,
    entity,
    source_endpoint,
    target_table
FROM ops.ingest_entity_plan
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB'
  AND entity = 'teams';

--vytvoření instrukce do ingest_entity_plan
UPDATE ops.ingest_entity_plan
SET
    source_endpoint = 'teams',
    target_table    = 'staging.stg_provider_teams',
    updated_at      = NOW()
WHERE provider   = 'api_volleyball'
  AND sport_code = 'VB'
  AND entity     = 'teams';