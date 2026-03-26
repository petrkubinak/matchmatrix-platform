SELECT
    provider,
    sport_code,
    COUNT(*) AS leagues_count
FROM staging.stg_provider_leagues
WHERE provider = 'api_volleyball'
  AND sport_code = 'volleyball'
GROUP BY provider, sport_code;

SELECT
    id,
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    external_id,
    season,
    parse_status,
    parse_message,
    payload_json ->> 'results' AS results,
    created_at
FROM staging.stg_api_payloads
WHERE provider = 'api_volleyball'
  AND sport_code = 'volleyball'
  AND entity_type = 'fixtures'
ORDER BY id DESC
LIMIT 3;

SELECT
    external_league_id,
    league_name,
    country_name,
    season
FROM staging.stg_provider_leagues
WHERE provider = 'api_volleyball'
  AND sport_code = 'volleyball'
ORDER BY league_name
LIMIT 50;

UPDATE ops.ingest_targets
SET provider_league_id = '66',
    season = '2022',
    notes = '1. Bundesliga',
    updated_at = now()
WHERE id = 4871;

SELECT
    id,
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    external_id,
    season,
    parse_status,
    parse_message,
    payload_json ->> 'results' AS results,
    created_at
FROM staging.stg_api_payloads
WHERE provider = 'api_volleyball'
  AND sport_code = 'volleyball'
  AND entity_type = 'fixtures'
ORDER BY id DESC
LIMIT 3;