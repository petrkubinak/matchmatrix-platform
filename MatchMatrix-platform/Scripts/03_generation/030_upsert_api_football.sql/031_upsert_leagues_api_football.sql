-- 03_generation/031_upsert_leagues_api_football.sql
-- Param: :run_id
-- Source: staging.api_football_fixtures (bez potřeby staging.api_football_leagues)

WITH leagues_src AS (
  SELECT DISTINCT
    f.league_id::text AS ext_league_id,
    COALESCE(to_jsonb(f)->>'league_name', 'League ' || f.league_id::text) AS name,
    NULLIF(COALESCE(to_jsonb(f)->>'league_country', to_jsonb(f)->>'country', ''), '') AS country
  FROM staging.api_football_fixtures f
  WHERE f.run_id = :run_id
),
upsert_leagues AS (
  INSERT INTO public.leagues (
    sport_id, name, country, ext_source, ext_league_id,
    is_cup, is_international, enabled_theodds, country_id
  )
  SELECT
    1 AS sport_id,
    s.name,
    s.country,
    'api_football' AS ext_source,
    s.ext_league_id,
    false, false, false, NULL::int
  FROM leagues_src s
  ON CONFLICT (ext_source, ext_league_id) DO UPDATE
  SET
    name = EXCLUDED.name,
    country = EXCLUDED.country,
    updated_at = now()
  RETURNING id, ext_league_id
)
INSERT INTO public.league_provider_map (provider, provider_league_id, league_id)
SELECT
  'api_football' AS provider,
  l.ext_league_id AS provider_league_id,
  l.id AS league_id
FROM public.leagues l
JOIN leagues_src s
  ON l.ext_source = 'api_football'
 AND l.ext_league_id = s.ext_league_id
ON CONFLICT (provider, provider_league_id) DO UPDATE
SET league_id = EXCLUDED.league_id;