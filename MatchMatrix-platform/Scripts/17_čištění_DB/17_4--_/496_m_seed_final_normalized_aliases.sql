-- 496_m_seed_final_normalized_aliases.sql
-- Cíl:
-- doplnit poslední 4 normalized aliasy pro exact match resolveru

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT v.team_id, v.alias, 'audit_496_final_normalized_alias'
FROM (
    VALUES
        (14,    'corinthians sp'),
        (17,    'flamengo rj'),
        (8,     'palmeiras sp'),
        (10979, 'universidad catolica chi')
) AS v(team_id, alias)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE LOWER(a.alias) = LOWER(v.alias)
);