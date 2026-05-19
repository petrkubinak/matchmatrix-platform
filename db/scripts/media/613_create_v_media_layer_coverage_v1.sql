CREATE OR REPLACE VIEW public.v_media_layer_coverage AS
SELECT
    COUNT(*) AS total_articles,
    COUNT(*) FILTER (WHERE COALESCE(article_quality_score, 0) >= 70) AS quality_70_plus,
    COUNT(*) FILTER (WHERE COALESCE(is_feed_eligible, false) = true) AS feed_eligible,
    COUNT(DISTINCT atm.article_id) AS team_linked_articles,
    COUNT(DISTINCT alm.article_id) AS league_linked_articles,
    COUNT(DISTINCT amm.article_id) AS match_linked_articles,
    COUNT(*) FILTER (
        WHERE COALESCE(article_quality_score, 0) >= 70
          AND amm.article_id IS NULL
    ) AS quality_unmatched_articles
FROM public.articles a
LEFT JOIN public.article_team_map atm ON atm.article_id = a.id
LEFT JOIN public.article_league_map alm ON alm.article_id = a.id
LEFT JOIN public.article_match_map amm ON amm.article_id = a.id;