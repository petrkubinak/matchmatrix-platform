INSERT INTO public.article_player_map (
    article_id,
    player_id,
    created_at
)
SELECT DISTINCT
    a.id AS article_id,
    mea.entity_id AS player_id,
    now() AS created_at
FROM public.articles a
JOIN public.media_entity_aliases mea
  ON mea.entity_type = 'player'
 AND mea.is_active = true
 AND position(lower(mea.alias_text) in lower(coalesce(a.title, ''))) > 0
WHERE COALESCE(a.article_quality_score, 0) >= 70
ON CONFLICT DO NOTHING;

SELECT
    COUNT(*) AS article_player_links,
    COUNT(DISTINCT article_id) AS linked_articles,
    COUNT(DISTINCT player_id) AS linked_players
FROM public.article_player_map;