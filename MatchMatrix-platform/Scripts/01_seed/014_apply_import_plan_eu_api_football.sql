-- 014_apply_import_plan_eu_api_football.sql
-- Překlopí ops.league_import_plan (provider=api_football) do:
-- 1) public.leagues (canonical; ext_source='api_football', ext_league_id)
-- 2) public.league_provider_map
-- 3) ops.ingest_targets
-- Zdroj lig (název/země) bere z public.leagues ext_source='api_football' (už máš přesné názvy).

BEGIN;

-- 0) Ověření providera v public.data_providers (bezpečné)
INSERT INTO public.data_providers(code, name)
VALUES ('api_football', 'API-Football (API-Sports v3)')
ON CONFLICT (code) DO NOTHING;

-- 1) Zdroj = import plan + lookup přes public.leagues(ext_source='api_football')
WITH plan AS (
  SELECT *
  FROM ops.league_import_plan
  WHERE provider='api_football'
    AND enabled=true
    AND notes ILIKE 'EU exact v1%'
),
src AS (
  SELECT
    p.provider,
    p.provider_league_id,
    p.sport_code,
    p.season,
    p.tier,
    p.fixtures_days_back,
    p.fixtures_days_forward,
    p.odds_days_forward,
    p.max_requests_per_run,
    p.notes,

    l.name,
    l.country,
    l.country_id,
    COALESCE(l.is_cup,false) AS is_cup,
    COALESCE(l.is_international,false) AS is_international
  FROM plan p
  JOIN public.leagues l
    ON l.ext_source='api_football'
   AND l.ext_league_id::text = p.provider_league_id::text
   AND l.sport_id = 1
),
-- 2) zjisti, jestli už existuje canonical liga pro dané provider_league_id
existing AS (
  SELECT
    s.*,
    l2.id AS existing_league_id
  FROM src s
  LEFT JOIN public.leagues l2
    ON l2.ext_source='api_football'
   AND l2.ext_league_id::text = s.provider_league_id::text
   AND l2.sport_id = 1
),
-- 3) vlož canonical ligy (jen ty, které ještě nemají záznam)
ins_leagues AS (
  INSERT INTO public.leagues (
    sport_id,
    name,
    country,
    ext_source,
    ext_league_id,
    country_id,
    tier,
    is_cup,
    is_international,
    created_at,
    updated_at
  )
  SELECT
    1,
    e.name,
    e.country,
    'api_football',
    e.provider_league_id,
    e.country_id,
    e.tier,
    e.is_cup,
    e.is_international,
    now(),
    now()
  FROM existing e
  WHERE e.existing_league_id IS NULL
  RETURNING id, ext_league_id
),
-- 4) sjednoť league_id pro mapování (nové + existující)
canon AS (
  SELECT
    e.provider,
    e.provider_league_id,
    COALESCE(e.existing_league_id, il.id) AS canonical_league_id,
    e.sport_code,
    e.season,
    e.tier,
    e.fixtures_days_back,
    e.fixtures_days_forward,
    e.odds_days_forward,
    e.max_requests_per_run,
    e.notes
  FROM existing e
  LEFT JOIN ins_leagues il
    ON il.ext_league_id::text = e.provider_league_id::text
),
-- 5) upsert league_provider_map
upsert_map AS (
  INSERT INTO public.league_provider_map (league_id, provider, provider_league_id)
  SELECT
    c.canonical_league_id,
    c.provider,
    c.provider_league_id
  FROM canon c
  ON CONFLICT (provider, provider_league_id) DO UPDATE
    SET league_id = EXCLUDED.league_id,
        updated_at = now()
  RETURNING provider, provider_league_id, league_id
),
-- 6) upsert ops.ingest_targets
upsert_targets AS (
  INSERT INTO ops.ingest_targets (
    sport_code,
    canonical_league_id,
    provider,
    provider_league_id,
    season,
    enabled,
    tier,
    fixtures_days_back,
    fixtures_days_forward,
    odds_days_forward,
    max_requests_per_run,
    notes,
    created_at,
    updated_at
  )
  SELECT
    c.sport_code,
    c.canonical_league_id,
    c.provider,
    c.provider_league_id,
    COALESCE(c.season,''),
    true,
    COALESCE(c.tier,1),
    COALESCE(c.fixtures_days_back,2),
    COALESCE(c.fixtures_days_forward,3),
    COALESCE(c.odds_days_forward,0),
    COALESCE(c.max_requests_per_run,100),
    c.notes,
    now(),
    now()
  FROM canon c
  ON CONFLICT (provider, provider_league_id, season) DO UPDATE
    SET canonical_league_id = EXCLUDED.canonical_league_id,
        enabled = EXCLUDED.enabled,
        tier = EXCLUDED.tier,
        fixtures_days_back = EXCLUDED.fixtures_days_back,
        fixtures_days_forward = EXCLUDED.fixtures_days_forward,
        odds_days_forward = EXCLUDED.odds_days_forward,
        max_requests_per_run = EXCLUDED.max_requests_per_run,
        notes = EXCLUDED.notes,
        updated_at = now()
  RETURNING id
)

SELECT
  (SELECT count(*) FROM plan)          AS plan_rows,
  (SELECT count(*) FROM ins_leagues)   AS leagues_inserted,
  (SELECT count(*) FROM upsert_map)    AS maps_upserted,
  (SELECT count(*) FROM upsert_targets)AS targets_upserted;

COMMIT;