-- =====================================================================
-- 243_premerge_fk_and_alias_cleanup_batch_20_next.sql
-- Dalsi batch 20 z aktualniho MULTI_MATCH exportu
-- =====================================================================

-- =========================
-- HERTHA BSC keep = 12920
-- old = 26641
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26641
  AND newa.team_id = 12920
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12920 WHERE team_id = 26641;
UPDATE public.league_standings         SET team_id = 12920 WHERE team_id = 26641;
SELECT public.merge_team(26641, 12920, 'merge Hertha BSC dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- HNK CIBALIA keep = 14548
-- old = 26482
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26482
  AND newa.team_id = 14548
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14548 WHERE team_id = 26482;
UPDATE public.league_standings         SET team_id = 14548 WHERE team_id = 26482;
SELECT public.merge_team(26482, 14548, 'merge HNK Cibalia dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- HNK HAJDUK SPLIT keep = 13003
-- old = 26996
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26996
  AND newa.team_id = 13003
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13003 WHERE team_id = 26996;
UPDATE public.league_standings         SET team_id = 13003 WHERE team_id = 26996;
SELECT public.merge_team(26996, 13003, 'merge HNK Hajduk Split dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- HNK RIJEKA keep = 12607
-- old = 27693
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27693
  AND newa.team_id = 12607
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12607 WHERE team_id = 27693;
UPDATE public.league_standings         SET team_id = 12607 WHERE team_id = 27693;
SELECT public.merge_team(27693, 12607, 'merge HNK Rijeka dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- HOLSTEIN KIEL keep = 1054
-- old = 12080
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12080
  AND newa.team_id = 1054
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1054 WHERE team_id = 12080;
UPDATE public.league_standings         SET team_id = 1054 WHERE team_id = 12080;
SELECT public.merge_team(12080, 1054, 'merge Holstein Kiel dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- HUESCA keep = 1162
-- old = 12552
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12552
  AND newa.team_id = 1162
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1162 WHERE team_id = 12552;
UPDATE public.league_standings         SET team_id = 1162 WHERE team_id = 12552;
SELECT public.merge_team(12552, 1162, 'merge Huesca dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- IBIZA ISLAS PITIUSAS keep = 26358
-- old = 28818
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28818
  AND newa.team_id = 26358
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 26358 WHERE team_id = 28818;
UPDATE public.league_standings         SET team_id = 26358 WHERE team_id = 28818;
SELECT public.merge_team(28818, 26358, 'merge Ibiza Islas Pitiusas dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- IF BROMMAPOJKARNA keep = 12408
-- old = 26589
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26589
  AND newa.team_id = 12408
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12408 WHERE team_id = 26589;
UPDATE public.league_standings         SET team_id = 12408 WHERE team_id = 26589;
SELECT public.merge_team(26589, 12408, 'merge IF Brommapojkarna dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- IF ELFSBORG keep = 13331
-- old = 26592
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26592
  AND newa.team_id = 13331
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13331 WHERE team_id = 26592;
UPDATE public.league_standings         SET team_id = 13331 WHERE team_id = 26592;
SELECT public.merge_team(26592, 13331, 'merge IF Elfsborg dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- IFK GOTEBORG keep = 12425
-- old = 27187
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27187
  AND newa.team_id = 12425
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12425 WHERE team_id = 27187;
UPDATE public.league_standings         SET team_id = 12425 WHERE team_id = 27187;
SELECT public.merge_team(27187, 12425, 'merge IFK Goteborg dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- JUVENTUD TORREMOLINOS keep = 26318
-- old = 28764
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28764
  AND newa.team_id = 26318
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 26318 WHERE team_id = 28764;
UPDATE public.league_standings         SET team_id = 26318 WHERE team_id = 28764;
SELECT public.merge_team(28764, 26318, 'merge Juventud Torremolinos dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- JUVENTUS U23 keep = 13829
-- old = 26496
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26496
  AND newa.team_id = 13829
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13829 WHERE team_id = 26496;
UPDATE public.league_standings         SET team_id = 13829 WHERE team_id = 26496;
SELECT public.merge_team(26496, 13829, 'merge Juventus U23 dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- JUVE STABIA keep = 12849
-- old = 27099
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27099
  AND newa.team_id = 12849
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12849 WHERE team_id = 27099;
UPDATE public.league_standings         SET team_id = 12849 WHERE team_id = 27099;
SELECT public.merge_team(27099, 12849, 'merge Juve Stabia dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- KAFR QASIM keep = 13887
-- old = 25821
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25821
  AND newa.team_id = 13887
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13887 WHERE team_id = 25821;
UPDATE public.league_standings         SET team_id = 13887 WHERE team_id = 25821;
SELECT public.merge_team(25821, 13887, 'merge Kafr Qasim dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- KALISZ keep = 14567
-- old = 26304
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26304
  AND newa.team_id = 14567
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14567 WHERE team_id = 26304;
UPDATE public.league_standings         SET team_id = 14567 WHERE team_id = 26304;
SELECT public.merge_team(26304, 14567, 'merge Kalisz dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- KAPAZ keep = 13165
-- old = 25763
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25763
  AND newa.team_id = 13165
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13165 WHERE team_id = 25763;
UPDATE public.league_standings         SET team_id = 13165 WHERE team_id = 25763;
SELECT public.merge_team(25763, 13165, 'merge Kapaz dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- KARLOVY VARY keep = 16991
-- old = 28420
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28420
  AND newa.team_id = 16991
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 16991 WHERE team_id = 28420;
UPDATE public.league_standings         SET team_id = 16991 WHERE team_id = 28420;
SELECT public.merge_team(28420, 16991, 'merge Karlovy Vary dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- KOPER keep = 13017
-- old = 27651
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27651
  AND newa.team_id = 13017
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13017 WHERE team_id = 27651;
UPDATE public.league_standings         SET team_id = 13017 WHERE team_id = 27651;
SELECT public.merge_team(27651, 13017, 'merge Koper dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- KRKA keep = 12362
-- old = 27215
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27215
  AND newa.team_id = 12362
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12362 WHERE team_id = 27215;
UPDATE public.league_standings         SET team_id = 12362 WHERE team_id = 27215;
SELECT public.merge_team(27215, 12362, 'merge Krka dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- LANGREO keep = 27555
-- old = 28788
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28788
  AND newa.team_id = 27555
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 27555 WHERE team_id = 28788;
UPDATE public.league_standings         SET team_id = 27555 WHERE team_id = 28788;
SELECT public.merge_team(28788, 27555, 'merge Langreo dup', 'FB_MULTI_MATCH', true, true);