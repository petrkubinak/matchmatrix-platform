-- =====================================================================
-- 241_premerge_fk_and_alias_cleanup_batch_20_next.sql
-- Dalsi batch 20 z aktualniho MULTI_MATCH exportu
-- =====================================================================

-- =========================
-- EJEA keep = 26324
-- old = 28811
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28811
  AND newa.team_id = 26324
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 26324 WHERE team_id = 28811;
UPDATE public.league_standings         SET team_id = 26324 WHERE team_id = 28811;
SELECT public.merge_team(28811, 26324, 'merge Ejea dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ELCHE keep = 12606
-- old = 26687
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26687
  AND newa.team_id = 12606
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12606 WHERE team_id = 26687;
UPDATE public.league_standings         SET team_id = 12606 WHERE team_id = 26687;
SELECT public.merge_team(26687, 12606, 'merge Elche dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- EMMEN keep = 13306
-- old = 25843
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25843
  AND newa.team_id = 13306
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13306 WHERE team_id = 25843;
UPDATE public.league_standings         SET team_id = 13306 WHERE team_id = 25843;
SELECT public.merge_team(25843, 13306, 'merge Emmen dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ENOSIS keep = 13660
-- old = 27072
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27072
  AND newa.team_id = 13660
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13660 WHERE team_id = 27072;
UPDATE public.league_standings         SET team_id = 13660 WHERE team_id = 27072;
SELECT public.merge_team(27072, 13660, 'merge Enosis dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ESCOBEDO keep = 14457
-- old = 27493
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27493
  AND newa.team_id = 14457
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14457 WHERE team_id = 27493;
UPDATE public.league_standings         SET team_id = 14457 WHERE team_id = 27493;
SELECT public.merge_team(27493, 14457, 'merge Escobedo dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ESPANYOL II keep = 16990
-- old = 27713
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27713
  AND newa.team_id = 16990
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 16990 WHERE team_id = 27713;
UPDATE public.league_standings         SET team_id = 16990 WHERE team_id = 27713;
SELECT public.merge_team(27713, 16990, 'merge Espanyol II dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ESTEPONA keep = 14373
-- old = 26332
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26332
  AND newa.team_id = 14373
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14373 WHERE team_id = 26332;
UPDATE public.league_standings         SET team_id = 14373 WHERE team_id = 26332;
SELECT public.merge_team(26332, 14373, 'merge Estepona dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ESTRELA keep = 12158
-- old = 27496
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27496
  AND newa.team_id = 12158
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12158 WHERE team_id = 27496;
UPDATE public.league_standings         SET team_id = 12158 WHERE team_id = 27496;
SELECT public.merge_team(27496, 12158, 'merge Estrela dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- EXTREMADURA 1924 keep = 26331
-- old = 28769
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28769
  AND newa.team_id = 26331
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 26331 WHERE team_id = 28769;
UPDATE public.league_standings         SET team_id = 26331 WHERE team_id = 28769;
SELECT public.merge_team(28769, 26331, 'merge Extremadura 1924 dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- FALKENBERGS FF keep = 26590
-- old = 28682
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28682
  AND newa.team_id = 26590
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 26590 WHERE team_id = 28682;
UPDATE public.league_standings         SET team_id = 26590 WHERE team_id = 28682;
SELECT public.merge_team(28682, 26590, 'merge Falkenbergs FF dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- FARENSE keep = 1133
-- old = 12152
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12152
  AND newa.team_id = 1133
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1133 WHERE team_id = 12152;
UPDATE public.league_standings         SET team_id = 1133 WHERE team_id = 12152;
SELECT public.merge_team(12152, 1133, 'merge Farense dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- FC ANDORRA keep = 16827
-- old = 27488
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27488
  AND newa.team_id = 16827
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 16827 WHERE team_id = 27488;
UPDATE public.league_standings         SET team_id = 16827 WHERE team_id = 27488;
SELECT public.merge_team(27488, 16827, 'merge FC Andorra dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- FC AUGSBURG keep = 528
-- old = 12073
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12073
  AND newa.team_id = 528
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 528 WHERE team_id = 12073;
UPDATE public.league_standings         SET team_id = 528 WHERE team_id = 12073;
SELECT public.merge_team(12073, 528, 'merge FC Augsburg dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- FC CARTAGENA keep = 12348
-- old = 27344
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27344
  AND newa.team_id = 12348
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12348 WHERE team_id = 27344;
UPDATE public.league_standings         SET team_id = 12348 WHERE team_id = 27344;
SELECT public.merge_team(27344, 12348, 'merge FC Cartagena dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- FC MIDTJYLLAND keep = 12310
-- old = 27729
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27729
  AND newa.team_id = 12310
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12310 WHERE team_id = 27729;
UPDATE public.league_standings         SET team_id = 12310 WHERE team_id = 27729;
SELECT public.merge_team(27729, 12310, 'merge FC Midtjylland dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- FC PORTO keep = 576
-- old = 12142
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12142
  AND newa.team_id = 576
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 576 WHERE team_id = 12142;
UPDATE public.league_standings         SET team_id = 576 WHERE team_id = 12142;
SELECT public.merge_team(12142, 576, 'merge FC Porto dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- FC THUN keep = 12827
-- old = 27523
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27523
  AND newa.team_id = 12827
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12827 WHERE team_id = 27523;
UPDATE public.league_standings         SET team_id = 12827 WHERE team_id = 27523;
SELECT public.merge_team(27523, 12827, 'merge FC Thun dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- FC VOLENDAM keep = 571
-- old = 27832
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27832
  AND newa.team_id = 571
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 571 WHERE team_id = 27832;
UPDATE public.league_standings         SET team_id = 571 WHERE team_id = 27832;
SELECT public.merge_team(27832, 571, 'merge FC Volendam dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- FEYENOORD keep = 1098
-- old = 12172
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12172
  AND newa.team_id = 1098
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1098 WHERE team_id = 12172;
UPDATE public.league_standings         SET team_id = 1098 WHERE team_id = 12172;
SELECT public.merge_team(12172, 1098, 'merge Feyenoord dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- FOGGIA keep = 14188
-- old = 27664
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27664
  AND newa.team_id = 14188
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14188 WHERE team_id = 27664;
UPDATE public.league_standings         SET team_id = 14188 WHERE team_id = 27664;
SELECT public.merge_team(27664, 14188, 'merge Foggia dup', 'FB_MULTI_MATCH', true, true);