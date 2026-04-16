-- =====================================================================
-- 228_premerge_fk_and_alias_cleanup_batch_laspalmas_leganes_monza.sql
-- =====================================================================

-- =========================
-- LAS PALMAS keep = 1155
-- old = 12087, 26688
-- =========================

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12087
  AND newa.team_id = 1155
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1155 WHERE team_id = 12087;
UPDATE public.league_standings         SET team_id = 1155 WHERE team_id = 12087;

SELECT public.merge_team(
    12087, 1155,
    'merge Las Palmas api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26688
  AND newa.team_id = 1155
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1155 WHERE team_id = 26688;
UPDATE public.league_standings         SET team_id = 1155 WHERE team_id = 26688;

SELECT public.merge_team(
    26688, 1155,
    'merge Las Palmas api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- LEGANES keep = 1156
-- old = 12089, 27751
-- =========================

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12089
  AND newa.team_id = 1156
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1156 WHERE team_id = 12089;
UPDATE public.league_standings         SET team_id = 1156 WHERE team_id = 12089;

SELECT public.merge_team(
    12089, 1156,
    'merge Leganes api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27751
  AND newa.team_id = 1156
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1156 WHERE team_id = 27751;
UPDATE public.league_standings         SET team_id = 1156 WHERE team_id = 27751;

SELECT public.merge_team(
    27751, 1156,
    'merge Leganes api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- MONZA keep = 1084
-- old = 12140, 28834
-- =========================

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12140
  AND newa.team_id = 1084
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1084 WHERE team_id = 12140;
UPDATE public.league_standings         SET team_id = 1084 WHERE team_id = 12140;

SELECT public.merge_team(
    12140, 1084,
    'merge Monza api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28834
  AND newa.team_id = 1084
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1084 WHERE team_id = 28834;
UPDATE public.league_standings         SET team_id = 1084 WHERE team_id = 28834;

SELECT public.merge_team(
    28834, 1084,
    'merge Monza api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);