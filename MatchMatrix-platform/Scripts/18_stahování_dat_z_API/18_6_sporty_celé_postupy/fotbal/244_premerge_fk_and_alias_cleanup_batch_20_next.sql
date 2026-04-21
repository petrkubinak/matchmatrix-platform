-- =====================================================================
-- 244_premerge_fk_and_alias_cleanup_batch_20_next.sql
-- Dalsi batch 20 z aktualniho MULTI_MATCH exportu
-- =====================================================================

-- =========================
-- LANZAROTE keep = 26408
-- old = 28820
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28820
  AND newa.team_id = 26408
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 26408 WHERE team_id = 28820;
UPDATE public.league_standings         SET team_id = 26408 WHERE team_id = 28820;
SELECT public.merge_team(28820, 26408, 'merge Lanzarote dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- LAS ROZAS keep = 26386
-- old = 28805
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28805
  AND newa.team_id = 26386
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 26386 WHERE team_id = 28805;
UPDATE public.league_standings         SET team_id = 26386 WHERE team_id = 28805;
SELECT public.merge_team(28805, 26386, 'merge Las Rozas dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- LATINA keep = 14409
-- old = 26933
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26933
  AND newa.team_id = 14409
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14409 WHERE team_id = 26933;
UPDATE public.league_standings         SET team_id = 14409 WHERE team_id = 26933;
SELECT public.merge_team(26933, 14409, 'merge Latina dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- LAUSANNE keep = 12865
-- old = 27521
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27521
  AND newa.team_id = 12865
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12865 WHERE team_id = 27521;
UPDATE public.league_standings         SET team_id = 12865 WHERE team_id = 27521;
SELECT public.merge_team(27521, 12865, 'merge Lausanne dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- LEGIA WARSZAWA keep = 12278
-- old = 27865
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27865
  AND newa.team_id = 12278
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12278 WHERE team_id = 27865;
UPDATE public.league_standings         SET team_id = 12278 WHERE team_id = 27865;
SELECT public.merge_team(27865, 12278, 'merge Legia Warszawa dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- LEVADIAKOS keep = 13183
-- old = 27702
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27702
  AND newa.team_id = 13183
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13183 WHERE team_id = 27702;
UPDATE public.league_standings         SET team_id = 13183 WHERE team_id = 27702;
SELECT public.merge_team(27702, 13183, 'merge Levadiakos dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- LEVSKI SOFIA keep = 13353
-- old = 25782
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25782
  AND newa.team_id = 13353
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13353 WHERE team_id = 25782;
UPDATE public.league_standings         SET team_id = 13353 WHERE team_id = 25782;
SELECT public.merge_team(25782, 13353, 'merge Levski Sofia dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- LIDA keep = 13415
-- old = 28462
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28462
  AND newa.team_id = 13415
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13415 WHERE team_id = 28462;
UPDATE public.league_standings         SET team_id = 13415 WHERE team_id = 28462;
SELECT public.merge_team(28462, 13415, 'merge Lida dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- LLANERA keep = 27673
-- old = 28812
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28812
  AND newa.team_id = 27673
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 27673 WHERE team_id = 28812;
UPDATE public.league_standings         SET team_id = 27673 WHERE team_id = 28812;
SELECT public.merge_team(28812, 27673, 'merge Llanera dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- LLEIDA ESPORTIU keep = 27509
-- old = 28789
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28789
  AND newa.team_id = 27509
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 27509 WHERE team_id = 28789;
UPDATE public.league_standings         SET team_id = 27509 WHERE team_id = 28789;
SELECT public.merge_team(28789, 27509, 'merge Lleida Esportiu dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- LOKOMOTIV PLOVDIV keep = 12702
-- old = 25783
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25783
  AND newa.team_id = 12702
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12702 WHERE team_id = 25783;
UPDATE public.league_standings         SET team_id = 12702 WHERE team_id = 25783;
SELECT public.merge_team(25783, 12702, 'merge Lokomotiv Plovdiv dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- LOKOMOTIV SOFIA keep = 12720
-- old = 27533
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27533
  AND newa.team_id = 12720
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12720 WHERE team_id = 27533;
UPDATE public.league_standings         SET team_id = 12720 WHERE team_id = 27533;
SELECT public.merge_team(27533, 12720, 'merge Lokomotiv Sofia dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- LORIENT keep = 1020
-- old = 27641
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27641
  AND newa.team_id = 1020
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1020 WHERE team_id = 27641;
UPDATE public.league_standings         SET team_id = 1020 WHERE team_id = 27641;
SELECT public.merge_team(27641, 1020, 'merge Lorient dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- LUDOGORETS keep = 12589
-- old = 25731
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25731
  AND newa.team_id = 12589
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12589 WHERE team_id = 25731;
UPDATE public.league_standings         SET team_id = 12589 WHERE team_id = 25731;
SELECT public.merge_team(25731, 12589, 'merge Ludogorets dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- LYNGBY keep = 12765
-- old = 25815
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25815
  AND newa.team_id = 12765
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12765 WHERE team_id = 25815;
UPDATE public.league_standings         SET team_id = 12765 WHERE team_id = 25815;
SELECT public.merge_team(25815, 12765, 'merge Lyngby dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- MACCABI PETAH TIKVA keep = 14406
-- old = 25807
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25807
  AND newa.team_id = 14406
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 14406 WHERE team_id = 25807;
UPDATE public.league_standings         SET team_id = 14406 WHERE team_id = 25807;
SELECT public.merge_team(25807, 14406, 'merge Maccabi Petah Tikva dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- MACCABI TEL AVIV keep = 13699
-- old = 25838
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25838
  AND newa.team_id = 13699
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13699 WHERE team_id = 25838;
UPDATE public.league_standings         SET team_id = 13699 WHERE team_id = 25838;
SELECT public.merge_team(25838, 13699, 'merge Maccabi Tel Aviv dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- MALMO FF keep = 13405
-- old = 27620
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27620
  AND newa.team_id = 13405
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13405 WHERE team_id = 27620;
UPDATE public.league_standings         SET team_id = 13405 WHERE team_id = 27620;
SELECT public.merge_team(27620, 13405, 'merge Malmo FF dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- MANTOVA keep = 13399
-- old = 27098
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27098
  AND newa.team_id = 13399
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13399 WHERE team_id = 27098;
UPDATE public.league_standings         SET team_id = 13399 WHERE team_id = 27098;
SELECT public.merge_team(27098, 13399, 'merge Mantova dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- MARIBOR keep = 12230
-- old = 26999
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26999
  AND newa.team_id = 12230
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12230 WHERE team_id = 26999;
UPDATE public.league_standings         SET team_id = 12230 WHERE team_id = 26999;
SELECT public.merge_team(26999, 12230, 'merge Maribor dup', 'FB_MULTI_MATCH', true, true);