INSERT INTO ops.player_enrichment_plan (
    provider,
    sport_code,
    entity,
    external_team_id,
    external_league_id,
    season,
    run_group,
    status,
    priority
)
SELECT
    'api_sport' AS provider,
    'basketball' AS sport_code,
    'players' AS entity,
    t.external_team_id,
    t.external_league_id,
    t.season,
    'BK_PEOPLE' AS run_group,
    'pending' AS status,
    10 AS priority
FROM staging.stg_provider_teams t
WHERE t.provider = 'api_sport'
  AND t.sport_code = 'basketball'
  AND t.external_league_id = '117'
  AND t.season = '2023-2024';