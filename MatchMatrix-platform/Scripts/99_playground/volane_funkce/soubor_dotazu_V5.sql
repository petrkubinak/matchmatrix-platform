-- 2026-02-19_check_ingest_football_data.sql
-- Kontrolní dotazy pro ingest football-data.org (SOURCE='football_data')

/* 1) Poslední import runy */
SELECT id, source, status, started_at, finished_at, details
FROM public.api_import_runs
WHERE source = 'football_data'
ORDER BY id DESC
LIMIT 10;

/* 2) Kolik raw payloadů se uložilo pro poslední run */
WITH last_run AS (
  SELECT id
  FROM public.api_import_runs
  WHERE source='football_data'
  ORDER BY id DESC
  LIMIT 1
)
SELECT p.endpoint, COUNT(*) AS cnt
FROM public.api_raw_payloads p
JOIN last_run r ON r.id = p.run_id
GROUP BY p.endpoint
ORDER BY cnt DESC;

/* 3) Kolik zápasů je z football_data celkem + kolik FINISHED/SCHEDULED */
SELECT status, COUNT(*) AS cnt
FROM public.matches
WHERE ext_source = 'football_data'
GROUP BY status
ORDER BY status;

/* 4) Kontrola, že statusy jsou jen SCHEDULED/FINISHED (matches_status_chk) */
SELECT status, COUNT(*) AS cnt
FROM public.matches
WHERE ext_source='football_data'
  AND status NOT IN ('SCHEDULED','FINISHED')
GROUP BY status;

/* 5) Kontrola score constraintu (matches_score_status_chk) – musí vrátit 0 řádků */
SELECT id, kickoff, status, home_score, away_score, ext_match_id
FROM public.matches
WHERE ext_source='football_data'
  AND (
    (status='FINISHED' AND (home_score IS NULL OR away_score IS NULL))
    OR
    (status<>'FINISHED' AND (home_score IS NOT NULL OR away_score IS NOT NULL))
  )
ORDER BY kickoff DESC
LIMIT 50;

/* 6) Kontrola home_team_id <> away_team_id (chk_teams_different) – musí vrátit 0 */
SELECT id, kickoff, home_team_id, away_team_id, ext_match_id
FROM public.matches
WHERE ext_source='football_data'
  AND home_team_id = away_team_id
LIMIT 50;

/* 7) Kolik týmů bylo založeno z football_data */
SELECT COUNT(*) AS teams_cnt
FROM public.teams
WHERE ext_source='football_data';

/* 8) Kolik lig bylo založeno z football_data */
SELECT COUNT(*) AS leagues_cnt
FROM public.leagues
WHERE ext_source='football_data';

/* 9) Top 20 lig podle počtu zápasů z football_data */
SELECT l.id AS league_id, l.name, COUNT(m.id) AS matches_cnt
FROM public.matches m
JOIN public.leagues l ON l.id = m.league_id
WHERE m.ext_source='football_data'
GROUP BY l.id, l.name
ORDER BY matches_cnt DESC
LIMIT 20;

/* 10) Budoucí zápasy (SCHEDULED) – sanity check */
SELECT m.id, m.kickoff, l.name AS league, th.name AS home, ta.name AS away, m.ext_match_id
FROM public.matches m
JOIN public.leagues l ON l.id = m.league_id
JOIN public.teams th ON th.id = m.home_team_id
JOIN public.teams ta ON ta.id = m.away_team_id
WHERE m.ext_source='football_data'
  AND m.status='SCHEDULED'
  AND m.kickoff >= now()
ORDER BY m.kickoff
LIMIT 50;

/* 11) Odehrané zápasy (FINISHED) – sanity check */
SELECT m.id, m.kickoff, l.name AS league, th.name AS home, ta.name AS away,
       m.home_score, m.away_score, m.ext_match_id
FROM public.matches m
JOIN public.leagues l ON l.id = m.league_id
JOIN public.teams th ON th.id = m.home_team_id
JOIN public.teams ta ON ta.id = m.away_team_id
WHERE m.ext_source='football_data'
  AND m.status='FINISHED'
ORDER BY m.kickoff DESC
LIMIT 50;


SELECT ext_source, ext_match_id, COUNT(*) AS cnt
FROM public.matches
WHERE ext_source = 'football_data'
GROUP BY ext_source, ext_match_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC, ext_match_id;
