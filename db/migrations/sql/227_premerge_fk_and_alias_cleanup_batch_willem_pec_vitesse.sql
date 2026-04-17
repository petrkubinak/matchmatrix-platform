-- =====================================================================
-- 227_premerge_fk_and_alias_cleanup_batch_willem_pec_vitesse.sql
-- =====================================================================

-- =========================
-- WILLEM II keep = 1110
-- old = 12162, 26900
-- =========================

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12162
  AND newa.team_id = 1110
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1110 WHERE team_id = 12162;
UPDATE public.league_standings         SET team_id = 1110 WHERE team_id = 12162;

SELECT public.merge_team(
    12162, 1110,
    'merge Willem II api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26900
  AND newa.team_id = 1110
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1110 WHERE team_id = 26900;
UPDATE public.league_standings         SET team_id = 1110 WHERE team_id = 26900;

SELECT public.merge_team(
    26900, 1110,
    'merge Willem II api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- PEC ZWOLLE keep = 567
-- old = 12160, 26479
-- =========================

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12160
  AND newa.team_id = 567
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 567 WHERE team_id = 12160;
UPDATE public.league_standings         SET team_id = 567 WHERE team_id = 12160;

SELECT public.merge_team(
    12160, 567,
    'merge PEC Zwolle api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26479
  AND newa.team_id = 567
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 567 WHERE team_id = 26479;
UPDATE public.league_standings         SET team_id = 567 WHERE team_id = 26479;

SELECT public.merge_team(
    26479, 567,
    'merge PEC Zwolle api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- VITESSE keep = 1113
-- old = 25793, 26481
-- =========================

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25793
  AND newa.team_id = 1113
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1113 WHERE team_id = 25793;
UPDATE public.league_standings         SET team_id = 1113 WHERE team_id = 25793;

SELECT public.merge_team(
    25793, 1113,
    'merge Vitesse api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26481
  AND newa.team_id = 1113
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1113 WHERE team_id = 26481;
UPDATE public.league_standings         SET team_id = 1113 WHERE team_id = 26481;

SELECT public.merge_team(
    26481, 1113,
    'merge Vitesse api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);