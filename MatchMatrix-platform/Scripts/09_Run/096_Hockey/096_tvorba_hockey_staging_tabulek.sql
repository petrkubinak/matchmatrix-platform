
--Provider do DB (data_providers má jen code+name)
INSERT INTO public.data_providers (code, name)
VALUES ('api_hockey', 'API-Hockey (API-Sports v1)')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name;

--Staging tabulky (podobně jako football, startujeme jen leagues)
CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.api_hockey_leagues (
  run_id       bigint NOT NULL,
  league_id    int4   NOT NULL,
  season       int4   NULL,
  name         text   NULL,
  type         text   NULL,
  country      text   NULL,
  country_code text   NULL,
  logo         text   NULL,
  raw          jsonb  NOT NULL,
  fetched_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_api_hockey_leagues_run ON staging.api_hockey_leagues(run_id);
CREATE INDEX IF NOT EXISTS ix_api_hockey_leagues_league ON staging.api_hockey_leagues(league_id);

-- 1)Kontrola payloadu a vzorek
SELECT COUNT(*) AS cnt, MIN(fetched_at), MAX(fetched_at)
FROM staging.api_hockey_leagues_raw
WHERE run_id = 1;
-- 2)vzorek
SELECT payload
FROM staging.api_hockey_leagues_raw
WHERE run_id = 1
LIMIT 1;

SELECT c.relname AS table_name
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'staging'
  AND c.relkind = 'r'
  AND c.relname ILIKE '%hockey%league%';

SELECT 'staging.api_hockey_leagues' AS tbl, COUNT(*) AS cnt FROM staging.api_hockey_leagues
UNION ALL
SELECT 'staging.api_hockey_leagues_raw' AS tbl, COUNT(*) AS cnt FROM staging.api_hockey_leagues_raw;