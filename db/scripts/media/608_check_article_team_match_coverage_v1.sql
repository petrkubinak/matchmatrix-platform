-- check_article_team_match_coverage_v1.sql
-- Ověří, jestli týmy z article_team_map existují v public.matches.

SELECT
    t.id AS team_id,
    t.name AS team_name,
    COUNT(DISTINCT atm.article_id) AS article_links,
    COUNT(DISTINCT m_home.id) AS home_matches,
    COUNT(DISTINCT m_away.id) AS away_matches,
    COUNT(DISTINCT COALESCE(m_home.id, m_away.id)) AS total_match_links
FROM public.article_team_map atm
JOIN public.teams t
  ON t.id = atm.team_id
LEFT JOIN public.matches m_home
  ON m_home.home_team_id = t.id
LEFT JOIN public.matches m_away
  ON m_away.away_team_id = t.id
GROUP BY
    t.id,
    t.name
ORDER BY
    total_match_links ASC,
    article_links DESC,
    t.name
LIMIT 100;