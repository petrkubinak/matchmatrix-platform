-- 718_check_hb_145_183_fixtures_after_error_batch.sql

SELECT
    external_league_id,
    season,
    COUNT(*) AS rows_total,
    COUNT(DISTINCT external_fixture_id) AS fixtures_distinct
FROM staging.stg_provider_fixtures
WHERE provider = 'api_handball'
  AND sport_code = 'handball'
  AND external_league_id IN ('145', '183')
  AND season = '2024'
GROUP BY external_league_id, season
ORDER BY external_league_id, season;

SELECT
    id,
    provider,
    sport_code,
    external_fixture_id,
    external_league_id,
    season,
    home_team_external_id,
    away_team_external_id,
    fixture_date,
    status_text,
    home_score,
    away_score,
    raw_payload_id,
    created_at,
    updated_at
FROM staging.stg_provider_fixtures
WHERE provider = 'api_handball'
  AND sport_code = 'handball'
  AND external_league_id IN ('145', '183')
  AND season = '2024'
ORDER BY external_league_id, fixture_date DESC, external_fixture_id
LIMIT 200;

SELECT
    id,
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    external_id,
    season,
    fetched_at,
    parse_status,
    parse_message,
    created_at
FROM staging.stg_api_payloads
WHERE provider = 'api_handball'
  AND sport_code = 'handball'
  AND entity_type = 'fixtures'
  AND external_id IN ('145_2024', '183_2024')
ORDER BY id DESC;