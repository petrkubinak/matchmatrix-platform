-- =====================================================================
-- 287_insert_missing_canonical_clubs_batch_2.sql
-- Vlozeni druhe davky chybejicich canonical klubu do public.teams
-- =====================================================================

INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id,
    created_at,
    updated_at,
    logo_url
)
SELECT
    v.team_name,
    'api_football_missing_canonical',
    v.external_team_id,
    NOW(),
    NOW(),
    NULL
FROM (
    VALUES
        ('9742','Antequera'),
        ('18785','Aral'),
        ('4314','Azul Claro Numazu'),
        ('7431','Bonnyrigg Rose Athletic'),
        ('9883','Brea'),
        ('4211','Buxoro'),
        ('17615','Caspe'),
        ('12762','Eltersdorf'),
        ('19220','Erlbach'),
        ('8158','Fraga')
) AS v(external_team_id, team_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.teams t
    WHERE LOWER(BTRIM(t.name)) = LOWER(BTRIM(v.team_name))
);