-- 715_check_hb_145_183_teams_after_pull.sql

-- 1) raw payloady
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
  AND entity_type = 'teams'
  AND external_id IN ('145_2024', '183_2024')
ORDER BY id DESC;

-- 2) staging teams
SELECT
    id,
    provider,
    sport_code,
    external_team_id,
    team_name,
    external_league_id,
    season,
    raw_payload_id,
    is_active,
    created_at,
    updated_at
FROM staging.stg_provider_teams
WHERE provider = 'api_handball'
  AND sport_code = 'handball'
  AND external_league_id IN ('145', '183')
  AND season = '2024'
ORDER BY external_league_id, team_name, external_team_id;

-- 3) souhrn
SELECT
    provider,
    sport_code,
    external_league_id,
    season,
    COUNT(*) AS rows_total,
    COUNT(DISTINCT external_team_id) AS teams_distinct
FROM staging.stg_provider_teams
WHERE provider = 'api_handball'
  AND sport_code = 'handball'
  AND external_league_id IN ('145', '183')
  AND season = '2024'
GROUP BY provider, sport_code, external_league_id, season
ORDER BY external_league_id, season;