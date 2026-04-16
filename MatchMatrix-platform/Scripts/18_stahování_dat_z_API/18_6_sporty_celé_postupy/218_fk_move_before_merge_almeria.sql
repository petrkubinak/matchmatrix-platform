-- =====================================================================
-- 218_fk_move_before_merge_almeria.sql
-- MatchMatrix - FK move před merge pro Almeria
-- old_team_id = 12871
-- new_team_id = 1158
-- =====================================================================

-- 1) Kontrola kolik řádků blokuje player_season_statistics
SELECT
    team_id,
    COUNT(*) AS row_count
FROM public.player_season_statistics
WHERE team_id IN (12871, 1158)
GROUP BY team_id
ORDER BY team_id;

-- 2) Přesun FK z old -> new
UPDATE public.player_season_statistics
SET team_id = 1158
WHERE team_id = 12871;

-- 3) Kontrola po přesunu
SELECT
    team_id,
    COUNT(*) AS row_count
FROM public.player_season_statistics
WHERE team_id IN (12871, 1158)
GROUP BY team_id
ORDER BY team_id;

-- 4) Znovu zkus merge
SELECT public.merge_team(
    12871,
    1158,
    'merge Almeria dup after FK move player_season_statistics',
    'FB_MULTI_MATCH',
    true,
    true
);