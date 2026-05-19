-- insert_article_player_map_title_v1.sql
-- Bezpečný první merge:
-- mapuje článek na hráče, pokud celé jméno hráče je v titulku článku.

INSERT INTO public.article_player_map (
    article_id,
    player_id,
    created_at
)
SELECT DISTINCT
    a.id AS article_id,
    p.id AS player_id,
    now() AS created_at
FROM public.articles a
JOIN public.players p
  ON position(lower(p.name) in lower(a.title)) > 0
WHERE COALESCE(a.article_quality_score, 0) >= 70
  AND a.title IS NOT NULL
  AND p.is_active = true
  AND length(p.name) >= 8
ON CONFLICT DO NOTHING;


-- Kontrola
SELECT
    COUNT(*) AS article_player_links,
    COUNT(DISTINCT article_id) AS linked_articles,
    COUNT(DISTINCT player_id) AS linked_players
FROM public.article_player_map;