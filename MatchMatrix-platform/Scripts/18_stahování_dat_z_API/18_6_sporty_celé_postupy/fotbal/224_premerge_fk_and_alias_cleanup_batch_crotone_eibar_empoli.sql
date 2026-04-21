-- =====================================================================
-- 224_premerge_fk_and_alias_cleanup_batch_crotone_eibar_empoli.sql
-- =====================================================================

-- =========================
-- CROTONE keep = 1090
-- old = 14302, 26935
-- =========================

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 14302
  AND newa.team_id = 1090
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1090 WHERE team_id = 14302;
UPDATE public.league_standings         SET team_id = 1090 WHERE team_id = 14302;

SELECT public.merge_team(
    14302, 1090,
    'merge Crotone api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26935
  AND newa.team_id = 1090
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1090 WHERE team_id = 26935;
UPDATE public.league_standings         SET team_id = 1090 WHERE team_id = 26935;

SELECT public.merge_team(
    26935, 1090,
    'merge Crotone api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- EIBAR keep = 1161
-- old = 12429, 27752
-- =========================

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12429
  AND newa.team_id = 1161
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1161 WHERE team_id = 12429;
UPDATE public.league_standings         SET team_id = 1161 WHERE team_id = 12429;

SELECT public.merge_team(
    12429, 1161,
    'merge Eibar api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27752
  AND newa.team_id = 1161
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1161 WHERE team_id = 27752;
UPDATE public.league_standings         SET team_id = 1161 WHERE team_id = 27752;

SELECT public.merge_team(
    27752, 1161,
    'merge Eibar api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- EMPOLI keep = 1083
-- old = 12135, 27097
-- =========================

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12135
  AND newa.team_id = 1083
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1083 WHERE team_id = 12135;
UPDATE public.league_standings         SET team_id = 1083 WHERE team_id = 12135;

SELECT public.merge_team(
    12135, 1083,
    'merge Empoli api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27097
  AND newa.team_id = 1083
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1083 WHERE team_id = 27097;
UPDATE public.league_standings         SET team_id = 1083 WHERE team_id = 27097;

SELECT public.merge_team(
    27097, 1083,
    'merge Empoli api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);