
--1. Ověření počtu zápasů v Premier League 2526
SELECT
    COUNT(*) AS all_rows,
    COUNT(DISTINCT (kickoff, home_team_id, away_team_id)) AS distinct_matches,
    COUNT(*) - COUNT(DISTINCT (kickoff, home_team_id, away_team_id)) AS duplicate_rows
FROM public.matches
WHERE league_id = 6
  AND season = '2526'
  AND status = 'FINISHED';

--2. Přímý seznam duplicit
SELECT
    kickoff,
    home_team_id,
    away_team_id,
    COUNT(*) AS cnt
FROM public.matches
WHERE league_id = 6
  AND season = '2526'
  AND status = 'FINISHED'
GROUP BY kickoff, home_team_id, away_team_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC, kickoff;

--3. Rozpis duplicit i se zdrojem
SELECT
    m.kickoff,
    th.name AS home_team,
    ta.name AS away_team,
    COUNT(*) AS cnt,
    STRING_AGG(COALESCE(m.ext_source, '-'), ' | ' ORDER BY COALESCE(m.ext_source, '-')) AS sources,
    STRING_AGG(COALESCE(m.ext_match_id, '-'), ' | ' ORDER BY COALESCE(m.ext_match_id, '-')) AS ext_match_ids
FROM public.matches m
JOIN public.teams th
  ON th.id = m.home_team_id
JOIN public.teams ta
  ON ta.id = m.away_team_id
WHERE m.league_id = 6
  AND m.season = '2526'
  AND m.status = 'FINISHED'
GROUP BY
    m.kickoff,
    th.name,
    ta.name
HAVING COUNT(*) > 1
ORDER BY cnt DESC, m.kickoff;

--4. Kontrola, do jakého kola to zhruba sahá
SELECT
    MIN(kickoff) AS first_match,
    MAX(kickoff) AS last_match,
    COUNT(DISTINCT (kickoff, home_team_id, away_team_id)) AS distinct_matches
FROM public.matches
WHERE league_id = 6
  AND season = '2526'
  AND status = 'FINISHED';