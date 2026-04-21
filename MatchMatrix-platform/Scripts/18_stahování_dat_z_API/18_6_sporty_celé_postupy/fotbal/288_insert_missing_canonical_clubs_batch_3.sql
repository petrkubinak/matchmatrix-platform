-- =====================================================================
-- 288_insert_missing_canonical_clubs_batch_3.sql
-- Vlozeni treti davky chybejicich canonical klubu do public.teams
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
        ('6762','Clyde'),
        ('6764','East Fife'),
        ('6765','East Kilbride'),
        ('6766','Edinburgh City'),
        ('6767','Elgin City'),
        ('4250','Forfar Athletic'),
        ('20445','Fuentes'),
        ('12780','Hankofen-Hailing'),
        ('26096','Heino'),
        ('5570','Imisli FK')
) AS v(external_team_id, team_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.teams t
    WHERE LOWER(BTRIM(t.name)) = LOWER(BTRIM(v.team_name))
);