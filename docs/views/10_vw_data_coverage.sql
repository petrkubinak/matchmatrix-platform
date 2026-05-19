CREATE OR REPLACE VIEW public.vw_data_coverage AS

SELECT

    l.id AS league_id,
    l.name AS league_name,

    COUNT(DISTINCT m.id) AS matches,

    COUNT(DISTINCT o.match_id) AS matches_with_odds,

    COUNT(DISTINCT p.match_id) AS matches_with_predictions

FROM leagues l

LEFT JOIN matches m
    ON m.league_id = l.id

LEFT JOIN odds o
    ON o.match_id = m.id

LEFT JOIN ml_predictions p
    ON p.match_id = m.id

GROUP BY

    l.id,
    l.name

ORDER BY

    matches DESC;