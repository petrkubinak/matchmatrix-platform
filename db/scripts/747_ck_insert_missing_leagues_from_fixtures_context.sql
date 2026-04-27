-- 747_ck_insert_missing_leagues_from_fixtures_context.sql

INSERT INTO public.leagues (
    sport_id,
    name,
    country,
    ext_source,
    ext_league_id,
    created_at,
    updated_at,
    is_active
)
SELECT DISTINCT
    14 AS sport_id,
    COALESCE(spl.league_name, 'CK League ' || f.external_league_id) AS name,
    spl.country_name AS country,
    'api_cricket' AS ext_source,
    f.external_league_id AS ext_league_id,
    now(),
    now(),
    true
FROM staging.stg_provider_fixtures f
LEFT JOIN staging.stg_provider_leagues spl
    ON spl.provider = 'api_cricket'
   AND spl.sport_code = 'CK'
   AND spl.external_league_id = f.external_league_id
LEFT JOIN public.leagues l
    ON l.ext_source = 'api_cricket'
   AND l.ext_league_id = f.external_league_id
   AND l.sport_id = 14
WHERE f.provider = 'api_cricket'
  AND f.sport_code = 'CK'
  AND l.id IS NULL;