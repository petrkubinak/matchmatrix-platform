/*
===============================================================================
MATCHMATRIX SQL 117_D
HARVEST MEDIA READINESS V1
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_harvest_media_readiness_v1 AS
SELECT
    total_articles,
    quality_70_plus,
    feed_eligible,
    with_published_at,
    league_linked_articles,
    team_linked_articles,
    player_linked_articles,
    match_linked_articles,

    ROUND((quality_70_plus::numeric / NULLIF(total_articles,0)) * 100, 2) AS quality_pct,
    ROUND((feed_eligible::numeric / NULLIF(total_articles,0)) * 100, 2) AS feed_eligible_pct,
    ROUND((with_published_at::numeric / NULLIF(total_articles,0)) * 100, 2) AS published_at_pct,
    ROUND((league_linked_articles::numeric / NULLIF(total_articles,0)) * 100, 2) AS league_link_pct,
    ROUND((team_linked_articles::numeric / NULLIF(total_articles,0)) * 100, 2) AS team_link_pct,
    ROUND((player_linked_articles::numeric / NULLIF(total_articles,0)) * 100, 2) AS player_link_pct,
    ROUND((match_linked_articles::numeric / NULLIF(total_articles,0)) * 100, 2) AS match_link_pct,

    ROUND((
        COALESCE((quality_70_plus::numeric / NULLIF(total_articles,0)) * 20, 0) +
        COALESCE((feed_eligible::numeric / NULLIF(total_articles,0)) * 20, 0) +
        COALESCE((with_published_at::numeric / NULLIF(total_articles,0)) * 10, 0) +
        COALESCE((league_linked_articles::numeric / NULLIF(total_articles,0)) * 20, 0) +
        COALESCE((team_linked_articles::numeric / NULLIF(total_articles,0)) * 10, 0) +
        COALESCE((player_linked_articles::numeric / NULLIF(total_articles,0)) * 10, 0) +
        COALESCE((match_linked_articles::numeric / NULLIF(total_articles,0)) * 10, 0)
    ), 2) AS media_readiness_score,

    CASE
        WHEN total_articles = 0 THEN 'MEDIA_EMPTY'
        WHEN match_linked_articles = 0 THEN 'MEDIA_MATCH_LINK_GAP'
        WHEN feed_eligible < 100 THEN 'MEDIA_FEED_LOW'
        ELSE 'MEDIA_READY'
    END AS media_readiness_status,

    CASE
        WHEN total_articles = 0
            THEN 'Spustit media ingest a merge do public.articles.'
        WHEN match_linked_articles = 0
            THEN 'Doplnit article_match_map / matcher článků na konkrétní zápasy.'
        WHEN team_linked_articles < total_articles * 0.5
            THEN 'Zlepšit team entity matcher.'
        WHEN player_linked_articles < total_articles * 0.5
            THEN 'Zlepšit player entity matcher.'
        ELSE 'Media vrstva je použitelná pro harvest a web feed.'
    END AS recommendation_cz

FROM public.v_media_layer_coverage;