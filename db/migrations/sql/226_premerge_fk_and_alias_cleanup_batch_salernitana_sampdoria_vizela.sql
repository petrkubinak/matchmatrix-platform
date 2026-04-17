-- =====================================================================
-- 226_premerge_fk_and_alias_cleanup_batch_salernitana_sampdoria_vizela.sql
-- =====================================================================

-- =========================
-- SALERNITANA keep = 1087
-- old = 13019, 26932
-- =========================

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 13019
  AND newa.team_id = 1087
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1087 WHERE team_id = 13019;
UPDATE public.league_standings         SET team_id = 1087 WHERE team_id = 13019;

SELECT public.merge_team(
    13019, 1087,
    'merge Salernitana api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26932
  AND newa.team_id = 1087
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1087 WHERE team_id = 26932;
UPDATE public.league_standings         SET team_id = 1087 WHERE team_id = 26932;

SELECT public.merge_team(
    26932, 1087,
    'merge Salernitana api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- SAMPDORIA keep = 1088
-- old = 12491, 27095
-- =========================

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12491
  AND newa.team_id = 1088
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1088 WHERE team_id = 12491;
UPDATE public.league_standings         SET team_id = 1088 WHERE team_id = 12491;

SELECT public.merge_team(
    12491, 1088,
    'merge Sampdoria api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27095
  AND newa.team_id = 1088
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1088 WHERE team_id = 27095;
UPDATE public.league_standings         SET team_id = 1088 WHERE team_id = 27095;

SELECT public.merge_team(
    27095, 1088,
    'merge Sampdoria api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- VIZELA keep = 1135
-- old = 12156, 26307
-- =========================

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12156
  AND newa.team_id = 1135
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1135 WHERE team_id = 12156;
UPDATE public.league_standings         SET team_id = 1135 WHERE team_id = 12156;

SELECT public.merge_team(
    12156, 1135,
    'merge Vizela api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26307
  AND newa.team_id = 1135
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1135 WHERE team_id = 26307;
UPDATE public.league_standings         SET team_id = 1135 WHERE team_id = 26307;

SELECT public.merge_team(
    26307, 1135,
    'merge Vizela api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);