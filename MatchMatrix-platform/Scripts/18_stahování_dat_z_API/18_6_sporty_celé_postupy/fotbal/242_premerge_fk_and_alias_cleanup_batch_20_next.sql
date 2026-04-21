-- =====================================================================
-- 242_premerge_fk_and_alias_cleanup_batch_20_next.sql
-- Dalsi batch 20 z aktualniho MULTI_MATCH exportu
-- =====================================================================

-- =========================
-- FORTUNA SITTARD keep = 572
-- old = 26896
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26896
  AND newa.team_id = 572
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 572 WHERE team_id = 26896;
UPDATE public.league_standings         SET team_id = 572 WHERE team_id = 26896;
SELECT public.merge_team(26896, 572, 'merge Fortuna Sittard dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- FREDRIKSTAD keep = 13089
-- old = 27725
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27725
  AND newa.team_id = 13089
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13089 WHERE team_id = 27725;
UPDATE public.league_standings         SET team_id = 13089 WHERE team_id = 27725;
SELECT public.merge_team(27725, 13089, 'merge Fredrikstad dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- GERNIKA keep = 16963
-- old = 26326
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26326
  AND newa.team_id = 16963
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 16963 WHERE team_id = 26326;
UPDATE public.league_standings         SET team_id = 16963 WHERE team_id = 26326;
SELECT public.merge_team(26326, 16963, 'merge Gernika dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- GETAFE II keep = 14477
-- old = 26246
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26246
  AND newa.team_id = 14477
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14477 WHERE team_id = 26246;
UPDATE public.league_standings         SET team_id = 14477 WHERE team_id = 26246;
SELECT public.merge_team(26246, 14477, 'merge Getafe II dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- GIF SUNDSVALL keep = 13195
-- old = 26595
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26595
  AND newa.team_id = 13195
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13195 WHERE team_id = 26595;
UPDATE public.league_standings         SET team_id = 13195 WHERE team_id = 26595;
SELECT public.merge_team(26595, 13195, 'merge GIF Sundsvall dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- GIUGLIANO keep = 14644
-- old = 26931
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26931
  AND newa.team_id = 14644
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14644 WHERE team_id = 26931;
UPDATE public.league_standings         SET team_id = 14644 WHERE team_id = 26931;
SELECT public.merge_team(26931, 14644, 'merge Giugliano dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- GKS KATOWICE keep = 12246
-- old = 26989
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26989
  AND newa.team_id = 12246
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12246 WHERE team_id = 26989;
UPDATE public.league_standings         SET team_id = 12246 WHERE team_id = 26989;
SELECT public.merge_team(26989, 12246, 'merge GKS Katowice dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- GO AHEAD EAGLES keep = 568
-- old = 26894
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26894
  AND newa.team_id = 568
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 568 WHERE team_id = 26894;
UPDATE public.league_standings         SET team_id = 568 WHERE team_id = 26894;
SELECT public.merge_team(26894, 568, 'merge GO Ahead Eagles dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- GORNIK ZABRZE keep = 12718
-- old = 26477
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26477
  AND newa.team_id = 12718
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12718 WHERE team_id = 26477;
UPDATE public.league_standings         SET team_id = 12718 WHERE team_id = 26477;
SELECT public.merge_team(26477, 12718, 'merge Gornik Zabrze dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- GRANADA CF keep = 12732
-- old = 27894
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27894
  AND newa.team_id = 12732
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12732 WHERE team_id = 27894;
UPDATE public.league_standings         SET team_id = 12732 WHERE team_id = 27894;
SELECT public.merge_team(27894, 12732, 'merge Granada CF dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- GRANADA II keep = 17007
-- old = 26393
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26393
  AND newa.team_id = 17007
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 17007 WHERE team_id = 26393;
UPDATE public.league_standings         SET team_id = 17007 WHERE team_id = 26393;
SELECT public.merge_team(26393, 17007, 'merge Granada II dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- GROENE STER keep = 17001
-- old = 26922
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26922
  AND newa.team_id = 17001
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 17001 WHERE team_id = 26922;
UPDATE public.league_standings         SET team_id = 17001 WHERE team_id = 26922;
SELECT public.merge_team(26922, 17001, 'merge Groene Ster dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- GUBBIO keep = 14497
-- old = 27872
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27872
  AND newa.team_id = 14497
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14497 WHERE team_id = 27872;
UPDATE public.league_standings         SET team_id = 14497 WHERE team_id = 27872;
SELECT public.merge_team(27872, 14497, 'merge Gubbio dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- GUIDONIA MONTECELIO 1937 keep = 15300
-- old = 27660
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27660
  AND newa.team_id = 15300
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 15300 WHERE team_id = 27660;
UPDATE public.league_standings         SET team_id = 15300 WHERE team_id = 27660;
SELECT public.merge_team(27660, 15300, 'merge Guidonia Montecelio 1937 dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- GUIMARAES keep = 12146
-- old = 27930
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27930
  AND newa.team_id = 12146
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12146 WHERE team_id = 27930;
UPDATE public.league_standings         SET team_id = 12146 WHERE team_id = 27930;
SELECT public.merge_team(27930, 12146, 'merge Guimaraes dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- HAPOEL BEER SHEVA keep = 13721
-- old = 25839
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25839
  AND newa.team_id = 13721
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13721 WHERE team_id = 25839;
UPDATE public.league_standings         SET team_id = 13721 WHERE team_id = 25839;
SELECT public.merge_team(25839, 13721, 'merge Hapoel Beer Sheva dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- HAPOEL KATAMON keep = 14462
-- old = 27793
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27793
  AND newa.team_id = 14462
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14462 WHERE team_id = 27793;
UPDATE public.league_standings         SET team_id = 14462 WHERE team_id = 27793;
SELECT public.merge_team(27793, 14462, 'merge Hapoel Katamon dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- HAPOEL KFAR SABA keep = 13892
-- old = 25809
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25809
  AND newa.team_id = 13892
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13892 WHERE team_id = 25809;
UPDATE public.league_standings         SET team_id = 13892 WHERE team_id = 25809;
SELECT public.merge_team(25809, 13892, 'merge Hapoel Kfar Saba dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- HAPOEL RISHON LEZION keep = 14127
-- old = 25820
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25820
  AND newa.team_id = 14127
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14127 WHERE team_id = 25820;
UPDATE public.league_standings         SET team_id = 14127 WHERE team_id = 25820;
SELECT public.merge_team(25820, 14127, 'merge Hapoel Rishon LeZion dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- HELSINGBORG keep = 12468
-- old = 26594
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26594
  AND newa.team_id = 12468
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12468 WHERE team_id = 26594;
UPDATE public.league_standings         SET team_id = 12468 WHERE team_id = 26594;
SELECT public.merge_team(26594, 12468, 'merge Helsingborg dup', 'FB_MULTI_MATCH', true, true);