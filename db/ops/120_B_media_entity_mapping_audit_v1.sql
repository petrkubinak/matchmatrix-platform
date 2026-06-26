/*
MATCHMATRIX SQL 120_B Media Entity Mapping Audit V1

CO TO JE:
- Audit napojení článků na sportovní entity.

K ČEMU TO JE:
- Zjistí, kolik článků je napojeno na týmy, hráče, ligy a zápasy.

KDE TO UVIDÍME:
- OPS / Media Command Center.

JAK SE TO VYUŽIJE:
- Připraví základ pro Match Context Engine.
*/

CREATE OR REPLACE VIEW ops.v_media_entity_mapping_audit_v1 AS
WITH articles_base AS (
    SELECT COUNT(*) AS total_articles
    FROM public.articles
),
team_map AS (
    SELECT COUNT(*) AS team_links,
           COUNT(DISTINCT article_id) AS articles_with_team
    FROM public.article_team_map
),
player_map AS (
    SELECT COUNT(*) AS player_links,
           COUNT(DISTINCT article_id) AS articles_with_player
    FROM public.article_player_map
),
league_map AS (
    SELECT COUNT(*) AS league_links,
           COUNT(DISTINCT article_id) AS articles_with_league
    FROM public.article_league_map
),
match_map AS (
    SELECT COUNT(*) AS match_links,
           COUNT(DISTINCT article_id) AS articles_with_match
    FROM public.article_match_map
)
SELECT
    ab.total_articles,

    tm.team_links,
    tm.articles_with_team,
    ROUND(tm.articles_with_team * 100.0 / NULLIF(ab.total_articles, 0), 2) AS team_mapping_pct,

    pm.player_links,
    pm.articles_with_player,
    ROUND(pm.articles_with_player * 100.0 / NULLIF(ab.total_articles, 0), 2) AS player_mapping_pct,

    lm.league_links,
    lm.articles_with_league,
    ROUND(lm.articles_with_league * 100.0 / NULLIF(ab.total_articles, 0), 2) AS league_mapping_pct,

    mm.match_links,
    mm.articles_with_match,
    ROUND(mm.articles_with_match * 100.0 / NULLIF(ab.total_articles, 0), 2) AS match_mapping_pct,

    now() AS audited_at
FROM articles_base ab
CROSS JOIN team_map tm
CROSS JOIN player_map pm
CROSS JOIN league_map lm
CROSS JOIN match_map mm;