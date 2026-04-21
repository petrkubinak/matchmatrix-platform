-- =====================================================================
-- 290_insert_missing_canonical_clubs_batch_5.sql
-- Vlozeni pate davky chybejicich canonical klubu do public.teams
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
        ('23309','Olimpik-Mobiuz'),
        ('19043','Orion'),
        ('7138','Osaka'),
        ('6777','Peterhead'),
        ('24634','Poortugaal'),
        ('21422','RKAVV'),
        ('19266','Roosendaal'),
        ('25318','Safa Baku'),
        ('4222','Shortan'),
        ('3903','SJC Noordwijk')
) AS v(external_team_id, team_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.teams t
    WHERE LOWER(BTRIM(t.name)) = LOWER(BTRIM(v.team_name))
);