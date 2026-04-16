-- 710_fix_league_standings_before_merge.sql
-- Oprava FK blokace před merge_team()

-- ALTAY
UPDATE public.league_standings
SET team_id = 13202
WHERE team_id = 14578;

-- ISKRA
UPDATE public.league_standings
SET team_id = 13228
WHERE team_id = 13255;

-- RUDAR
UPDATE public.league_standings
SET team_id = 13110
WHERE team_id = 13615;