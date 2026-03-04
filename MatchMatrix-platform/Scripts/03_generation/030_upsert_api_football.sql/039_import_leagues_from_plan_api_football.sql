-- 039_import_leagues_from_plan_api_football.sql
-- Vezme vybrané ligy z ops.league_import_plan a:
-- 1) založí/aktualizuje public.leagues (kanonické ligy)
-- 2) založí/aktualizuje public.league_provider_map
-- 3) založí/aktualizuje ops.ingest_targets

BEGIN;

-- 0) zajistit existenci providera v public.data_providers
INSERT INTO public.data_providers (code, name)
VALUES ('api-football', 'API-Football')
ON CONFLICT (code) DO NOTHING;

-- 1) Zdroj = import plán + staging (dedup)
WITH plan AS (
    SELECT *
    FROM ops.league_import_plan
    WHERE enabled = true
      AND provider = 'api-football'
),
src AS (
    SELECT
        p.provider,
        p.provider_league_id,
        p.sport_code,
        p.season AS target_season,
        p.tier,
        p.fixtures_days_back,
        p.fixtures_days_forward,
        p.odds_days_forward,
        p.max_requests_per_run,
        p.notes,

        s.league_id,
        s.season AS staging_season,
        s.name,
        s.country,
        s.country_code,
        s.country_id,
        COALESCE(s.is_cup, false) AS is_cup,
        COALESCE(s.is_international, false) AS is_international
    FROM plan p
    JOIN staging.v_api_football_leagues_latest_enriched s
      ON s.league_id::text = p.provider_league_id
),
sport AS (
    SELECT id, code
    FROM public.sports
),
existing_map AS (
    SELECT m.provider, m.provider_league_id, m.league_id
    FROM public.league_provider_map m
    JOIN src s
      ON s.provider = m.provider
     AND s.provider_league_id = m.provider_league_id
),
to_create AS (
    SELECT s.*
    FROM src s
    LEFT JOIN existing_map em
      ON em.provider = s.provider
     AND em.provider_league_id = s.provider_league_id
    WHERE em.league_id IS NULL
),

-- 2) Vytvořit kanonické ligy pro ty, které ještě nemají mapování
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
        sp.id AS sport_id,
        tc.name,
        tc.country,
        tc.provider AS ext_source,
        tc.provider_league_id AS ext_league_id,
        tc.country_id,
        tc.tier,
        tc.is_cup,
        tc.is_international,
        now(),
        now()
    FROM to_create tc
    JOIN sport sp ON sp.code = tc.sport_code
    RETURNING id, ext_source, ext_league_id
),

-- 3) Založit mapování (provider -> league_id)
upsert_map AS (
    INSERT INTO public.league_provider_map (league_id, provider, provider_league_id)
    SELECT
        il.id,
        il.ext_source AS provider,
        il.ext_league_id AS provider_league_id
    FROM ins_leagues il
    ON CONFLICT (provider, provider_league_id) DO UPDATE
      SET league_id = EXCLUDED.league_id,
          updated_at = now()
    RETURNING league_id, provider, provider_league_id
),

-- 4) Aktualizovat atributy kanonických lig i pro ty, které už existují (podle staging + plánu)
upd_existing_leagues AS (
    UPDATE public.leagues l
    SET
        name = s.name,
        country = s.country,
        country_id = COALESCE(s.country_id, l.country_id),
        tier = s.tier,
        is_cup = s.is_cup,
        is_international = s.is_international,
        updated_at = now()
    FROM src s
    JOIN public.league_provider_map m
      ON m.provider = s.provider
     AND m.provider_league_id = s.provider_league_id
     AND m.league_id = l.id
    RETURNING l.id
),

-- 5) Upsert ops.ingest_targets (unikát: provider+provider_league_id+season)
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
        s.sport_code,
        m.league_id AS canonical_league_id,
        s.provider,
        s.provider_league_id,
        s.target_season,
        true,
        s.tier,
        s.fixtures_days_back,
        s.fixtures_days_forward,
        s.odds_days_forward,
        s.max_requests_per_run,
        s.notes,
        now(),
        now()
    FROM src s
    JOIN public.league_provider_map m
      ON m.provider = s.provider
     AND m.provider_league_id = s.provider_league_id
    ON CONFLICT (provider, provider_league_id, season) DO UPDATE
      SET canonical_league_id = EXCLUDED.canonical_league_id,
          enabled            = EXCLUDED.enabled,
          tier               = EXCLUDED.tier,
          fixtures_days_back = EXCLUDED.fixtures_days_back,
          fixtures_days_forward = EXCLUDED.fixtures_days_forward,
          odds_days_forward  = EXCLUDED.odds_days_forward,
          max_requests_per_run = EXCLUDED.max_requests_per_run,
          notes              = EXCLUDED.notes,
          updated_at         = now()
    RETURNING id
)

SELECT
  (SELECT count(*) FROM src)                     AS plan_rows,
  (SELECT count(*) FROM to_create)               AS new_leagues_needed,
  (SELECT count(*) FROM ins_leagues)             AS leagues_inserted,
  (SELECT count(*) FROM upsert_map)              AS maps_inserted_or_updated,
  (SELECT count(*) FROM upd_existing_leagues)    AS leagues_updated,
  (SELECT count(*) FROM upsert_targets)          AS targets_upserted;

COMMIT;