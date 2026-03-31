-- Kolik zápasů má odds (1X2)

WITH base AS (
    SELECT
        m.id,
        m.kickoff,
        l.name AS league_name
    FROM public.matches m
    JOIN public.leagues l ON l.id = m.league_id
    WHERE m.kickoff >= now()
      AND m.kickoff < now() + interval '14 days'
),
odds_1x2 AS (
    SELECT DISTINCT match_id
    FROM public.odds
)
SELECT
    league_name,
    COUNT(*) AS total_matches,
    COUNT(o.match_id) AS matches_with_odds,
    ROUND(100.0 * COUNT(o.match_id) / COUNT(*), 1) AS coverage_pct
FROM base b
LEFT JOIN odds_1x2 o
  ON o.match_id = b.id
GROUP BY league_name
ORDER BY coverage_pct ASC, total_matches DESC;