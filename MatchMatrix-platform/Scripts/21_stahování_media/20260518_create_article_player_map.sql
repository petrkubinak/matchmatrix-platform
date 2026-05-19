-- =========================================================
-- MATCHMATRIX
-- ARTICLE ↔ PLAYER MEDIA MAP
-- =========================================================
--
-- Co to dělá:
-- Propojuje media články s hráči.
--
-- K čemu to je:
-- - player news feed
-- - trending players
-- - AI summaries
-- - media relevance
-- - highlights
-- - recommendation engine
--
-- Kde se to využije:
-- - profil hráče
-- - homepage feed
-- - trending sekce
-- - AI doporučení
--
-- Web/App výstup:
-- hráč → články → highlights → AI feed
--
-- =========================================================

CREATE TABLE IF NOT EXISTS public.article_player_map
(
    id BIGSERIAL PRIMARY KEY,

    article_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,

    match_type TEXT,
    match_source TEXT,

    matched_text TEXT,

    relevance_score NUMERIC(10,2) DEFAULT 0,

    is_primary_match BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT uq_article_player_map
    UNIQUE(article_id, player_id)
);

-- =========================================================
-- INDEXY
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_article_player_map_article
ON public.article_player_map(article_id);

CREATE INDEX IF NOT EXISTS idx_article_player_map_player
ON public.article_player_map(player_id);

CREATE INDEX IF NOT EXISTS idx_article_player_map_score
ON public.article_player_map(relevance_score DESC);

-- =========================================================
-- FK
-- =========================================================

ALTER TABLE public.article_player_map
ADD CONSTRAINT fk_article_player_map_article
FOREIGN KEY(article_id)
REFERENCES public.articles(id)
ON DELETE CASCADE;

ALTER TABLE public.article_player_map
ADD CONSTRAINT fk_article_player_map_player
FOREIGN KEY(player_id)
REFERENCES public.players(id)
ON DELETE CASCADE;