-- 717_check_hb_145_183_teams_after_batch.sql

SELECT
    external_league_id,
    season,
    COUNT(*) AS rows_total,
    COUNT(DISTINCT external_team_id) AS teams_distinct
FROM staging.stg_provider_teams
WHERE provider = 'api_handball'
  AND sport_code = 'handball'
  AND external_league_id IN ('145','183')
  AND season = '2024'
GROUP BY external_league_id, season
ORDER BY external_league_id, season;

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
    created_at
FROM staging.stg_provider_teams
WHERE provider = 'api_handball'
  AND sport_code = 'handball'
  AND external_league_id IN ('145','183')
  AND season = '2024'
ORDER BY external_league_id, team_name, external_team_id
LIMIT 200;