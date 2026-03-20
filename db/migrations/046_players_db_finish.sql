-- MatchMatrix
-- 046_players_db_finish.sql

BEGIN;

-- =========================================================
-- PUBLIC: player_season_statistics
-- doplnění sloupců, pokud někde ještě chybí
-- =========================================================
ALTER TABLE public.player_season_statistics
    ADD COLUMN IF NOT EXISTS provider text,
    ADD COLUMN IF NOT EXISTS sport_code text DEFAULT 'football',
    ADD COLUMN IF NOT EXISTS season_id bigint,
    ADD COLUMN IF NOT EXISTS league_id integer,
    ADD COLUMN IF NOT EXISTS team_id integer,
    ADD COLUMN IF NOT EXISTS player_id bigint,
    ADD COLUMN IF NOT EXISTS provider_player_id text,
    ADD COLUMN IF NOT EXISTS provider_team_id text,
    ADD COLUMN IF NOT EXISTS provider_league_id text,
    ADD COLUMN IF NOT EXISTS season_code text,

    ADD COLUMN IF NOT EXISTS appearances integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS lineups integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS minutes_played integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS rating numeric(6,2),

    ADD COLUMN IF NOT EXISTS goals integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS assists integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS shots_total integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS shots_on integer NOT NULL DEFAULT 0,

    ADD COLUMN IF NOT EXISTS passes_total integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS passes_key integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS passes_accuracy numeric(6,2),

    ADD COLUMN IF NOT EXISTS tackles_total integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS duels_total integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS duels_won integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS dribbles_attempts integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS dribbles_success integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS fouls_drawn integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS fouls_committed integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS yellow_cards integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS red_cards integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS penalty_won integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS penalty_committed integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS penalty_scored integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS penalty_missed integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS penalty_saved integer NOT NULL DEFAULT 0,

    ADD COLUMN IF NOT EXISTS raw_payload_id bigint,
    ADD COLUMN IF NOT EXISTS raw_json jsonb,
    ADD COLUMN IF NOT EXISTS source_endpoint text,
    ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true,
    ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
    ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'uq_player_season_statistics_row'
          AND conrelid = 'public.player_season_statistics'::regclass
    ) THEN
        ALTER TABLE public.player_season_statistics
            ADD CONSTRAINT uq_player_season_statistics_row
            UNIQUE (provider, player_id, team_id, league_id, season_code);
    END IF;
END $$;

-- =========================================================
-- PUBLIC: player_match_statistics
-- source metadata pro budoucí merge/debug
-- =========================================================
ALTER TABLE public.player_match_statistics
    ADD COLUMN IF NOT EXISTS provider text,
    ADD COLUMN IF NOT EXISTS sport_code text DEFAULT 'football',
    ADD COLUMN IF NOT EXISTS provider_player_id text,
    ADD COLUMN IF NOT EXISTS provider_team_id text,
    ADD COLUMN IF NOT EXISTS provider_fixture_id text,
    ADD COLUMN IF NOT EXISTS raw_payload_id bigint,
    ADD COLUMN IF NOT EXISTS raw_json jsonb,
    ADD COLUMN IF NOT EXISTS source_endpoint text;

-- =========================================================
-- PUBLIC: player_provider_map
-- rozšíření mapování
-- =========================================================
ALTER TABLE public.player_provider_map
    ADD COLUMN IF NOT EXISTS provider_league_id text,
    ADD COLUMN IF NOT EXISTS season_code text,
    ADD COLUMN IF NOT EXISTS source_endpoint text;

-- =========================================================
-- STAGING: stg_provider_players
-- doplnění audit sloupců
-- =========================================================
ALTER TABLE staging.stg_provider_players
    ADD COLUMN IF NOT EXISTS external_league_id text,
    ADD COLUMN IF NOT EXISTS source_endpoint text,
    ADD COLUMN IF NOT EXISTS raw_json jsonb;

-- =========================================================
-- INDEXY
-- =========================================================
CREATE INDEX IF NOT EXISTS ix_player_season_statistics_player
    ON public.player_season_statistics (player_id);

CREATE INDEX IF NOT EXISTS ix_player_season_statistics_team
    ON public.player_season_statistics (team_id);

CREATE INDEX IF NOT EXISTS ix_player_season_statistics_league
    ON public.player_season_statistics (league_id);

CREATE INDEX IF NOT EXISTS ix_player_season_statistics_season
    ON public.player_season_statistics (season_id);

CREATE INDEX IF NOT EXISTS ix_player_season_statistics_provider
    ON public.player_season_statistics (provider, provider_player_id);

CREATE INDEX IF NOT EXISTS ix_player_season_statistics_sport_season
    ON public.player_season_statistics (sport_code, season_code);

CREATE INDEX IF NOT EXISTS ix_player_match_statistics_provider_fixture
    ON public.player_match_statistics (provider, provider_fixture_id);

CREATE INDEX IF NOT EXISTS ix_player_provider_map_provider_team
    ON public.player_provider_map (provider, provider_team_id);

CREATE INDEX IF NOT EXISTS ix_stg_provider_player_season_stats_lookup
    ON staging.stg_provider_player_season_stats (provider, provider_player_id, external_team_id, external_league_id, season);

CREATE INDEX IF NOT EXISTS ix_stg_provider_player_stats_lookup
    ON staging.stg_provider_player_stats (provider, external_fixture_id, external_player_id);

CREATE INDEX IF NOT EXISTS ix_stg_provider_player_stats_team
    ON staging.stg_provider_player_stats (external_team_id);

COMMIT;