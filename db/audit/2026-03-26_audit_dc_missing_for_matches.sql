-- Audit: mají vybrané budoucí zápasy uložené DC odds?
-- Spouštět v DBeaveru

WITH target_matches AS (
    SELECT *
    FROM (VALUES
        (62674),
        (62677),
        (62678),
        (62680),
        (62681)
    ) AS x(match_id)
)
SELECT
    m.id AS match_id,
    l.name AS league_name,
    ht.name AS home_team,
    at.name AS away_team,
    mk.code AS market_code,
    mk.name AS market_name,
    mo.code AS outcome_code,
    mo.label AS outcome_label,
    b.name AS bookmaker_name,
    o.odd_value,
    o.collected_at
FROM target_matches tm
JOIN public.matches m
  ON m.id = tm.match_id
LEFT JOIN public.leagues l
  ON l.id = m.league_id
LEFT JOIN public.teams ht
  ON ht.id = m.home_team_id
LEFT JOIN public.teams at
  ON at.id = m.away_team_id
LEFT JOIN public.odds o
  ON o.match_id = m.id
LEFT JOIN public.market_outcomes mo
  ON mo.id = o.market_outcome_id
LEFT JOIN public.markets mk
  ON mk.id = mo.market_id
LEFT JOIN public.bookmakers b
  ON b.id = o.bookmaker_id
WHERE mk.code IN ('h2h', 'DC')
ORDER BY
    m.id,
    mk.code,
    mo.code,
    o.odd_value DESC NULLS LAST;