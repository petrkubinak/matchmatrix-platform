-- =====================================================================
-- 247_premerge_fk_and_alias_cleanup_batch_20_next.sql
-- Dalsi batch 20 z aktualniho MULTI_MATCH exportu
-- =====================================================================

-- =========================
-- POTENZA keep = 14463
-- old = 27665
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27665
  AND newa.team_id = 14463
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14463 WHERE team_id = 27665;
UPDATE public.league_standings         SET team_id = 14463 WHERE team_id = 27665;
SELECT public.merge_team(27665, 14463, 'merge Potenza dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- POVLTAVA FA keep = 13924
-- old = 27168
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27168
  AND newa.team_id = 13924
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13924 WHERE team_id = 27168;
UPDATE public.league_standings         SET team_id = 13924 WHERE team_id = 27168;
SELECT public.merge_team(27168, 13924, 'merge Povltava FA dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- QARABAG keep = 13648
-- old = 27490
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27490
  AND newa.team_id = 13648
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13648 WHERE team_id = 27490;
UPDATE public.league_standings         SET team_id = 13648 WHERE team_id = 27490;
SELECT public.merge_team(27490, 13648, 'merge Qarabag dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- QPR keep = 12198
-- old = 27652
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27652
  AND newa.team_id = 12198
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12198 WHERE team_id = 27652;
UPDATE public.league_standings         SET team_id = 12198 WHERE team_id = 27652;
SELECT public.merge_team(27652, 12198, 'merge QPR dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- RACING FERROL keep = 12825
-- old = 27869
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27869
  AND newa.team_id = 12825
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12825 WHERE team_id = 27869;
UPDATE public.league_standings         SET team_id = 12825 WHERE team_id = 27869;
SELECT public.merge_team(27869, 12825, 'merge Racing Ferrol dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- RACING SANTANDER keep = 13693
-- old = 27749
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27749
  AND newa.team_id = 13693
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13693 WHERE team_id = 27749;
UPDATE public.league_standings         SET team_id = 13693 WHERE team_id = 27749;
SELECT public.merge_team(27749, 13693, 'merge Racing Santander dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- RADOMIAK RADOM keep = 13259
-- old = 26988
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26988
  AND newa.team_id = 13259
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13259 WHERE team_id = 26988;
UPDATE public.league_standings         SET team_id = 13259 WHERE team_id = 26988;
SELECT public.merge_team(26988, 13259, 'merge Radomiak Radom dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- RADOMLJE keep = 12854
-- old = 25796
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25796
  AND newa.team_id = 12854
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12854 WHERE team_id = 25796;
UPDATE public.league_standings         SET team_id = 12854 WHERE team_id = 25796;
SELECT public.merge_team(25796, 12854, 'merge Radomlje dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- RANGERS keep = 12291
-- old = 26868
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26868
  AND newa.team_id = 12291
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12291 WHERE team_id = 26868;
UPDATE public.league_standings         SET team_id = 12291 WHERE team_id = 26868;
SELECT public.merge_team(26868, 12291, 'merge Rangers dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- RAPID keep = 12707
-- old = 27765
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27765
  AND newa.team_id = 12707
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12707 WHERE team_id = 27765;
UPDATE public.league_standings         SET team_id = 12707 WHERE team_id = 27765;
SELECT public.merge_team(27765, 12707, 'merge Rapid dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- RAYO MAJADAHONDA keep = 14348
-- old = 27758
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27758
  AND newa.team_id = 14348
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14348 WHERE team_id = 27758;
UPDATE public.league_standings         SET team_id = 14348 WHERE team_id = 27758;
SELECT public.merge_team(27758, 14348, 'merge Rayo Majadahonda dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- READING keep = 1004
-- old = 13650
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 13650
  AND newa.team_id = 1004
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1004 WHERE team_id = 13650;
UPDATE public.league_standings         SET team_id = 1004 WHERE team_id = 13650;
SELECT public.merge_team(13650, 1004, 'merge Reading dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- REAL MADRID III keep = 14062
-- old = 26346
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26346
  AND newa.team_id = 14062
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14062 WHERE team_id = 26346;
UPDATE public.league_standings         SET team_id = 14062 WHERE team_id = 26346;
SELECT public.merge_team(26346, 14062, 'merge Real Madrid III dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- REAL ZARAGOZA II keep = 16733
-- old = 26328
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26328
  AND newa.team_id = 16733
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 16733 WHERE team_id = 26328;
UPDATE public.league_standings         SET team_id = 16733 WHERE team_id = 26328;
SELECT public.merge_team(26328, 16733, 'merge Real Zaragoza II dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- RECREATIVO HUELVA keep = 16852
-- old = 26397
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26397
  AND newa.team_id = 16852
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 16852 WHERE team_id = 26397;
UPDATE public.league_standings         SET team_id = 16852 WHERE team_id = 26397;
SELECT public.merge_team(26397, 16852, 'merge Recreativo Huelva dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- RENNES keep = 1010
-- old = 27643
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27643
  AND newa.team_id = 1010
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1010 WHERE team_id = 27643;
UPDATE public.league_standings         SET team_id = 1010 WHERE team_id = 27643;
SELECT public.merge_team(27643, 1010, 'merge Rennes dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- RIO AVE keep = 12148
-- old = 25895
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25895
  AND newa.team_id = 12148
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12148 WHERE team_id = 25895;
UPDATE public.league_standings         SET team_id = 12148 WHERE team_id = 25895;
SELECT public.merge_team(25895, 12148, 'merge Rio Ave dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ROSENBORG keep = 12818
-- old = 27409
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27409
  AND newa.team_id = 12818
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12818 WHERE team_id = 27409;
UPDATE public.league_standings         SET team_id = 12818 WHERE team_id = 27409;
SELECT public.merge_team(27409, 12818, 'merge Rosenborg dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ROTHERHAM keep = 1002
-- old = 12814
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12814
  AND newa.team_id = 1002
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1002 WHERE team_id = 12814;
UPDATE public.league_standings         SET team_id = 1002 WHERE team_id = 12814;
SELECT public.merge_team(12814, 1002, 'merge Rotherham dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- RUDAR keep = 13110
-- old = 26977
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26977
  AND newa.team_id = 13110
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13110 WHERE team_id = 26977;
UPDATE public.league_standings         SET team_id = 13110 WHERE team_id = 26977;
SELECT public.merge_team(26977, 13110, 'merge Rudar dup', 'FB_MULTI_MATCH', true, true);