-- =====================================================================
-- 246_premerge_fk_and_alias_cleanup_batch_20_next.sql
-- Dalsi batch 20 z aktualniho MULTI_MATCH exportu
-- =====================================================================

-- =========================
-- OVIEDO keep = 12918
-- old = 25885
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25885
  AND newa.team_id = 12918
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12918 WHERE team_id = 25885;
UPDATE public.league_standings         SET team_id = 12918 WHERE team_id = 25885;
SELECT public.merge_team(25885, 12918, 'merge Oviedo dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PACOS FERREIRA keep = 1138
-- old = 14073
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 14073
  AND newa.team_id = 1138
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1138 WHERE team_id = 14073;
UPDATE public.league_standings         SET team_id = 1138 WHERE team_id = 14073;
SELECT public.merge_team(14073, 1138, 'merge Pacos Ferreira dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PADOVA keep = 14106
-- old = 28835
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28835
  AND newa.team_id = 14106
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14106 WHERE team_id = 28835;
UPDATE public.league_standings         SET team_id = 14106 WHERE team_id = 28835;
SELECT public.merge_team(28835, 14106, 'merge Padova dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PAEEK keep = 12466
-- old = 26979
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26979
  AND newa.team_id = 12466
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12466 WHERE team_id = 26979;
UPDATE public.league_standings         SET team_id = 12466 WHERE team_id = 26979;
SELECT public.merge_team(26979, 12466, 'merge PAEEK dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PANATHINAIKOS keep = 12543
-- old = 27703
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27703
  AND newa.team_id = 12543
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12543 WHERE team_id = 27703;
UPDATE public.league_standings         SET team_id = 12543 WHERE team_id = 27703;
SELECT public.merge_team(27703, 12543, 'merge Panathinaikos dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PANETOLIKOS keep = 12413
-- old = 25780
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25780
  AND newa.team_id = 12413
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12413 WHERE team_id = 25780;
UPDATE public.league_standings         SET team_id = 12413 WHERE team_id = 25780;
SELECT public.merge_team(25780, 12413, 'merge Panetolikos dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PAOK keep = 13128
-- old = 27834
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27834
  AND newa.team_id = 13128
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13128 WHERE team_id = 27834;
UPDATE public.league_standings         SET team_id = 13128 WHERE team_id = 27834;
SELECT public.merge_team(27834, 13128, 'merge PAOK dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PARTICK keep = 13226
-- old = 27878
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27878
  AND newa.team_id = 13226
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13226 WHERE team_id = 27878;
UPDATE public.league_standings         SET team_id = 13226 WHERE team_id = 27878;
SELECT public.merge_team(27878, 13226, 'merge Partick dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PAS GIANnina keep = 12289
-- old = 26852
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26852
  AND newa.team_id = 12289
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12289 WHERE team_id = 26852;
UPDATE public.league_standings         SET team_id = 12289 WHERE team_id = 26852;
SELECT public.merge_team(26852, 12289, 'merge PAS Giannina dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PESCARA keep = 14367
-- old = 27803
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27803
  AND newa.team_id = 14367
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14367 WHERE team_id = 27803;
UPDATE public.league_standings         SET team_id = 14367 WHERE team_id = 27803;
SELECT public.merge_team(27803, 14367, 'merge Pescara dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PIACENZA keep = 15095
-- old = 28836
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28836
  AND newa.team_id = 15095
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 15095 WHERE team_id = 28836;
UPDATE public.league_standings         SET team_id = 15095 WHERE team_id = 28836;
SELECT public.merge_team(28836, 15095, 'merge Piacenza dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PIRIN BLAGOEVGRAD keep = 12771
-- old = 25733
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25733
  AND newa.team_id = 12771
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12771 WHERE team_id = 25733;
UPDATE public.league_standings         SET team_id = 12771 WHERE team_id = 25733;
SELECT public.merge_team(25733, 12771, 'merge Pirin Blagoevgrad dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PLYMOUTH keep = 1001
-- old = 12206
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12206
  AND newa.team_id = 1001
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1001 WHERE team_id = 12206;
UPDATE public.league_standings         SET team_id = 1001 WHERE team_id = 12206;
SELECT public.merge_team(12206, 1001, 'merge Plymouth dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- POBLENSE keep = 26275
-- old = 28791
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28791
  AND newa.team_id = 26275
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 26275 WHERE team_id = 28791;
UPDATE public.league_standings         SET team_id = 26275 WHERE team_id = 28791;
SELECT public.merge_team(28791, 26275, 'merge Poblense dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- POGON SZCZECIN keep = 12495
-- old = 27649
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27649
  AND newa.team_id = 12495
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12495 WHERE team_id = 27649;
UPDATE public.league_standings         SET team_id = 12495 WHERE team_id = 27649;
SELECT public.merge_team(27649, 12495, 'merge Pogon Szczecin dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- POLONIA WARSZAWA keep = 12748
-- old = 25800
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25800
  AND newa.team_id = 12748
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12748 WHERE team_id = 25800;
UPDATE public.league_standings         SET team_id = 12748 WHERE team_id = 25800;
SELECT public.merge_team(25800, 12748, 'merge Polonia Warszawa dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PONTEDERA keep = 13828
-- old = 25865
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25865
  AND newa.team_id = 13828
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13828 WHERE team_id = 25865;
UPDATE public.league_standings         SET team_id = 13828 WHERE team_id = 25865;
SELECT public.merge_team(25865, 13828, 'merge Pontedera dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PONTEVEDRA keep = 27349
-- old = 28808
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28808
  AND newa.team_id = 27349
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 27349 WHERE team_id = 28808;
UPDATE public.league_standings         SET team_id = 27349 WHERE team_id = 28808;
SELECT public.merge_team(28808, 27349, 'merge Pontevedra dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PORTIMONENSE keep = 1134
-- old = 14036
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 14036
  AND newa.team_id = 1134
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1134 WHERE team_id = 14036;
UPDATE public.league_standings         SET team_id = 1134 WHERE team_id = 14036;
SELECT public.merge_team(14036, 1134, 'merge Portimonense dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- PORT VALE keep = 12597
-- old = 26984
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26984
  AND newa.team_id = 12597
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12597 WHERE team_id = 26984;
UPDATE public.league_standings         SET team_id = 12597 WHERE team_id = 26984;
SELECT public.merge_team(26984, 12597, 'merge Port Vale dup', 'FB_MULTI_MATCH', true, true);