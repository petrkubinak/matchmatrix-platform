/*
MATCHMATRIX
037_players_multisource_foundation.sql

Cíl:
- připravit databázový základ pro další zdroje hráčských dat
- oddělit canonical player od provider-specific profile
- připravit planner pro enrichment
*/

-- =========================================================
-- 1) STAGING: RAW PAYLOADS PRO DALŠÍ PLAYER ZDROJE
-- =========================================================

CREATE TABLE IF NOT EXISTS staging.stg_player_source_payloads (
    id bigserial PRIMARY KEY,
    provider text NOT NULL,
    sport_code text NOT NULL,
    entity_type text NOT NULL DEFAULT 'player_profile',
    external_player_id text NULL,
    external_team_id text NULL,
    external_league_id text NULL,
    season text NULL,
    endpoint_name text NULL,
    request_url text NULL,
    request_params jsonb NULL,
    payload_json jsonb NOT NULL,
    parse_status text NOT NULL DEFAULT 'pending',
    fetched_at timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_stg_player_source_payloads_provider
    ON staging.stg_player_source_payloads(provider);

CREATE INDEX IF NOT EXISTS idx_stg_player_source_payloads_player
    ON staging.stg_player_source_payloads(provider, external_player_id);

CREATE INDEX IF NOT EXISTS idx_stg_player_source_payloads_team
    ON staging.stg_player_source_payloads(provider, external_team_id);

CREATE INDEX IF NOT EXISTS idx_stg_player_source_payloads_parse_status
    ON staging.stg_player_source_payloads(parse_status);


-- =========================================================
-- 2) STAGING: NORMALIZOVANÉ PROVIDER PLAYER PROFILES
-- =========================================================

CREATE TABLE IF NOT EXISTS staging.stg_provider_player_profiles (
    id bigserial PRIMARY KEY,
    provider text NOT NULL,
    sport_code text NOT NULL,
    external_player_id text NOT NULL,

    -- identity / bio
    player_name text NULL,
    first_name text NULL,
    last_name text NULL,
    display_name text NULL,
    short_name text NULL,
    birth_date date NULL,
    birth_place text NULL,
    birth_country text NULL,
    nationality text NULL,
    height_cm integer NULL,
    weight_kg integer NULL,
    preferred_foot text NULL,

    -- roster / squad
    shirt_number integer NULL,
    position_code text NULL,
    position_name text NULL,
    photo_url text NULL,
    is_injured boolean NULL,
    is_active boolean NULL,

    -- current context
    external_team_id text NULL,
    team_name text NULL,
    external_league_id text NULL,
    league_name text NULL,
    season text NULL,

    -- lineage
    source_payload_id bigint NULL REFERENCES staging.stg_player_source_payloads(id) ON DELETE SET NULL,
    source_endpoint text NULL,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_stg_provider_player_profiles_provider_player
    ON staging.stg_provider_player_profiles(provider, external_player_id);

CREATE INDEX IF NOT EXISTS idx_stg_provider_player_profiles_team
    ON staging.stg_provider_player_profiles(provider, external_team_id);

CREATE INDEX IF NOT EXISTS idx_stg_provider_player_profiles_league
    ON staging.stg_provider_player_profiles(provider, external_league_id);

CREATE INDEX IF NOT EXISTS idx_stg_provider_player_profiles_season
    ON staging.stg_provider_player_profiles(season);


-- =========================================================
-- 3) PUBLIC: CANONICAL PLAYER EXTERNAL IDENTITIES
--    (mapuje canonical player na více externích provider IDs)
-- =========================================================

CREATE TABLE IF NOT EXISTS public.player_external_identity (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
    provider text NOT NULL,
    external_player_id text NOT NULL,

    external_team_id text NULL,
    external_league_id text NULL,
    season text NULL,

    confidence_score numeric(5,2) NULL,
    match_method text NULL,      -- exact_id / exact_name_birth / manual / imported
    is_primary boolean NOT NULL DEFAULT false,
    is_active boolean NOT NULL DEFAULT true,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_player_external_identity_provider_player
    ON public.player_external_identity(provider, external_player_id);

CREATE INDEX IF NOT EXISTS idx_player_external_identity_player
    ON public.player_external_identity(player_id);


-- =========================================================
-- 4) OPS: PLAYER ENRICHMENT PLAN
-- =========================================================

CREATE TABLE IF NOT EXISTS ops.player_enrichment_plan (
    id bigserial PRIMARY KEY,
    provider text NOT NULL,
    sport_code text NOT NULL DEFAULT 'football',
    entity text NOT NULL DEFAULT 'player_profile',

    player_id bigint NULL REFERENCES public.players(id) ON DELETE SET NULL,
    source_provider text NULL,           -- např. api_football
    source_external_player_id text NULL, -- hráč, od kterého enrichment startuje
    external_team_id text NULL,
    external_league_id text NULL,
    season text NULL,

    run_group text NULL,
    priority integer NOT NULL DEFAULT 50,
    status text NOT NULL DEFAULT 'pending', -- pending/running/done/error/skipped
    attempts integer NOT NULL DEFAULT 0,
    next_run timestamptz NULL DEFAULT now(),
    last_error text NULL,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_player_enrichment_plan_queue
    ON ops.player_enrichment_plan(status, next_run, priority, id);

CREATE INDEX IF NOT EXISTS idx_player_enrichment_plan_provider
    ON ops.player_enrichment_plan(provider, sport_code, entity);

CREATE UNIQUE INDEX IF NOT EXISTS ux_player_enrichment_plan_unique
    ON ops.player_enrichment_plan(
        provider,
        sport_code,
        entity,
        COALESCE(source_provider, ''),
        COALESCE(source_external_player_id, ''),
        COALESCE(season, '')
    );


-- =========================================================
-- 5) VIEW: QUEUE PRO WORKERY
-- =========================================================

CREATE OR REPLACE VIEW ops.v_player_enrichment_queue AS
SELECT
    id,
    provider,
    sport_code,
    entity,
    player_id,
    source_provider,
    source_external_player_id,
    external_team_id,
    external_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    next_run,
    last_error,
    created_at,
    updated_at
FROM ops.player_enrichment_plan
WHERE status IN ('pending', 'error')
  AND (next_run IS NULL OR next_run <= now());


-- =========================================================
-- 6) ZÁKLADNÍ PROVIDER REGISTRY
-- =========================================================

INSERT INTO ops.player_enrichment_plan (
    provider,
    sport_code,
    entity,
    source_provider,
    source_external_player_id,
    external_team_id,
    external_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    next_run
)
SELECT
    'api_football_squads' AS provider,
    'football' AS sport_code,
    'player_profile' AS entity,
    'api_football' AS source_provider,
    ppm.provider_player_id AS source_external_player_id,
    NULL,
    NULL,
    NULL,
    'PLAYERS_ENRICHMENT_PREP' AS run_group,
    20 AS priority,
    'pending' AS status,
    0 AS attempts,
    now() AS next_run
FROM public.player_provider_map ppm
WHERE ppm.provider = 'api_football'
  AND NOT EXISTS (
      SELECT 1
      FROM ops.player_enrichment_plan pep
      WHERE pep.provider = 'api_football_squads'
        AND pep.sport_code = 'football'
        AND pep.entity = 'player_profile'
        AND COALESCE(pep.source_provider, '') = 'api_football'
        AND COALESCE(pep.source_external_player_id, '') = COALESCE(ppm.provider_player_id, '')
  );