-- 036_create_staging_league_views.sql
-- Deduplikace staging.api_football_leagues logicky přes VIEW (bez mazání dat)

BEGIN;

-- 1) poslední záznam pro každé league_id (priorita: nejvyšší run_id, pak fetched_at)
CREATE OR REPLACE VIEW staging.v_api_football_leagues_latest AS
SELECT DISTINCT ON (league_id)
    run_id,
    league_id,
    season,
    name,
    type,
    country,
    country_code,
    is_cup,
    is_international,
    logo,
    raw,
    fetched_at
FROM staging.api_football_leagues
ORDER BY league_id, run_id DESC, fetched_at DESC;

-- 2) enrich o countries (kontinent, country_id) – join podle iso2 = country_code
CREATE OR REPLACE VIEW staging.v_api_football_leagues_latest_enriched AS
SELECT
    l.*,
    c.id              AS country_id,
    c.continent_code  AS continent_code
FROM staging.v_api_football_leagues_latest l
LEFT JOIN public.countries c
       ON c.iso2 = l.country_code;

COMMIT;