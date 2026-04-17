-- =====================================================================
-- 239_premerge_fk_and_alias_cleanup_batch_10_next.sql
-- Dalsi batch z aktualniho MULTI_MATCH exportu
-- =====================================================================

-- =========================
-- CONQUENSE keep = 26341
-- old = 28786
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28786
  AND newa.team_id = 26341
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 26341 WHERE team_id = 28786;
UPDATE public.league_standings         SET team_id = 26341 WHERE team_id = 28786;

SELECT public.merge_team(28786, 26341, 'merge Conquense dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- CORDOBA keep = 12934
-- old = 27750
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27750
  AND newa.team_id = 12934
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12934 WHERE team_id = 27750;
UPDATE public.league_standings         SET team_id = 12934 WHERE team_id = 27750;

SELECT public.merge_team(27750, 12934, 'merge Cordoba dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- CRACOVIA KRAKOW keep = 12363
-- old = 27866
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27866
  AND newa.team_id = 12363
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12363 WHERE team_id = 27866;
UPDATE public.league_standings         SET team_id = 12363 WHERE team_id = 27866;

SELECT public.merge_team(27866, 12363, 'merge Cracovia Krakow dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- CSKA 1948 keep = 13447
-- old = 26892
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26892
  AND newa.team_id = 13447
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13447 WHERE team_id = 26892;
UPDATE public.league_standings         SET team_id = 13447 WHERE team_id = 26892;

SELECT public.merge_team(26892, 13447, 'merge CSKA 1948 dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- CSKA SOFIA keep = 12228
-- old = 27532
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27532
  AND newa.team_id = 12228
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12228 WHERE team_id = 27532;
UPDATE public.league_standings         SET team_id = 12228 WHERE team_id = 27532;

SELECT public.merge_team(27532, 12228, 'merge CSKA Sofia dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- CULTURAL LEONESA keep = 25857
-- old = 28799
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28799
  AND newa.team_id = 25857
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 25857 WHERE team_id = 28799;
UPDATE public.league_standings         SET team_id = 25857 WHERE team_id = 28799;

SELECT public.merge_team(28799, 25857, 'merge Cultural Leonesa dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- DEGERFORS IF keep = 13441
-- old = 27188
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27188
  AND newa.team_id = 13441
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13441 WHERE team_id = 27188;
UPDATE public.league_standings         SET team_id = 13441 WHERE team_id = 27188;

SELECT public.merge_team(27188, 13441, 'merge Degerfors IF dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- DE GRAAFSCHAP keep = 12165
-- old = 26480
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26480
  AND newa.team_id = 12165
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12165 WHERE team_id = 26480;
UPDATE public.league_standings         SET team_id = 12165 WHERE team_id = 26480;

SELECT public.merge_team(26480, 12165, 'merge De Graafschap dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- DEKANI keep = 12953
-- old = 27003
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27003
  AND newa.team_id = 12953
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12953 WHERE team_id = 27003;
UPDATE public.league_standings         SET team_id = 12953 WHERE team_id = 27003;

SELECT public.merge_team(27003, 12953, 'merge Dekani dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- DEN BOSCH keep = 12181
-- old = 26901
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26901
  AND newa.team_id = 12181
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12181 WHERE team_id = 26901;
UPDATE public.league_standings         SET team_id = 12181 WHERE team_id = 26901;

SELECT public.merge_team(26901, 12181, 'merge Den Bosch dup', 'FB_MULTI_MATCH', true, true);