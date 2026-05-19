INSERT INTO public.team_aliases
(
    team_id,
    alias,
    source
)
SELECT DISTINCT
    t.id AS team_id,
    LOWER(t.name) AS alias,
    'media_seed_bk_hk_name' AS source
FROM public.teams t
WHERE t.ext_source IN ('api_sport', 'api_hockey')
  AND t.name IS NOT NULL
ON CONFLICT DO NOTHING;