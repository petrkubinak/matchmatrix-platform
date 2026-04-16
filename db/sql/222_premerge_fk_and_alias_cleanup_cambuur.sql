-- =====================================================================
-- 222_premerge_fk_and_alias_cleanup_cambuur.sql
-- Cambuur:
-- keep = 1114
-- old  = 12180 (api_football)
-- old  = 27530 (api_sport)
-- =====================================================================

-- -------------------------------------------------
-- A) 12180 -> 1114
-- -------------------------------------------------

-- alias cleanup
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12180
  AND newa.team_id = 1114
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

-- FK move
UPDATE public.player_season_statistics
SET team_id = 1114
WHERE team_id = 12180;

UPDATE public.league_standings
SET team_id = 1114
WHERE team_id = 12180;

-- merge
SELECT public.merge_team(
    12180,
    1114,
    'merge Cambuur api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH',
    true,
    true
);

-- -------------------------------------------------
-- B) 27530 -> 1114
-- -------------------------------------------------

-- alias cleanup
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27530
  AND newa.team_id = 1114
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

-- FK move
UPDATE public.player_season_statistics
SET team_id = 1114
WHERE team_id = 27530;

UPDATE public.league_standings
SET team_id = 1114
WHERE team_id = 27530;

-- merge
SELECT public.merge_team(
    27530,
    1114,
    'merge Cambuur api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH',
    true,
    true
);