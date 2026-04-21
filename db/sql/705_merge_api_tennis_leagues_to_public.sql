-- 705_merge_api_tennis_leagues_to_public.sql
-- TN leagues merge: staging.api_tennis_leagues -> public.leagues

BEGIN;

-- =========================================================
-- 1) INSERT nových TN leagues do public.leagues
-- =========================================================
INSERT INTO public.leagues (
    sport_id,
    name,
    country,
    ext_source,
    ext_league_id,
    is_cup,
    is_international,
    is_active,
    created_at,
    updated_at
)
SELECT
    s.id AS sport_id,
    stl.name,
    stl.country,
    'api_tennis' AS ext_source,
    stl.provider_league_id AS ext_league_id,
    false AS is_cup,
    true AS is_international,
    stl.is_active,
    now(),
    now()
FROM staging.v_api_tennis_leagues_latest stl
JOIN public.sports s
  ON s.code = 'TN'
LEFT JOIN public.leagues pl
  ON pl.ext_source = 'api_tennis'
 AND pl.ext_league_id = stl.provider_league_id
WHERE pl.id IS NULL;

-- =========================================================
-- 2) UPDATE existujících TN leagues
-- =========================================================
UPDATE public.leagues pl
SET
    name = stl.name,
    country = stl.country,
    is_active = stl.is_active,
    updated_at = now()
FROM staging.v_api_tennis_leagues_latest stl
WHERE pl.ext_source = 'api_tennis'
  AND pl.ext_league_id = stl.provider_league_id;

COMMIT;