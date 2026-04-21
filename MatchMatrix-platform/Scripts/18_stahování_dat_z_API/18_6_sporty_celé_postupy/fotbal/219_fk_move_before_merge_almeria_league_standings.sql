-- =====================================================================
-- 219_fk_move_before_merge_almeria_league_standings.sql
-- MatchMatrix - další FK move před merge pro Almeria
-- old_team_id = 12871
-- new_team_id = 1158
-- =====================================================================

-- 1) Kontrola league_standings
SELECT
    team_id,
    COUNT(*) AS row_count
FROM public.league_standings
WHERE team_id IN (12871, 1158)
GROUP BY team_id
ORDER BY team_id;

-- 2) Přesun FK old -> new
UPDATE public.league_standings
SET team_id = 1158
WHERE team_id = 12871;

-- 3) Kontrola po přesunu
SELECT
    team_id,
    COUNT(*) AS row_count
FROM public.league_standings
WHERE team_id IN (12871, 1158)
GROUP BY team_id
ORDER BY team_id;

-- 4) Znovu zkus merge
SELECT public.merge_team(
    12871,
    1158,
    'merge Almeria dup after FK move league_standings',
    'FB_MULTI_MATCH',
    true,
    true
);