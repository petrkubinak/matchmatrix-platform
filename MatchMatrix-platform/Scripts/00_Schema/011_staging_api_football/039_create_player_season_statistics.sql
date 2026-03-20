-- ============================================================
-- MatchMatrix
-- 039_create_player_season_statistics.sql
-- ============================================================

CREATE TABLE IF NOT EXISTS staging.stg_provider_player_season_stats (
    id bigserial PRIMARY KEY,
    provider text NOT NULL,
    sport_code text NOT NULL,
    external_league_id text,
    season text,
    player_external_id text NOT NULL,
    team_external_id text,
    stat_name text NOT NULL,
    stat_value text,
    raw_payload_id bigint NOT NULL,
    source_endpoint text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_stg_player_season_stats_player
    ON staging.stg_provider_player_season_stats (provider, player_external_id);

CREATE INDEX IF NOT EXISTS ix_stg_player_season_stats_league_season
    ON staging.stg_provider_player_season_stats (provider, external_league_id, season);

CREATE INDEX IF NOT EXISTS ix_stg_player_season_stats_payload
    ON staging.stg_provider_player_season_stats (raw_payload_id);

CREATE INDEX IF NOT EXISTS ix_stg_player_season_stats_stat_name
    ON staging.stg_provider_player_season_stats (stat_name);

CREATE TABLE IF NOT EXISTS public.player_season_statistics (
    id bigserial PRIMARY KEY,
    player_id int NOT NULL REFERENCES public.players(id),
    team_id int NULL REFERENCES public.teams(id),
    sport_id int NULL REFERENCES public.sports(id),
    league_id int NULL REFERENCES public.leagues(id),
    season text NOT NULL,
    appearances int NULL,
    lineups int NULL,
    minutes_played int NULL,
    rating numeric(10,2) NULL,
    goals int NULL,
    assists int NULL,
    shots_total int NULL,
    shots_on_target int NULL,
    passes_total int NULL,
    passes_key int NULL,
    passes_accuracy numeric(10,2) NULL,
    tackles_total int NULL,
    tackles_blocks int NULL,
    tackles_interceptions int NULL,
    duels_total int NULL,
    duels_won int NULL,
    dribbles_attempts int NULL,
    dribbles_success int NULL,
    fouls_drawn int NULL,
    fouls_committed int NULL,
    yellow_cards int NULL,
    red_cards int NULL,
    penalty_won int NULL,
    penalty_committed int NULL,
    penalty_scored int NULL,
    penalty_missed int NULL,
    penalty_saved int NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_player_season_statistics_unique
    ON public.player_season_statistics (player_id, league_id, season);

CREATE INDEX IF NOT EXISTS ix_player_season_statistics_team
    ON public.player_season_statistics (team_id);

CREATE INDEX IF NOT EXISTS ix_player_season_statistics_league
    ON public.player_season_statistics (league_id);