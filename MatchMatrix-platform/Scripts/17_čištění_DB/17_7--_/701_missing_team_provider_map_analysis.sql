-- 701_missing_team_provider_map_analysis.sql

SELECT
    f.provider,
    f.sport_code,
    f.external_league_id,
    f.season,
    f.home_team_external_id,
    f.away_team_external_id,
    COUNT(*) AS missing_count
FROM staging.stg_provider_fixtures f
LEFT JOIN public.team_provider_map h
    ON h.provider = f.provider
   AND h.provider_team_id = f.home_team_external_id
LEFT JOIN public.team_provider_map a
    ON a.provider = f.provider
   AND a.provider_team_id = f.away_team_external_id
WHERE h.team_id IS NULL
   OR a.team_id IS NULL
GROUP BY
    f.provider,
    f.sport_code,
    f.external_league_id,
    f.season,
    f.home_team_external_id,
    f.away_team_external_id
ORDER BY missing_count DESC,
         f.provider,
         f.sport_code
LIMIT 200;