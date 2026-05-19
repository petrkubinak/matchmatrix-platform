BEGIN;

-- =========================================================
-- TRENDING PLAYERS
-- =========================================================

CREATE TABLE IF NOT EXISTS public.media_trending_players (
    player_id BIGINT PRIMARY KEY,

    article_count INTEGER NOT NULL DEFAULT 0,
    total_score NUMERIC(10,2) NOT NULL DEFAULT 0,
    trending_score NUMERIC(10,2) NOT NULL DEFAULT 0,

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT media_trending_players_player_id_fkey
    FOREIGN KEY (player_id)
    REFERENCES public.players(id)
    ON DELETE CASCADE
);

-- =========================================================
-- TRENDING TEAMS
-- =========================================================

CREATE TABLE IF NOT EXISTS public.media_trending_teams (
    team_id BIGINT PRIMARY KEY,

    article_count INTEGER NOT NULL DEFAULT 0,
    total_score NUMERIC(10,2) NOT NULL DEFAULT 0,
    trending_score NUMERIC(10,2) NOT NULL DEFAULT 0,

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT media_trending_teams_team_id_fkey
    FOREIGN KEY (team_id)
    REFERENCES public.teams(id)
    ON DELETE CASCADE
);

-- =========================================================
-- TRENDING LEAGUES
-- =========================================================

CREATE TABLE IF NOT EXISTS public.media_trending_leagues (
    league_id BIGINT PRIMARY KEY,

    article_count INTEGER NOT NULL DEFAULT 0,
    total_score NUMERIC(10,2) NOT NULL DEFAULT 0,
    trending_score NUMERIC(10,2) NOT NULL DEFAULT 0,

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT media_trending_leagues_league_id_fkey
    FOREIGN KEY (league_id)
    REFERENCES public.leagues(id)
    ON DELETE CASCADE
);

COMMIT;