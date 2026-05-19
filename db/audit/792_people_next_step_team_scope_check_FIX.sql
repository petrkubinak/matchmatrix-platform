SELECT
    tpm.provider,
    'FB' AS sport_code,
    tpm.provider_team_id,
    t.name AS team_name,
    COUNT(DISTINCT m.id) AS matches_count
FROM public.team_provider_map tpm
JOIN public.teams t
    ON t.id = tpm.team_id
LEFT JOIN public.matches m
    ON m.home_team_id = t.id
    OR m.away_team_id = t.id
WHERE tpm.provider = 'api_football'
GROUP BY
    tpm.provider,
    tpm.provider_team_id,
    t.name
ORDER BY matches_count DESC, t.name
LIMIT 50;