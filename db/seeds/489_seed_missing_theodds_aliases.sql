-- 489_seed_missing_theodds_aliases.sql
-- bezpečné aliasy pro existující týmy

INSERT INTO public.team_aliases (
    team_id,
    alias,
    source
)
VALUES
    (35250, 'Junior FC', 'theodds'),
    (35256, 'Rosario Central', 'theodds')
ON CONFLICT DO NOTHING;

-- kontrola
SELECT
    ta.team_id,
    t.name,
    ta.alias,
    ta.source
FROM public.team_aliases ta
JOIN public.teams t ON t.id = ta.team_id
WHERE ta.alias IN ('Junior FC', 'Rosario Central');