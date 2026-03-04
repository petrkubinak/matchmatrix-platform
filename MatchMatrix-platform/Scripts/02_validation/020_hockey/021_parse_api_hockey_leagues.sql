BEGIN;

-- 0) jistota že staging parsed tabulka existuje (pokud už ji máš, nic se nestane)
CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.api_hockey_leagues (
  run_id        int8,
  league_id     int4,
  season        int4,
  name          text,
  type          text,
  country       text,
  country_code  text,
  logo          text,
  is_cup        bool,
  is_international bool,
  raw           jsonb,
  fetched_at    timestamptz NOT NULL DEFAULT now()
);

-- 1) vyčistit parsed pro run_id (ať je to idempotentní)
DELETE FROM staging.api_hockey_leagues
WHERE run_id = :run_id;

-- 2) parse: 1 row = league × season
INSERT INTO staging.api_hockey_leagues (
  run_id, league_id, season, name, type, country, country_code, logo, is_cup, is_international, raw, fetched_at
)
SELECT
  r.run_id,
  (j->>'id')::int AS league_id,
  (s->>'season')::int AS season,
  j->>'name' AS name,
  j->>'type' AS type,
  j->'country'->>'name' AS country,
  j->'country'->>'code' AS country_code,
  j->>'logo' AS logo,
  NULL::bool AS is_cup,
  NULL::bool AS is_international,
  j AS raw,
  r.fetched_at
FROM staging.api_hockey_leagues_raw r
CROSS JOIN LATERAL jsonb_array_elements(r.payload->'response') AS j
CROSS JOIN LATERAL jsonb_array_elements(j->'seasons') AS s
WHERE r.run_id = :run_id;

COMMIT;