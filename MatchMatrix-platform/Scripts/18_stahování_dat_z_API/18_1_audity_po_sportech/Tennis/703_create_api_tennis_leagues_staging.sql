-- 703_create_api_tennis_leagues_staging.sql
-- Tennis leagues/tournaments staging skeleton
-- 1) RAW payload table
-- 2) Parsed staging table
-- 3) latest view
-- 4) indexy pro pull + parser + merge flow

BEGIN;

-- =========================================================
-- 1) RAW payloads
-- =========================================================
CREATE TABLE IF NOT EXISTS staging.api_tennis_leagues_raw (
    id              bigserial PRIMARY KEY,
    run_id          bigint,
    provider        text NOT NULL DEFAULT 'api_tennis',
    sport_code      text NOT NULL DEFAULT 'TN',
    provider_league_id text,
    season          text,
    payload         jsonb NOT NULL,
    fetched_at      timestamptz NOT NULL DEFAULT now(),
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_api_tennis_leagues_raw_run_id
    ON staging.api_tennis_leagues_raw (run_id);

CREATE INDEX IF NOT EXISTS ix_api_tennis_leagues_raw_provider_league_id
    ON staging.api_tennis_leagues_raw (provider_league_id);

CREATE INDEX IF NOT EXISTS ix_api_tennis_leagues_raw_season
    ON staging.api_tennis_leagues_raw (season);

-- =========================================================
-- 2) Parsed leagues / tournaments
-- =========================================================
CREATE TABLE IF NOT EXISTS staging.api_tennis_leagues (
    id                  bigserial PRIMARY KEY,
    run_id              bigint,
    provider            text NOT NULL DEFAULT 'api_tennis',
    sport_code          text NOT NULL DEFAULT 'TN',
    provider_league_id  text NOT NULL,
    season              text NOT NULL,
    name                text NOT NULL,
    category            text,
    gender              text,
    surface             text,
    country             text,
    is_active           boolean DEFAULT true,
    raw_payload         jsonb,
    parsed_at           timestamptz NOT NULL DEFAULT now(),
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_api_tennis_leagues_unique
        UNIQUE (provider, sport_code, provider_league_id, season)
);

CREATE INDEX IF NOT EXISTS ix_api_tennis_leagues_provider_league_id
    ON staging.api_tennis_leagues (provider_league_id);

CREATE INDEX IF NOT EXISTS ix_api_tennis_leagues_season
    ON staging.api_tennis_leagues (season);

CREATE INDEX IF NOT EXISTS ix_api_tennis_leagues_name
    ON staging.api_tennis_leagues (name);

-- =========================================================
-- 3) updated_at trigger
-- =========================================================
DROP TRIGGER IF EXISTS trg_api_tennis_leagues_set_updated_at
ON staging.api_tennis_leagues;

CREATE TRIGGER trg_api_tennis_leagues_set_updated_at
BEFORE UPDATE ON staging.api_tennis_leagues
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at_generic();

-- =========================================================
-- 4) latest view
-- =========================================================
CREATE OR REPLACE VIEW staging.v_api_tennis_leagues_latest AS
SELECT DISTINCT ON (provider, sport_code, provider_league_id, season)
    id,
    run_id,
    provider,
    sport_code,
    provider_league_id,
    season,
    name,
    category,
    gender,
    surface,
    country,
    is_active,
    raw_payload,
    parsed_at,
    created_at,
    updated_at
FROM staging.api_tennis_leagues
ORDER BY provider, sport_code, provider_league_id, season, parsed_at DESC, id DESC;

COMMIT;