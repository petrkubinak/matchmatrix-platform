-- 909_trace_bk_public_sources.sql

SELECT
    'public.leagues' AS area,
    ext_source AS source,
    COUNT(*) AS rows_count
FROM public.leagues
WHERE sport_id = 3
GROUP BY ext_source

UNION ALL

SELECT
    'public.matches',
    ext_source,
    COUNT(*)
FROM public.matches
WHERE sport_id = 3
GROUP BY ext_source

UNION ALL

SELECT
    'public.team_provider_map',
    provider,
    COUNT(*)
FROM public.team_provider_map
WHERE provider ILIKE '%basket%'
   OR provider ILIKE '%sport%'
GROUP BY provider

ORDER BY area, source;