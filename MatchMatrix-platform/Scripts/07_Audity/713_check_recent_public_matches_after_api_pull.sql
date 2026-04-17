SELECT
    id,
    ext_source,
    ext_match_id,
    kickoff,
    home_team_id,
    away_team_id,
    updated_at
FROM public.matches
ORDER BY updated_at DESC NULLS LAST
LIMIT 50;