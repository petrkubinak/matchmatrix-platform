-- check_media_layer_inventory_v1.sql
-- Kompletní kontrola MEDIA layer, aby se neopakovaly hotové věci.

-- 1) MEDIA tabulky / views v public
SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND (
       table_name LIKE '%article%'
    OR table_name LIKE '%media%'
    OR table_name LIKE '%alias%'
    OR table_name LIKE '%trending%'
  )
ORDER BY table_type, table_name;


-- 2) Počty hlavních MEDIA tabulek
SELECT 'articles' AS object_name, COUNT(*) AS rows_count FROM public.articles
UNION ALL
SELECT 'article_league_map', COUNT(*) FROM public.article_league_map
UNION ALL
SELECT 'article_team_map', COUNT(*) FROM public.article_team_map
UNION ALL
SELECT 'article_player_map', COUNT(*) FROM public.article_player_map
UNION ALL
SELECT 'article_match_map', COUNT(*) FROM public.article_match_map
UNION ALL
SELECT 'media_entity_aliases', COUNT(*) FROM public.media_entity_aliases;


-- 3) Aliasy podle typu
SELECT
    entity_type,
    COUNT(*) AS alias_count,
    COUNT(*) FILTER (WHERE is_active = true) AS active_alias_count
FROM public.media_entity_aliases
GROUP BY entity_type
ORDER BY entity_type;


-- 4) Coverage článků
SELECT
    COUNT(*) AS total_articles,
    COUNT(*) FILTER (WHERE COALESCE(article_quality_score, 0) >= 70) AS quality_70_plus,
    COUNT(*) FILTER (WHERE COALESCE(is_feed_eligible, false) = true) AS feed_eligible,
    COUNT(*) FILTER (WHERE published_at IS NOT NULL) AS with_published_at,
    COUNT(DISTINCT alm.article_id) AS league_linked_articles,
    COUNT(DISTINCT atm.article_id) AS team_linked_articles,
    COUNT(DISTINCT apm.article_id) AS player_linked_articles,
    COUNT(DISTINCT amm.article_id) AS match_linked_articles
FROM public.articles a
LEFT JOIN public.article_league_map alm ON alm.article_id = a.id
LEFT JOIN public.article_team_map atm ON atm.article_id = a.id
LEFT JOIN public.article_player_map apm ON apm.article_id = a.id
LEFT JOIN public.article_match_map amm ON amm.article_id = a.id;


-- 5) Existující MEDIA views
SELECT
    table_name AS view_name
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name LIKE 'v_media%'
ORDER BY table_name;


-- 6) Trending views / tabulky
SELECT
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name LIKE '%trending%'
ORDER BY table_name;