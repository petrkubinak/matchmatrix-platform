/*
MATCHMATRIX SQL 120_L Match Context Summary V1

CO TO JE:
- Univerzální dashboard stavu Match Context vrstvy.

K ČEMU TO JE:
- Ukáže, jak dobře jsou články napojené na týmy, hráče, ligy a zápasy.

KDE TO UVIDÍME:
- OPS / Media Command Center / Match Context Engine.

JAK SE TO VYUŽIJE:
- Základ pro univerzální vyhledávání a kontext na webu.
*/

CREATE OR REPLACE VIEW ops.v_match_context_summary_v1 AS
WITH base AS (
    SELECT COUNT(*) AS total_articles
    FROM public.articles
),
team_map AS (
    SELECT COUNT(DISTINCT article_id) AS articles_with_team
    FROM public.article_team_map
),
player_map AS (
    SELECT COUNT(DISTINCT article_id) AS articles_with_player
    FROM public.article_player_map
),
league_map AS (
    SELECT COUNT(DISTINCT article_id) AS articles_with_league
    FROM public.article_league_map
),
match_map AS (
    SELECT COUNT(DISTINCT article_id) AS articles_with_match
    FROM public.article_match_map
)
SELECT
    b.total_articles,

    tm.articles_with_team,
    ROUND(tm.articles_with_team * 100.0 / NULLIF(b.total_articles, 0), 2) AS team_coverage_pct,

    pm.articles_with_player,
    ROUND(pm.articles_with_player * 100.0 / NULLIF(b.total_articles, 0), 2) AS player_coverage_pct,

    lm.articles_with_league,
    ROUND(lm.articles_with_league * 100.0 / NULLIF(b.total_articles, 0), 2) AS league_coverage_pct,

    mm.articles_with_match,
    ROUND(mm.articles_with_match * 100.0 / NULLIF(b.total_articles, 0), 2) AS match_coverage_pct,

    ROUND((
        COALESCE(tm.articles_with_team * 100.0 / NULLIF(b.total_articles, 0), 0) +
        COALESCE(pm.articles_with_player * 100.0 / NULLIF(b.total_articles, 0), 0) +
        COALESCE(lm.articles_with_league * 100.0 / NULLIF(b.total_articles, 0), 0) +
        COALESCE(mm.articles_with_match * 100.0 / NULLIF(b.total_articles, 0), 0)
    ) / 4, 2) AS match_context_readiness_pct,

    now() AS updated_at
FROM base b
CROSS JOIN team_map tm
CROSS JOIN player_map pm
CROSS JOIN league_map lm
CROSS JOIN match_map mm;