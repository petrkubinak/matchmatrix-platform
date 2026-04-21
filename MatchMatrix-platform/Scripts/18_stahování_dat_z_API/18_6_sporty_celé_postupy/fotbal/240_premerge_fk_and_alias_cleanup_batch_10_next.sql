-- =====================================================================
-- 240_premerge_fk_and_alias_cleanup_batch_10_next.sql
-- Dalsi batch z aktualniho MULTI_MATCH exportu
-- =====================================================================

-- =========================
-- DEPORTIVA MINERA keep = 26334
-- old = 28821
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28821
  AND newa.team_id = 26334
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 26334 WHERE team_id = 28821;
UPDATE public.league_standings         SET team_id = 26334 WHERE team_id = 28821;

SELECT public.merge_team(28821, 26334, 'merge Deportiva Minera dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- DEPORTIVO LA CORUNA keep = 12984
-- old = 27893
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27893
  AND newa.team_id = 12984
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12984 WHERE team_id = 27893;
UPDATE public.league_standings         SET team_id = 12984 WHERE team_id = 27893;

SELECT public.merge_team(27893, 12984, 'merge Deportivo La Coruna dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- DINAMO BREST keep = 12438
-- old = 26456
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26456
  AND newa.team_id = 12438
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12438 WHERE team_id = 26456;
UPDATE public.league_standings         SET team_id = 12438 WHERE team_id = 26456;

SELECT public.merge_team(26456, 12438, 'merge Dinamo Brest dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- DINAMO BUCURESTI keep = 13585
-- old = 25819
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25819
  AND newa.team_id = 13585
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13585 WHERE team_id = 25819;
UPDATE public.league_standings         SET team_id = 13585 WHERE team_id = 25819;

SELECT public.merge_team(25819, 13585, 'merge Dinamo Bucuresti dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- DINAMO ZAGREB keep = 12284
-- old = 26997
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26997
  AND newa.team_id = 12284
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12284 WHERE team_id = 26997;
UPDATE public.league_standings         SET team_id = 12284 WHERE team_id = 26997;

SELECT public.merge_team(26997, 12284, 'merge Dinamo Zagreb dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- DJURGARDENS IF keep = 13081
-- old = 26588
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26588
  AND newa.team_id = 13081
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13081 WHERE team_id = 26588;
UPDATE public.league_standings         SET team_id = 13081 WHERE team_id = 26588;

SELECT public.merge_team(26588, 13081, 'merge Djurgardens IF dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- DOBRUDZHA keep = 12437
-- old = 26294
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26294
  AND newa.team_id = 12437
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12437 WHERE team_id = 26294;
UPDATE public.league_standings         SET team_id = 12437 WHERE team_id = 26294;

SELECT public.merge_team(26294, 12437, 'merge Dobrudzha dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- DON BENITO keep = 27597
-- old = 28787
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28787
  AND newa.team_id = 27597
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 27597 WHERE team_id = 28787;
UPDATE public.league_standings         SET team_id = 27597 WHERE team_id = 28787;

SELECT public.merge_team(28787, 27597, 'merge Don Benito dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- DUKLA PRAHA II keep = 14523
-- old = 26156
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26156
  AND newa.team_id = 14523
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 14523 WHERE team_id = 26156;
UPDATE public.league_standings         SET team_id = 14523 WHERE team_id = 26156;

SELECT public.merge_team(26156, 14523, 'merge Dukla Praha II dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- EINTRACHT FRANKFURT keep = 71
-- old = 27218
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27218
  AND newa.team_id = 71
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 71 WHERE team_id = 27218;
UPDATE public.league_standings         SET team_id = 71 WHERE team_id = 27218;

SELECT public.merge_team(27218, 71, 'merge Eintracht Frankfurt dup', 'FB_MULTI_MATCH', true, true);