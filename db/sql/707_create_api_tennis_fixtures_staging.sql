-- 707_create_api_tennis_fixtures_staging.sql
-- Tennis fixtures staging skeleton

BEGIN;

-- =========================================================
-- 1) RAW payload
-- =========================================================
CREATE TABLE IF NOT EXISTS staging.api_tennis_fixtures_raw (
    id              bigserial PRIMARY KEY,
    run_id          bigint,
    provider        text NOT NULL DEFAULT 'api_tennis',
    sport_code      text NOT NULL DEFAULT 'TN',
    provider_match_id text,
    payload         jsonb NOT NULL,
    fetched_at      timestamptz NOT NULL DEFAULT now(),
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_tn_fx_raw_run_id
    ON staging.api_tennis_fixtures_raw (run_id);

-- =========================================================
-- 2) Parsed fixtures
-- =========================================================
CREATE TABLE IF NOT EXISTS staging.api_tennis_fixtures (
    id                  bigserial PRIMARY KEY,
    run_id              bigint,
    provider            text NOT NULL DEFAULT 'api_tennis',
    sport_code          text NOT NULL DEFAULT 'TN',
    provider_match_id   text,
    league_name         text,
    player_1            text,
    player_2            text,
    match_time          timestamptz,
    status              text,
    raw_payload         jsonb,
    parsed_at           timestamptz DEFAULT now(),
    created_at          timestamptz DEFAULT now(),
    updated_at          timestamptz DEFAULT now(),

    CONSTRAINT uq_tn_fx UNIQUE (provider, sport_code, provider_match_id)
);

-- =========================================================
-- 3) updated_at trigger
-- =========================================================
DROP TRIGGER IF EXISTS trg_tn_fx_updated ON staging.api_tennis_fixtures;

CREATE TRIGGER trg_tn_fx_updated
BEFORE UPDATE ON staging.api_tennis_fixtures
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at_generic();

COMMIT;