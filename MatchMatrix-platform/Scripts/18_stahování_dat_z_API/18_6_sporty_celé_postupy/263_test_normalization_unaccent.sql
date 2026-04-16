SELECT
    team_name,
    public.normalize_team_name(team_name) AS normalized
FROM staging.stg_provider_teams
WHERE team_name ~ '\?'
ORDER BY team_name
LIMIT 50;