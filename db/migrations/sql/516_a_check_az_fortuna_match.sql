-- 516_a_check_az_fortuna_match.sql
-- Cíl:
-- ověřit, jestli AZ Alkmaar vs Fortuna Sittard existuje v matches

SELECT
    m.id,
    m.kickoff,
    m.home_team_id,
    th.name AS home_team_name,
    m.away_team_id,
    ta.name AS away_team_name,
    m.ext_source,
    m.ext_match_id,
    m.status
FROM public.matches m
JOIN public.teams th
  ON th.id = m.home_team_id
JOIN public.teams ta
  ON ta.id = m.away_team_id
WHERE m.kickoff BETWEEN '2026-04-04 00:00:00' AND '2026-04-05 23:59:59'
  AND (
        (m.home_team_id = 1106 AND m.away_team_id = 572)
     OR (m.home_team_id = 572 AND m.away_team_id = 1106)
  )
ORDER BY m.kickoff, m.id;