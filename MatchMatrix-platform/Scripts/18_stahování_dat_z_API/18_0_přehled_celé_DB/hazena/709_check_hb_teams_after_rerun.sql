-- 709_check_hb_teams_after_rerun.sql

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
  AND sport_code = 'HB'
  AND entity_type = 'teams'
ORDER BY id DESC
LIMIT 50;

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
  AND sport_code = 'HB'
ORDER BY id DESC
LIMIT 200;

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
  AND sport_code = 'HB'
GROUP BY provider, sport_code, external_league_id, season
ORDER BY external_league_id, season;