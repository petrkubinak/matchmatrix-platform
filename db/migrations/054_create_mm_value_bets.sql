-- ============================================================
-- MatchMatrix
-- Table: mm_value_bets
-- Popis:
-- ukládá value betting signály z ML modelu
-- ============================================================

CREATE TABLE IF NOT EXISTS public.mm_value_bets (

    id BIGSERIAL PRIMARY KEY,

    match_id BIGINT NOT NULL,

    league_id INT,
    match_date TIMESTAMP,

    home_team TEXT,
    away_team TEXT,

    -- model probabilities
    model_p_home NUMERIC,
    model_p_draw NUMERIC,
    model_p_away NUMERIC,

    -- bookmaker odds
    odds_home NUMERIC,
    odds_draw NUMERIC,
    odds_away NUMERIC,

    -- bookmaker implied probabilities
    book_p_home NUMERIC,
    book_p_draw NUMERIC,
    book_p_away NUMERIC,

    -- edges
    edge_home NUMERIC,
    edge_draw NUMERIC,
    edge_away NUMERIC,

    -- recommended pick
    recommended_pick TEXT,

    created_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_mm_value_bets_match
ON public.mm_value_bets(match_id);

CREATE INDEX idx_mm_value_bets_edge
ON public.mm_value_bets(edge_home, edge_draw, edge_away);