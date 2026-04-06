-- 496_g_seed_remaining_clear_aliases.sql
-- Cíl:
-- doplnit jen jasně potvrzené aliasy ze zbývajících TEAM_NOT_MAPPED

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT v.team_id, v.alias, 'audit_496_remaining_clear_alias'
FROM (
    VALUES
        (35253, 'cerro porteno'),
        (6,     'gremio'),
        (605,   'independiente medellin'),
        (35232, 'la guaira'),
        (27876, 'ucv')
) AS v(team_id, alias)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE LOWER(a.alias) = LOWER(v.alias)
);