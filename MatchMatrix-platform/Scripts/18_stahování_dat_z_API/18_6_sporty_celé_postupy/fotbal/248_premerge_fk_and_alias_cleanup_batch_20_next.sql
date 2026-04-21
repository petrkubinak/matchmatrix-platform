-- =====================================================================
-- 248_premerge_fk_and_alias_cleanup_batch_20_next.sql
-- Dalsi batch 20 z aktualniho MULTI_MATCH exportu
-- =====================================================================

-- =========================
-- SALAMANCA UDS keep = 27556
-- old = 28810
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28810
  AND newa.team_id = 27556
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 27556 WHERE team_id = 28810;
UPDATE public.league_standings         SET team_id = 27556 WHERE team_id = 28810;
SELECT public.merge_team(28810, 27556, 'merge Salamanca UDS dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- SAMBENEDETTESE keep = 27661
-- old = 28741
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28741
  AND newa.team_id = 27661
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 27661 WHERE team_id = 28741;
UPDATE public.league_standings         SET team_id = 27661 WHERE team_id = 28741;
SELECT public.merge_team(28741, 27661, 'merge Sambenedettese dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- SANDEFJORD keep = 13028
-- old = 27444
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27444
  AND newa.team_id = 13028
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13028 WHERE team_id = 27444;
UPDATE public.league_standings         SET team_id = 13028 WHERE team_id = 27444;
SELECT public.merge_team(27444, 13028, 'merge Sandefjord dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- SANT ANDREU keep = 13825
-- old = 27714
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27714
  AND newa.team_id = 13825
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13825 WHERE team_id = 27714;
UPDATE public.league_standings         SET team_id = 13825 WHERE team_id = 27714;
SELECT public.merge_team(27714, 13825, 'merge Sant Andreu dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- SARPSBORG 08 FF keep = 13235
-- old = 27726
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27726
  AND newa.team_id = 13235
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13235 WHERE team_id = 27726;
UPDATE public.league_standings         SET team_id = 13235 WHERE team_id = 27726;
SELECT public.merge_team(27726, 13235, 'merge Sarpsborg 08 FF dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- SELAYA keep = 27492
-- old = 28813
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28813
  AND newa.team_id = 27492
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 27492 WHERE team_id = 28813;
UPDATE public.league_standings         SET team_id = 27492 WHERE team_id = 28813;
SELECT public.merge_team(28813, 27492, 'merge Selaya dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- SIRIUS keep = 13280
-- old = 26593
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26593
  AND newa.team_id = 13280
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13280 WHERE team_id = 26593;
UPDATE public.league_standings         SET team_id = 13280 WHERE team_id = 26593;
SELECT public.merge_team(26593, 13280, 'merge Sirius dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- SLAVIA MOZYR keep = 12483
-- old = 26870
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26870
  AND newa.team_id = 12483
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12483 WHERE team_id = 26870;
UPDATE public.league_standings         SET team_id = 12483 WHERE team_id = 26870;
SELECT public.merge_team(26870, 12483, 'merge Slavia Mozyr dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- SONSECA keep = 27610
-- old = 28779
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28779
  AND newa.team_id = 27610
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 27610 WHERE team_id = 28779;
UPDATE public.league_standings         SET team_id = 27610 WHERE team_id = 28779;
SELECT public.merge_team(28779, 27610, 'merge Sonseca dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- SPARTA ROTTERDAM keep = 573
-- old = 26478
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26478
  AND newa.team_id = 573
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 573 WHERE team_id = 26478;
UPDATE public.league_standings         SET team_id = 573 WHERE team_id = 26478;
SELECT public.merge_team(26478, 573, 'merge Sparta Rotterdam dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- SPEZIA keep = 1089
-- old = 13383
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 13383
  AND newa.team_id = 1089
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1089 WHERE team_id = 13383;
UPDATE public.league_standings         SET team_id = 1089 WHERE team_id = 13383;
SELECT public.merge_team(13383, 1089, 'merge Spezia dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- SPORTING GIJON keep = 12859
-- old = 27489
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27489
  AND newa.team_id = 12859
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12859 WHERE team_id = 27489;
UPDATE public.league_standings         SET team_id = 12859 WHERE team_id = 27489;
SELECT public.merge_team(27489, 12859, 'merge Sporting Gijon dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- SS MONOPOLI keep = 14790
-- old = 25868
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25868
  AND newa.team_id = 14790
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14790 WHERE team_id = 25868;
UPDATE public.league_standings         SET team_id = 14790 WHERE team_id = 25868;
SELECT public.merge_team(25868, 14790, 'merge SS Monopoli dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- STADE LAUSANNE-OUCHY keep = 12883
-- old = 26803
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26803
  AND newa.team_id = 12883
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12883 WHERE team_id = 26803;
UPDATE public.league_standings         SET team_id = 12883 WHERE team_id = 26803;
SELECT public.merge_team(26803, 12883, 'merge Stade Lausanne-Ouchy dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- START keep = 12370
-- old = 27445
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27445
  AND newa.team_id = 12370
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12370 WHERE team_id = 27445;
UPDATE public.league_standings         SET team_id = 12370 WHERE team_id = 27445;
SELECT public.merge_team(27445, 12370, 'merge Start dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ST MIRREN keep = 12417
-- old = 27877
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27877
  AND newa.team_id = 12417
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12417 WHERE team_id = 27877;
UPDATE public.league_standings         SET team_id = 12417 WHERE team_id = 27877;
SELECT public.merge_team(27877, 12417, 'merge ST Mirren dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- TARANTO keep = 14494
-- old = 28838
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28838
  AND newa.team_id = 14494
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14494 WHERE team_id = 28838;
UPDATE public.league_standings         SET team_id = 14494 WHERE team_id = 28838;
SELECT public.merge_team(28838, 14494, 'merge Taranto dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- TARAZONA keep = 16967
-- old = 27343
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27343
  AND newa.team_id = 16967
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 16967 WHERE team_id = 27343;
UPDATE public.league_standings         SET team_id = 16967 WHERE team_id = 27343;
SELECT public.merge_team(27343, 16967, 'merge Tarazona dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- TENERIFE keep = 13210
-- old = 118276
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 118276
  AND newa.team_id = 13210
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13210 WHERE team_id = 118276;
UPDATE public.league_standings         SET team_id = 13210 WHERE team_id = 118276;
SELECT public.merge_team(118276, 13210, 'merge Tenerife dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- TERUEL keep = 14736
-- old = 26316
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26316
  AND newa.team_id = 14736
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14736 WHERE team_id = 26316;
UPDATE public.league_standings         SET team_id = 14736 WHERE team_id = 26316;
SELECT public.merge_team(26316, 14736, 'merge Teruel dup', 'FB_MULTI_MATCH', true, true);