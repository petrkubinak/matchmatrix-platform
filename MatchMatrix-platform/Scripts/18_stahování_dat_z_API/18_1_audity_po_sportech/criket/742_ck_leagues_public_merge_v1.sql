-- 742_ck_leagues_public_merge_v1.sql

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
    4, -- CK sport_id, případně upravíme pokud máš jiné ID pro cricket
    s.league_name,
    s.country_name,
    'api_cricket',
    s.external_league_id,
    now(),
    now(),
    true
FROM staging.stg_provider_leagues s
LEFT JOIN public.leagues l
    ON l.ext_source = 'api_cricket'
   AND l.ext_league_id = s.external_league_id
WHERE s.provider = 'api_cricket'
  AND s.sport_code = 'CK'
  AND l.id IS NULL;