-- =====================================================================
-- 221_premerge_fk_and_alias_cleanup_almeria_api_sport.sql
-- old_team_id = 25856
-- new_team_id = 1158
-- =====================================================================

-- 1) Alias cleanup - smaž jen kolizní aliasy old -> new
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25856
  AND newa.team_id = 1158
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

-- 2) FK move - player_season_statistics
UPDATE public.player_season_statistics
SET team_id = 1158
WHERE team_id = 25856;

-- 3) FK move - league_standings
UPDATE public.league_standings
SET team_id = 1158
WHERE team_id = 25856;

-- 4) Merge
SELECT public.merge_team(
    25856,
    1158,
    'merge Almeria api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH',
    true,
    true
);