-- check_media_mapping_inputs_v1.sql
-- Diagnostika proč article -> match kandidáti vychází prázdně.

-- 1) Počty základních media map tabulek
SELECT 'articles' AS table_name, COUNT(*) AS rows_count FROM public.articles
UNION ALL
SELECT 'article_team_map', COUNT(*) FROM public.article_team_map
UNION ALL
SELECT 'article_league_map', COUNT(*) FROM public.article_league_map
UNION ALL
SELECT 'article_match_map', COUNT(*) FROM public.article_match_map;


-- 2) Kvalita článků a published_at
SELECT
    COUNT(*) AS total_articles,
    COUNT(*) FILTER (WHERE published_at IS NOT NULL) AS with_published_at,
    COUNT(*) FILTER (WHERE article_quality_score IS NOT NULL) AS with_article_quality_score,
    COUNT(*) FILTER (WHERE COALESCE(article_quality_score, 0) >= 70) AS quality_70_plus,
    MIN(published_at) AS min_published_at,
    MAX(published_at) AS max_published_at
FROM public.articles;


-- 3) Zda article_team_map opravdu odkazuje na existující články a týmy
SELECT
    COUNT(*) AS total_article_team_links,
    COUNT(*) FILTER (WHERE a.id IS NOT NULL) AS valid_articles,
    COUNT(*) FILTER (WHERE t.id IS NOT NULL) AS valid_teams,
    COUNT(*) FILTER (WHERE a.published_at IS NOT NULL) AS links_with_published_at,
    COUNT(*) FILTER (WHERE COALESCE(a.article_quality_score, 0) >= 70) AS links_quality_70_plus
FROM public.article_team_map atm
LEFT JOIN public.articles a ON a.id = atm.article_id
LEFT JOIN public.teams t ON t.id = atm.team_id;


-- 4) Ukázka namapovaných článků na týmy
SELECT
    a.id AS article_id,
    a.title,
    a.published_at,
    a.article_quality_score,
    t.id AS team_id,
    t.name AS team_name
FROM public.article_team_map atm
JOIN public.articles a ON a.id = atm.article_id
JOIN public.teams t ON t.id = atm.team_id
ORDER BY a.published_at DESC NULLS LAST
LIMIT 30;


-- 5) Rozsah zápasů
SELECT
    COUNT(*) AS total_matches,
    MIN(kickoff) AS min_kickoff,
    MAX(kickoff) AS max_kickoff
FROM public.matches;