SELECT *
FROM public.vw_offer_matches
LIMIT 20;

SELECT
    m.id AS market_id,
    m.code AS market_code,
    m.name AS market_name,
    mo.id AS market_outcome_id,
    mo.code AS outcome_code,
    mo.label AS outcome_label
FROM public.markets m
JOIN public.market_outcomes mo
  ON mo.market_id = m.id
ORDER BY m.code, mo.code;

SELECT *
FROM public.vw_offer_matches
WHERE match_id IN (66039, 65706);

SELECT
    m.id,
    m.kickoff,
    l.name AS league_name,
    th.name AS home_team,
    ta.name AS away_team,
    CASE WHEN p.match_id IS NOT NULL THEN 1 ELSE 0 END AS has_prediction
FROM public.matches m
JOIN public.leagues l
  ON l.id = m.league_id
LEFT JOIN public.teams th
  ON th.id = m.home_team_id
LEFT JOIN public.teams ta
  ON ta.id = m.away_team_id
LEFT JOIN public.ml_predictions p
  ON p.match_id = m.id
WHERE m.id IN (66039, 65706)
ORDER BY m.id;

SELECT *
FROM public.ml_match_predict_dataset_v1
WHERE match_id IN (66039, 65706);

SELECT definition
FROM pg_views
WHERE schemaname = 'public'
  AND viewname = 'ml_match_predict_dataset_v1';

SELECT *
FROM public.match_features
WHERE match_id IN (66039, 65706);

SELECT definition
FROM pg_views
WHERE schemaname = 'public'
  AND viewname = 'ml_match_dataset_v2';

SELECT *
FROM public.match_features
WHERE match_id IN (66039, 65706);

SELECT
    match_id,
    home_team,
    away_team,
    odd_1,
    odd_x,
    odd_2,
    has_prediction
FROM public.vw_offer_matches
WHERE match_id IN (66039, 65706);