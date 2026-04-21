-- =====================================================================
-- 225_premerge_fk_and_alias_cleanup_batch_lens_reims_brest.sql
-- =====================================================================

-- =========================
-- LENS keep = 1012
-- old = 12119, 27000
-- =========================

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12119
  AND newa.team_id = 1012
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1012 WHERE team_id = 12119;
UPDATE public.league_standings         SET team_id = 1012 WHERE team_id = 12119;

SELECT public.merge_team(
    12119, 1012,
    'merge Lens api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27000
  AND newa.team_id = 1012
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1012 WHERE team_id = 27000;
UPDATE public.league_standings         SET team_id = 1012 WHERE team_id = 27000;

SELECT public.merge_team(
    27000, 1012,
    'merge Lens api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- REIMS keep = 1025
-- old = 12111, 25879
-- =========================

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12111
  AND newa.team_id = 1025
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1025 WHERE team_id = 12111;
UPDATE public.league_standings         SET team_id = 1025 WHERE team_id = 12111;

SELECT public.merge_team(
    12111, 1025,
    'merge Reims api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25879
  AND newa.team_id = 1025
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1025 WHERE team_id = 25879;
UPDATE public.league_standings         SET team_id = 1025 WHERE team_id = 25879;

SELECT public.merge_team(
    25879, 1025,
    'merge Reims api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- STADE BRESTOIS 29 keep = 501
-- old = 12115, 27638
-- =========================

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12115
  AND newa.team_id = 501
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 501 WHERE team_id = 12115;
UPDATE public.league_standings         SET team_id = 501 WHERE team_id = 12115;

SELECT public.merge_team(
    12115, 501,
    'merge Stade Brestois 29 api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27638
  AND newa.team_id = 501
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 501 WHERE team_id = 27638;
UPDATE public.league_standings         SET team_id = 501 WHERE team_id = 27638;

SELECT public.merge_team(
    27638, 501,
    'merge Stade Brestois 29 api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);