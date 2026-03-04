SELECT provider, count(*) AS cnt
FROM public.league_provider_map
GROUP BY provider
ORDER BY cnt DESC, provider;


SELECT
  l.id AS canonical_league_id,
  l.country,
  l.name,
  m.provider,
  m.provider_league_id
FROM public.leagues l
JOIN public.league_provider_map m ON m.league_id = l.id
WHERE m.provider = 'api_football'
  AND (
    l.name ILIKE '%Premier League%' OR
    l.name ILIKE '%La Liga%' OR
    l.name ILIKE '%Bundesliga%' OR
    l.name ILIKE '%Serie A%' OR
    l.name ILIKE '%Ligue 1%' OR
    l.name ILIKE '%Eredivisie%' OR
    l.name ILIKE '%Primeira%' OR
    l.name ILIKE '%World Cup%'
  )
ORDER BY l.country, l.name;

SELECT provider, enabled, count(*)
FROM ops.ingest_targets
GROUP BY provider, enabled
ORDER BY provider, enabled;

SELECT * FROM public.data_providers ORDER BY code;


INSERT INTO public.data_providers(code, name)
VALUES ('api_football', 'API-Football')
ON CONFLICT (code) DO NOTHING;

SELECT
  l.id AS league_id,
  l.name,
  l.country,
  count(lt.team_id) AS teams_in_league
FROM public.leagues l
JOIN public.league_provider_map m
  ON m.league_id = l.id
LEFT JOIN public.league_teams lt
  ON lt.league_id = l.id
WHERE m.provider = 'api_football'
GROUP BY l.id, l.name, l.country
ORDER BY teams_in_league ASC, l.country, l.name;

DELETE FROM ops.ingest_targets
WHERE provider = 'api_football'
  AND provider_league_id = '39'
  AND season = '2024';

UPDATE ops.ingest_targets
SET
  fixtures_days_back = 2,
  fixtures_days_forward = 3,
  odds_days_forward = 0,
  max_requests_per_run = 100,
  updated_at = now(),
  notes = 'TOP8 free-mode (2 back / 3 fwd / budget 100)'
WHERE provider = 'api_football'
  AND enabled = true;

ALTER TABLE ops.ingest_targets
ADD COLUMN IF NOT EXISTS run_group text;

UPDATE ops.ingest_targets
SET run_group = CASE
  WHEN provider_league_id IN ('39','140','78','135') THEN 'A'
  WHEN provider_league_id IN ('61','88','94','40') THEN 'B'
  ELSE run_group
END
WHERE provider='api_football';

SELECT provider_league_id, season, fixtures_days_back, fixtures_days_forward, max_requests_per_run, notes
FROM ops.ingest_targets
WHERE provider='api_football' AND enabled=true
ORDER BY provider_league_id;

SELECT league_id, name, country, country_code
FROM staging.v_api_football_leagues_run103
WHERE country_code IS NOT NULL
  AND COALESCE(is_international,false)=false
  AND COALESCE(is_cup,false)=false
  AND name !~* '(women|u17|u18|u19|u20|u21|youth|reserves|friendly)'
  AND country_code IN ('GB-ENG','EN','ES','DE','IT','FR','NL','PT','BE','AT','CH','CZ','PL','SVK','BG','DK','HR','CY','GB-IE','RO','GB-SCO','SI','TR','GB-WAL')
ORDER BY country, name;