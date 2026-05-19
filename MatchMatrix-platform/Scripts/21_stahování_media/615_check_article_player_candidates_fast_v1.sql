-- check_article_player_candidates_fast_v1.sql
-- Rychlá verze: hledá hráče jen v title, ne v raw_text.

WITH candidate_articles AS (
    SELECT
        id,
        title,
        article_quality_score
    FROM public.articles
    WHERE COALESCE(article_quality_score, 0) >= 70
      AND title IS NOT NULL
),
candidate_players AS (
    SELECT
        id,
        name,
        team_id
    FROM public.players
    WHERE is_active = true
      AND length(name) >= 8
)
SELECT
    a.id AS article_id,
    a.title,
    p.id AS player_id,
    p.name AS player_name,
    p.team_id,
    a.article_quality_score
FROM candidate_articles a
JOIN candidate_players p
  ON position(lower(p.name) in lower(a.title)) > 0
ORDER BY
    a.id,
    p.name
LIMIT 100;