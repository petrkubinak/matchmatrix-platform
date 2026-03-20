-- MatchMatrix - Players DB completion (core/public)
-- Ulozit do: C:\MatchMatrix-platform\db\migrations\046_players_core_completion.sql

BEGIN;

-- 1) Finalni sezonni statistiky hracu v public vrstve
CREATE TABLE IF NOT EXISTS public.player_season_statistics (
    id bigserial PRIMARY KEY,
    provider text NOT NULL,
    sport_code text NOT NULL DEFAULT 'football',
    season_id bigint,
    league_id integer,
    team_id integer,
    player_id bigint NOT NULL,
    provider_player_id text,
    provider_team_id text,
    provider_league_id text,
    season_code text,

    appearances integer NOT NULL DEFAULT 0,
    lineups integer NOT NULL DEFAULT 0,
    minutes_played integer NOT NULL DEFAULT 0,
    rating numeric(6,2),

    goals integer NOT NULL DEFAULT 0,
    assists integer NOT NULL DEFAULT 0,
    shots_total integer NOT NULL DEFAULT 0,
    shots_on integer NOT NULL DEFAULT 0,

    passes_total integer NOT NULL DEFAULT 0,
    passes_key integer NOT NULL DEFAULT 0,
    passes_accuracy numeric(6,2),

    tackles_total integer NOT NULL DEFAULT 0,
    duels_total integer NOT NULL DEFAULT 0,
    duels_won integer NOT NULL DEFAULT 0,
    dribbles_attempts integer NOT NULL DEFAULT 0,
    dribbles_success integer NOT NULL DEFAULT 0,
    fouls_drawn integer NOT NULL DEFAULT 0,
    fouls_committed integer NOT NULL DEFAULT 0,
    yellow_cards integer NOT NULL DEFAULT 0,
    red_cards integer NOT NULL DEFAULT 0,
    penalty_won integer NOT NULL DEFAULT 0,
    penalty_committed integer NOT NULL DEFAULT 0,
    penalty_scored integer NOT NULL DEFAULT 0,
    penalty_missed integer NOT NULL DEFAULT 0,
    penalty_saved integer NOT NULL DEFAULT 0,

    raw_payload_id bigint,
    raw_json jsonb,
    source_endpoint text,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_player_season_statistics_row UNIQUE (provider, player_id, team_id, league_id, season_code)
);

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

-- FK jen tam, kde tabulky existuji a chceme vazby na canonical vrstvu
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_player_season_statistics_player'
          AND conrelid = 'public.player_season_statistics'::regclass
    ) THEN
        ALTER TABLE public.player_season_statistics
            ADD CONSTRAINT fk_player_season_statistics_player
            FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_player_season_statistics_team'
          AND conrelid = 'public.player_season_statistics'::regclass
    ) THEN
        ALTER TABLE public.player_season_statistics
            ADD CONSTRAINT fk_player_season_statistics_team
            FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE SET NULL;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_player_season_statistics_league'
          AND conrelid = 'public.player_season_statistics'::regclass
    ) THEN
        ALTER TABLE public.player_season_statistics
            ADD CONSTRAINT fk_player_season_statistics_league
            FOREIGN KEY (league_id) REFERENCES public.leagues(id) ON DELETE SET NULL;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_player_season_statistics_season'
          AND conrelid = 'public.player_season_statistics'::regclass
    ) THEN
        ALTER TABLE public.player_season_statistics
            ADD CONSTRAINT fk_player_season_statistics_season
            FOREIGN KEY (season_id) REFERENCES public.seasons(id) ON DELETE SET NULL;
    END IF;
END $$;

-- 2) Player match statistics doplnit o source metadata pro merge/debug
ALTER TABLE public.player_match_statistics
    ADD COLUMN IF NOT EXISTS provider text,
    ADD COLUMN IF NOT EXISTS sport_code text DEFAULT 'football',
    ADD COLUMN IF NOT EXISTS provider_player_id text,
    ADD COLUMN IF NOT EXISTS provider_team_id text,
    ADD COLUMN IF NOT EXISTS provider_fixture_id text,
    ADD COLUMN IF NOT EXISTS raw_payload_id bigint,
    ADD COLUMN IF NOT EXISTS raw_json jsonb,
    ADD COLUMN IF NOT EXISTS source_endpoint text;

-- 3) Player provider map posilit o ligu/sezonu pro audit a budoucí multisource merge
ALTER TABLE public.player_provider_map
    ADD COLUMN IF NOT EXISTS provider_league_id text,
    ADD COLUMN IF NOT EXISTS season_code text,
    ADD COLUMN IF NOT EXISTS source_endpoint text;

-- 4) Indexy
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

COMMIT;
