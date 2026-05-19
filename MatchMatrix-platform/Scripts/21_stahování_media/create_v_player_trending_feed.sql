-- =========================================================
-- MATCHMATRIX
-- PLAYER TRENDING FEED VIEW
-- =========================================================
--
-- Co view dělá:
-- ---------------------------------------------------------
-- Připravuje hotový trending feed hráčů pro:
-- - web
-- - mobilní aplikaci
-- - API
-- - AI feed
--
-- Zdroj:
-- ---------------------------------------------------------
-- public.player_trending
-- public.players
--
-- Web/App:
-- ---------------------------------------------------------
-- Trending Players sekce
--
-- =========================================================

CREATE OR REPLACE VIEW public.v_player_trending_feed AS

SELECT
    pt.player_id,

    p.name AS player_name,

    pt.article_count,

    pt.trending_score,

    pt.last_article_at,

    pt.updated_at

FROM public.player_trending pt

JOIN public.players p
    ON p.id = pt.player_id

ORDER BY
    pt.trending_score DESC;