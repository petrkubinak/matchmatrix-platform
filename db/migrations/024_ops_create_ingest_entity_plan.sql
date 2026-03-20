BEGIN;

-- =========================================================
-- MATCHMATRIX
-- 036_ops_create_ingest_entity_plan.sql
-- Centrálni matice sport × provider × entity
-- =========================================================

CREATE TABLE IF NOT EXISTS ops.ingest_entity_plan (
    id BIGSERIAL PRIMARY KEY,
    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,
    entity TEXT NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    priority INTEGER NOT NULL DEFAULT 100,

    -- global = 1 job pro sport/provider
    -- league = 1 job per league
    -- league_season = 1 job per league+season
    -- enrichment = enrich pipeline / navazny krok
    scope_type TEXT NOT NULL DEFAULT 'league_season',

    requires_league BOOLEAN NOT NULL DEFAULT TRUE,
    requires_season BOOLEAN NOT NULL DEFAULT TRUE,

    default_run_group TEXT,
    ingest_mode TEXT NOT NULL DEFAULT 'daily',

    source_endpoint TEXT,
    target_table TEXT,
    worker_script TEXT,
    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_ingest_entity_plan UNIQUE (provider, sport_code, entity),
    CONSTRAINT chk_ingest_entity_plan_scope_type
        CHECK (scope_type IN ('global', 'league', 'league_season', 'enrichment')),
    CONSTRAINT chk_ingest_entity_plan_ingest_mode
        CHECK (ingest_mode IN ('bootstrap', 'daily', 'maintenance', 'backfill', 'enrichment'))
);

-- updated_at trigger
DROP TRIGGER IF EXISTS trg_ingest_entity_plan_set_updated_at ON ops.ingest_entity_plan;

CREATE TRIGGER trg_ingest_entity_plan_set_updated_at
BEFORE UPDATE ON ops.ingest_entity_plan
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- ---------------------------------------------------------
-- FOOTBALL: základní entity
-- ---------------------------------------------------------

INSERT INTO ops.ingest_entity_plan (
    provider,
    sport_code,
    entity,
    enabled,
    priority,
    scope_type,
    requires_league,
    requires_season,
    default_run_group,
    ingest_mode,
    source_endpoint,
    target_table,
    worker_script,
    notes
)
VALUES
(
    'api_football',
    'football',
    'leagues',
    TRUE,
    10,
    'global',
    FALSE,
    FALSE,
    'FOOTBALL_MAINTENANCE',
    'maintenance',
    '/leagues',
    'staging.stg_provider_leagues',
    NULL,
    'Globální metadata lig. 1 job pro provider+sport.'
),
(
    'api_football',
    'football',
    'teams',
    TRUE,
    20,
    'league_season',
    TRUE,
    TRUE,
    'FOOTBALL_MAINTENANCE',
    'daily',
    '/teams',
    'staging.stg_provider_teams',
    NULL,
    'Týmy pro konkrétní ligu a sezonu.'
),
(
    'api_football',
    'football',
    'fixtures',
    TRUE,
    30,
    'league_season',
    TRUE,
    TRUE,
    'FOOTBALL_MAINTENANCE',
    'daily',
    '/fixtures',
    'staging.stg_provider_fixtures',
    NULL,
    'Zápasy pro konkrétní ligu a sezonu.'
),
(
    'api_football',
    'football',
    'odds',
    TRUE,
    40,
    'league_season',
    TRUE,
    TRUE,
    'FOOTBALL_MAINTENANCE',
    'daily',
    '/odds',
    'staging.stg_provider_odds',
    NULL,
    'Kurzy pro konkrétní ligu a sezonu.'
),
(
    'api_football',
    'football',
    'players',
    TRUE,
    50,
    'league_season',
    TRUE,
    TRUE,
    'FOOTBALL_MAINTENANCE',
    'maintenance',
    '/players',
    'staging.players_import',
    'pull_api_football_players_v4.py',
    'Základní ingest hráčů do import vrstvy.'
),
(
    'api_football',
    'football',
    'player_profiles',
    TRUE,
    60,
    'enrichment',
    TRUE,
    TRUE,
    'FOOTBALL_MAINTENANCE',
    'enrichment',
    '/players/squads',
    'staging.stg_provider_player_profiles',
    'pull_api_football_players_squads_v1.py',
    'Profily hráčů a team-based enrichment.'
),
(
    'api_football',
    'football',
    'player_season_stats',
    TRUE,
    70,
    'league_season',
    TRUE,
    TRUE,
    'FOOTBALL_MAINTENANCE',
    'maintenance',
    '/players',
    'staging.stg_provider_player_season_stats',
    'run_players_season_stats_bridge_v3.py',
    'Sezónní statistiky hráčů z players importu.'
),
(
    'api_football',
    'football',
    'player_stats',
    TRUE,
    80,
    'league_season',
    TRUE,
    TRUE,
    'FOOTBALL_MAINTENANCE',
    'maintenance',
    NULL,
    'staging.stg_provider_player_stats',
    NULL,
    'Rezerva pro detailnější player stats / future match-level stats.'
)
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    enabled = EXCLUDED.enabled,
    priority = EXCLUDED.priority,
    scope_type = EXCLUDED.scope_type,
    requires_league = EXCLUDED.requires_league,
    requires_season = EXCLUDED.requires_season,
    default_run_group = EXCLUDED.default_run_group,
    ingest_mode = EXCLUDED.ingest_mode,
    source_endpoint = EXCLUDED.source_endpoint,
    target_table = EXCLUDED.target_table,
    worker_script = EXCLUDED.worker_script,
    notes = EXCLUDED.notes,
    updated_at = NOW();

COMMIT;