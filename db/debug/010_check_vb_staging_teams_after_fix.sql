SELECT
    sport_code,
    provider,
    COUNT(*) AS teams_count
FROM staging.stg_provider_teams
WHERE sport_code = 'volleyball'
GROUP BY sport_code, provider;