-- 496_j_seed_last_clear_aliases.sql
-- Cíl:
-- doplnit poslední jasně potvrzené aliasy

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT v.team_id, v.alias, 'audit_496_last_clear_alias'
FROM (
    VALUES
        (35253, 'cerro porteno'),
        (6,     'gremio'),
        (605,   'independiente medellin'),
        (35250, 'junior'),
        (35232, 'la guaira'),
        (27876, 'ucv')
) AS v(team_id, alias)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE LOWER(a.alias) = LOWER(v.alias)
);