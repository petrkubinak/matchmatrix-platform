SELECT
    COUNT(*) AS api_football_matches,
    MAX(updated_at) AS last_updated_at
FROM public.matches
WHERE ext_source = 'api_football';