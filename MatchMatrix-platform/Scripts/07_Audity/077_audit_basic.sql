-- 077_audit_basic.sql

-- A) Duplicate ext ids (teams)
SELECT ext_source, ext_team_id, count(*)
FROM public.teams
GROUP BY ext_source, ext_team_id
HAVING count(*) > 1;

-- B) Orphan matches (missing team FK)
SELECT m.id
FROM public.matches m
LEFT JOIN public.teams t1 ON t1.id = m.home_team_id
LEFT JOIN public.teams t2 ON t2.id = m.away_team_id
WHERE t1.id IS NULL OR t2.id IS NULL;

-- C) Leagues without teams
SELECT l.id
FROM public.leagues l
LEFT JOIN public.league_teams lt ON lt.league_id = l.id
WHERE lt.league_id IS NULL;

-- D) Teams without seasons
SELECT t.id
FROM public.teams t
LEFT JOIN public.league_team_seasons lts
  ON lts.team_id = t.id
WHERE lts.league_id IS NULL;