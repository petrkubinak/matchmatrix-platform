-- =====================================================================
-- 250_premerge_fk_and_alias_cleanup_batch_20_next.sql
-- Dalsi batch 20 z aktualniho MULTI_MATCH exportu
-- =====================================================================

-- =========================
-- VILLANOVENSE keep = 14025
-- old = 26418
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26418
  AND newa.team_id = 14025
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14025 WHERE team_id = 26418;
UPDATE public.league_standings         SET team_id = 14025 WHERE team_id = 26418;
SELECT public.merge_team(26418, 14025, 'merge Villanovense dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- VIS PESARO keep = 13971
-- old = 26497
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26497
  AND newa.team_id = 13971
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13971 WHERE team_id = 26497;
UPDATE public.league_standings         SET team_id = 13971 WHERE team_id = 26497;
SELECT public.merge_team(26497, 13971, 'merge Vis Pesaro dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- VOLOS NFC keep = 13281
-- old = 27281
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27281
  AND newa.team_id = 13281
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13281 WHERE team_id = 27281;
UPDATE public.league_standings         SET team_id = 13281 WHERE team_id = 27281;
SELECT public.merge_team(27281, 13281, 'merge Volos NFC dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- VRCHOVINA keep = 15525
-- old = 26143
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26143
  AND newa.team_id = 15525
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 15525 WHERE team_id = 26143;
UPDATE public.league_standings         SET team_id = 15525 WHERE team_id = 26143;
SELECT public.merge_team(26143, 15525, 'merge Vrchovina dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- VUKOVAR keep = 14619
-- old = 27692
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27692
  AND newa.team_id = 14619
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14619 WHERE team_id = 27692;
UPDATE public.league_standings         SET team_id = 14619 WHERE team_id = 27692;
SELECT public.merge_team(27692, 14619, 'merge Vukovar dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- VVV VENLO keep = 1116
-- old = 12738
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12738
  AND newa.team_id = 1116
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1116 WHERE team_id = 12738;
UPDATE public.league_standings         SET team_id = 1116 WHERE team_id = 12738;
SELECT public.merge_team(12738, 1116, 'merge VVV Venlo dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- WAALWIJK keep = 1112
-- old = 12178
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12178
  AND newa.team_id = 1112
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1112 WHERE team_id = 12178;
UPDATE public.league_standings         SET team_id = 1112 WHERE team_id = 12178;
SELECT public.merge_team(12178, 1112, 'merge Waalwijk dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- WEST HAM keep = 11914
-- old = 25874
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25874
  AND newa.team_id = 11914
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 11914 WHERE team_id = 25874;
UPDATE public.league_standings         SET team_id = 11914 WHERE team_id = 25874;
SELECT public.merge_team(25874, 11914, 'merge West Ham dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- WIGAN keep = 1005
-- old = 13030
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 13030
  AND newa.team_id = 1005
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1005 WHERE team_id = 13030;
UPDATE public.league_standings         SET team_id = 1005 WHERE team_id = 13030;
SELECT public.merge_team(13030, 1005, 'merge Wigan dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- WISLA PLOCK keep = 12797
-- old = 25816
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25816
  AND newa.team_id = 12797
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12797 WHERE team_id = 25816;
UPDATE public.league_standings         SET team_id = 12797 WHERE team_id = 25816;
SELECT public.merge_team(25816, 12797, 'merge Wisla Plock dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- WYCOMBE keep = 1008
-- old = 13309
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 13309
  AND newa.team_id = 1008
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1008 WHERE team_id = 13309;
UPDATE public.league_standings         SET team_id = 1008 WHERE team_id = 13309;
SELECT public.merge_team(13309, 1008, 'merge Wycombe dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- XEREZ keep = 27708
-- old = 28817
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28817
  AND newa.team_id = 27708
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 27708 WHERE team_id = 28817;
UPDATE public.league_standings         SET team_id = 27708 WHERE team_id = 28817;
SELECT public.merge_team(28817, 27708, 'merge Xerez dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- YECLANO keep = 27658
-- old = 28796
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28796
  AND newa.team_id = 27658
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 27658 WHERE team_id = 28796;
UPDATE public.league_standings         SET team_id = 27658 WHERE team_id = 28796;
SELECT public.merge_team(28796, 27658, 'merge Yeclano dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- YVERDON SPORT keep = 12426
-- old = 26802
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26802
  AND newa.team_id = 12426
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12426 WHERE team_id = 26802;
UPDATE public.league_standings         SET team_id = 12426 WHERE team_id = 26802;
SELECT public.merge_team(26802, 12426, 'merge Yverdon Sport dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ZAMORA keep = 16999
-- old = 26321
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26321
  AND newa.team_id = 16999
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 16999 WHERE team_id = 26321;
UPDATE public.league_standings         SET team_id = 16999 WHERE team_id = 26321;
SELECT public.merge_team(26321, 16999, 'merge Zamora dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ZIRA keep = 13495
-- old = 25762
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25762
  AND newa.team_id = 13495
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13495 WHERE team_id = 25762;
UPDATE public.league_standings         SET team_id = 13495 WHERE team_id = 25762;
SELECT public.merge_team(25762, 13495, 'merge Zira dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ZNOJMO keep = 13963
-- old = 26174
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26174
  AND newa.team_id = 13963
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13963 WHERE team_id = 26174;
UPDATE public.league_standings         SET team_id = 13963 WHERE team_id = 26174;
SELECT public.merge_team(26174, 13963, 'merge Znojmo dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- AEL keep = 13018
-- old = 27071
-- =========================
-- safety recheck from current export tail / stale-risk low only if still exists
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27071
  AND newa.team_id = 13018
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13018 WHERE team_id = 27071;
UPDATE public.league_standings         SET team_id = 13018 WHERE team_id = 27071;
SELECT public.merge_team(27071, 13018, 'merge AEL dup recheck', 'FB_MULTI_MATCH', true, true);

-- =========================
-- AFC HERMANNSTADT keep = 13186
-- old = 26635
-- =========================
-- safety recheck from current export tail / stale-risk low only if still exists
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26635
  AND newa.team_id = 13186
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13186 WHERE team_id = 26635;
UPDATE public.league_standings         SET team_id = 13186 WHERE team_id = 26635;
SELECT public.merge_team(26635, 13186, 'merge AFC Hermannstadt dup recheck', 'FB_MULTI_MATCH', true, true);