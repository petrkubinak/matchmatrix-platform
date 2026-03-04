BEGIN;

WITH base AS (
  SELECT
    l.ext_league_id::text AS provider_league_id,
    l.name,
    l.country
  FROM public.leagues l
  WHERE l.ext_source = 'api_football'
    AND l.sport_id = 1
    AND l.country IN (
      'Spain','Germany','Italy','France','Netherlands',
      'Portugal','Belgium','Austria','Switzerland',
      'Czech-Republic','Poland','Turkey'
    )
    AND l.name !~* '(women|u17|u18|u19|u20|u21|youth|cup|super|friendly|group|regional|reserves)'
),
tiered AS (
  SELECT *,
    CASE

      -- Spain
      WHEN country='Spain' AND name ILIKE '%La Liga%' AND name NOT ILIKE '%2%' THEN 1
      WHEN country='Spain' AND name ILIKE '%Segunda%' THEN 2
      WHEN country='Spain' AND name ILIKE '%Primera RFEF%' THEN 3

      -- Germany
      WHEN country='Germany' AND name ILIKE '%Bundesliga%' AND name NOT ILIKE '%2. Bundesliga%' THEN 1
      WHEN country='Germany' AND name ILIKE '%2. Bundesliga%' THEN 2
      WHEN country='Germany' AND name ILIKE '%3. Liga%' THEN 3

      -- Italy
      WHEN country='Italy' AND name ILIKE '%Serie A%' THEN 1
      WHEN country='Italy' AND name ILIKE '%Serie B%' THEN 2
      WHEN country='Italy' AND name ILIKE '%Serie C%' THEN 3

      -- France
      WHEN country='France' AND name ILIKE '%Ligue 1%' THEN 1
      WHEN country='France' AND name ILIKE '%Ligue 2%' THEN 2
      WHEN country='France' AND name ~* '\bNational\b' THEN 3

      -- Netherlands
      WHEN country='Netherlands' AND name ILIKE '%Eredivisie%' THEN 1
      WHEN country='Netherlands' AND name ILIKE '%Eerste Divisie%' THEN 2
      WHEN country='Netherlands' AND name ILIKE '%Tweede Divisie%' THEN 3

      -- Portugal
      WHEN country='Portugal' AND name ILIKE '%Primeira%' THEN 1
      WHEN country='Portugal' AND (name ILIKE '%Segunda%' OR name ILIKE '%Liga Portugal 2%') THEN 2
      WHEN country='Portugal' AND name ILIKE '%Liga 3%' THEN 3

      -- Belgium
      WHEN country='Belgium' AND name ILIKE '%Pro League%' THEN 1
      WHEN country='Belgium' AND (name ILIKE '%First Division B%' OR name ILIKE '%Challenger Pro League%') THEN 2
      WHEN country='Belgium' AND name ILIKE '%National 1%' THEN 3

      -- Austria
      WHEN country='Austria' AND name ILIKE '%Bundesliga%' THEN 1
      WHEN country='Austria' AND name ILIKE '%2. Liga%' THEN 2
      WHEN country='Austria' AND name ILIKE '%Regionalliga%' THEN 3

      -- Switzerland
      WHEN country='Switzerland' AND name ILIKE '%Super League%' THEN 1
      WHEN country='Switzerland' AND name ILIKE '%Challenge League%' THEN 2
      WHEN country='Switzerland' AND name ILIKE '%Promotion League%' THEN 3

      -- Czech
      WHEN country='Czech-Republic' AND name ILIKE '%1.%' THEN 1
      WHEN country='Czech-Republic' AND name ILIKE '%2.%' THEN 2
      WHEN country='Czech-Republic' AND name ILIKE '%3.%' THEN 3

      -- Poland
      WHEN country='Poland' AND name ILIKE '%Ekstraklasa%' THEN 1
      WHEN country='Poland' AND name ILIKE '%I Liga%' THEN 2
      WHEN country='Poland' AND name ILIKE '%II Liga%' THEN 3

      -- Turkey
      WHEN country='Turkey' AND (name ILIKE '%Süper Lig%' OR name ILIKE '%Super Lig%') THEN 1
      WHEN country='Turkey' AND name ILIKE '%1. Lig%' THEN 2
      WHEN country='Turkey' AND name ILIKE '%2. Lig%' THEN 3

      ELSE NULL
    END AS tier
  FROM base
)

INSERT INTO ops.league_import_plan
(provider, provider_league_id, sport_code, season, enabled, tier,
 fixtures_days_back, fixtures_days_forward, odds_days_forward, notes)
SELECT
  'api_football',
  provider_league_id,
  'football',
  '',
  true,
  tier,
  2,
  3,
  0,
  'EU major v4 | tier=' || tier || ' | ' || country || ' - ' || name
FROM tiered
WHERE tier IS NOT NULL
ON CONFLICT (provider, provider_league_id, season)
DO UPDATE SET
  enabled = true,
  tier = EXCLUDED.tier,
  notes = EXCLUDED.notes,
  updated_at = now();

COMMIT;