SELECT
    provider,
    sport_code,
    external_team_id,
    team_name,
    external_league_id,
    season,
    created_at,
    updated_at
FROM staging.stg_provider_teams
WHERE provider = 'api_sport'
ORDER BY updated_at DESC
LIMIT 30;