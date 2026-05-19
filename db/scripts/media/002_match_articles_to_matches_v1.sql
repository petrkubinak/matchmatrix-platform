-- ====================================================================
-- MATCHMATRIX ARTICLE ↔ MATCH MAPPER V1
-- Rule:
-- If one article is mapped to both home_team_id and away_team_id,
-- connect article to that match.
-- ====================================================================

INSERT INTO public.article_match_map
(
    article_id,
    match_id,
    created_at
)
SELECT DISTINCT
    atm_home.article_id,
    m.id AS match_id,
    NOW() AS created_at
FROM public.matches m
JOIN public.article_team_map atm_home
    ON atm_home.team_id = m.home_team_id
JOIN public.article_team_map atm_away
    ON atm_away.article_id = atm_home.article_id
   AND atm_away.team_id = m.away_team_id
WHERE m.home_team_id IS NOT NULL
  AND m.away_team_id IS NOT NULL
ON CONFLICT DO NOTHING;