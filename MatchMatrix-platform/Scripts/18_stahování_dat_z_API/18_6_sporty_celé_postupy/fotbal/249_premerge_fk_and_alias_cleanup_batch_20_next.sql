-- =====================================================================
-- 249_premerge_fk_and_alias_cleanup_batch_20_next.sql
-- Dalsi batch 20 z aktualniho MULTI_MATCH exportu
-- =====================================================================

-- =========================
-- TORRENT keep = 14140
-- old = 26360
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26360
  AND newa.team_id = 14140
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14140 WHERE team_id = 26360;
UPDATE public.league_standings         SET team_id = 14140 WHERE team_id = 26360;
SELECT public.merge_team(26360, 14140, 'merge Torrent dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- TORRES keep = 14148
-- old = 26927
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26927
  AND newa.team_id = 14148
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14148 WHERE team_id = 26927;
UPDATE public.league_standings         SET team_id = 14148 WHERE team_id = 26927;
SELECT public.merge_team(26927, 14148, 'merge Torres dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- TRELLEBORGS FF keep = 12224
-- old = 27190
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27190
  AND newa.team_id = 12224
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12224 WHERE team_id = 27190;
UPDATE public.league_standings         SET team_id = 12224 WHERE team_id = 27190;
SELECT public.merge_team(27190, 12224, 'merge Trelleborgs FF dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- TRIGLAV keep = 12338
-- old = 26526
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26526
  AND newa.team_id = 12338
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12338 WHERE team_id = 26526;
UPDATE public.league_standings         SET team_id = 12338 WHERE team_id = 26526;
SELECT public.merge_team(26526, 12338, 'merge Triglav dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- TUDELANO keep = 27568
-- old = 28793
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28793
  AND newa.team_id = 27568
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 27568 WHERE team_id = 28793;
UPDATE public.league_standings         SET team_id = 27568 WHERE team_id = 28793;
SELECT public.merge_team(28793, 27568, 'merge Tudelano dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- TURAN keep = 13115
-- old = 25799
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25799
  AND newa.team_id = 13115
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13115 WHERE team_id = 25799;
UPDATE public.league_standings         SET team_id = 13115 WHERE team_id = 25799;
SELECT public.merge_team(25799, 13115, 'merge Turan dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- TURBINE POTSDAM W keep = 14268
-- old = 26792
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26792
  AND newa.team_id = 14268
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14268 WHERE team_id = 26792;
UPDATE public.league_standings         SET team_id = 14268 WHERE team_id = 26792;
SELECT public.merge_team(26792, 14268, 'merge Turbine Potsdam W dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- TWENTE keep = 12177
-- old = 26895
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26895
  AND newa.team_id = 12177
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12177 WHERE team_id = 26895;
UPDATE public.league_standings         SET team_id = 12177 WHERE team_id = 26895;
SELECT public.merge_team(26895, 12177, 'merge Twente dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- UCAM MURCIA keep = 14522
-- old = 27659
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27659
  AND newa.team_id = 14522
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14522 WHERE team_id = 27659;
UPDATE public.league_standings         SET team_id = 14522 WHERE team_id = 27659;
SELECT public.merge_team(27659, 14522, 'merge Ucam Murcia dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- UD SAN PEDRO keep = 26392
-- old = 28765
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28765
  AND newa.team_id = 26392
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 26392 WHERE team_id = 28765;
UPDATE public.league_standings         SET team_id = 26392 WHERE team_id = 28765;
SELECT public.merge_team(28765, 26392, 'merge UD San Pedro dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- UNIONISTAS DE SALAMANCA keep = 27350
-- old = 28795
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28795
  AND newa.team_id = 27350
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 27350 WHERE team_id = 28795;
UPDATE public.league_standings         SET team_id = 27350 WHERE team_id = 28795;
SELECT public.merge_team(28795, 27350, 'merge Unionistas de Salamanca dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- UNIREA SLOBOZIA keep = 13380
-- old = 27260
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27260
  AND newa.team_id = 13380
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13380 WHERE team_id = 27260;
UPDATE public.league_standings         SET team_id = 13380 WHERE team_id = 27260;
SELECT public.merge_team(27260, 13380, 'merge Unirea Slobozia dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- UNIVERSITATEA CRAIOVA keep = 12534
-- old = 27766
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27766
  AND newa.team_id = 12534
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12534 WHERE team_id = 27766;
UPDATE public.league_standings         SET team_id = 12534 WHERE team_id = 27766;
SELECT public.merge_team(27766, 12534, 'merge Universitatea Craiova dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- UTEBO keep = 14675
-- old = 26323
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26323
  AND newa.team_id = 14675
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14675 WHERE team_id = 26323;
UPDATE public.league_standings         SET team_id = 14675 WHERE team_id = 26323;
SELECT public.merge_team(26323, 14675, 'merge Utebo dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- VALENCIA II keep = 16767
-- old = 26433
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26433
  AND newa.team_id = 16767
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 16767 WHERE team_id = 26433;
UPDATE public.league_standings         SET team_id = 16767 WHERE team_id = 26433;
SELECT public.merge_team(26433, 16767, 'merge Valencia II dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- VALLADOLID keep = 1157
-- old = 12098
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12098
  AND newa.team_id = 1157
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1157 WHERE team_id = 12098;
UPDATE public.league_standings         SET team_id = 1157 WHERE team_id = 12098;
SELECT public.merge_team(12098, 1157, 'merge Valladolid dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- VARBERGS BOIS FC keep = 12337
-- old = 27622
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27622
  AND newa.team_id = 12337
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12337 WHERE team_id = 27622;
UPDATE public.league_standings         SET team_id = 12337 WHERE team_id = 27622;
SELECT public.merge_team(27622, 12337, 'merge Varbergs BoIS FC dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- VASTERAS SK FK keep = 13423
-- old = 25832
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25832
  AND newa.team_id = 13423
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13423 WHERE team_id = 25832;
UPDATE public.league_standings         SET team_id = 13423 WHERE team_id = 25832;
SELECT public.merge_team(25832, 13423, 'merge Vasteras SK FK dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- VENEZIA keep = 1085
-- old = 12136
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12136
  AND newa.team_id = 1085
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1085 WHERE team_id = 12136;
UPDATE public.league_standings         SET team_id = 1085 WHERE team_id = 12136;
SELECT public.merge_team(12136, 1085, 'merge Venezia dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- VIC keep = 26374
-- old = 28781
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28781
  AND newa.team_id = 26374
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 26374 WHERE team_id = 28781;
UPDATE public.league_standings         SET team_id = 26374 WHERE team_id = 28781;
SELECT public.merge_team(28781, 26374, 'merge Vic dup', 'FB_MULTI_MATCH', true, true);