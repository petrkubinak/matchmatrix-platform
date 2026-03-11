SELECT
    COUNT(*) AS future_matches
FROM public.matches
WHERE kickoff >= now()
  AND status = 'SCHEDULED';

SELECT
    COUNT(DISTINCT p.match_id) AS future_matches_with_predictions
FROM public.ml_predictions p
JOIN public.matches m
  ON m.id = p.match_id
WHERE m.kickoff >= now()
  AND m.status = 'SCHEDULED';

SELECT
    COUNT(*) AS future_matches_with_features
FROM public.match_features f
JOIN public.matches m
  ON m.id = f.match_id
WHERE m.kickoff >= now()
  AND m.status = 'SCHEDULED';

