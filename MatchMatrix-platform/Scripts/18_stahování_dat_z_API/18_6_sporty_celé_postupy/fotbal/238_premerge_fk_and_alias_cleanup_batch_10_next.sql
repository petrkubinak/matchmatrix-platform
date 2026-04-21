-- =====================================================================
-- 238_premerge_fk_and_alias_cleanup_batch_10_next.sql
-- Novy batch z aktualniho MULTI_MATCH exportu
-- =====================================================================

-- =========================
-- AD CEUTA FC keep = 26689
-- old = 28745
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28745
  AND newa.team_id = 26689
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 26689 WHERE team_id = 28745;
UPDATE public.league_standings         SET team_id = 26689 WHERE team_id = 28745;

SELECT public.merge_team(28745, 26689, 'merge AD Ceuta FC dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- AEL keep = 13018
-- old = 27071
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27071
  AND newa.team_id = 13018
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13018 WHERE team_id = 27071;
UPDATE public.league_standings         SET team_id = 13018 WHERE team_id = 27071;

SELECT public.merge_team(27071, 13018, 'merge AEL dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- AFC HERMANNSTADT keep = 13186
-- old = 26635
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26635
  AND newa.team_id = 13186
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13186 WHERE team_id = 26635;
UPDATE public.league_standings         SET team_id = 13186 WHERE team_id = 26635;

SELECT public.merge_team(26635, 13186, 'merge AFC Hermannstadt dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ALFARO keep = 27562
-- old = 28825
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28825
  AND newa.team_id = 27562
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 27562 WHERE team_id = 28825;
UPDATE public.league_standings         SET team_id = 27562 WHERE team_id = 28825;

SELECT public.merge_team(28825, 27562, 'merge Alfaro dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ANTONIANO keep = 13747
-- old = 26339
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26339
  AND newa.team_id = 13747
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13747 WHERE team_id = 26339;
UPDATE public.league_standings         SET team_id = 13747 WHERE team_id = 26339;

SELECT public.merge_team(26339, 13747, 'merge Antoniano dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- CHICLANA keep = 26401
-- old = 28768
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28768
  AND newa.team_id = 26401
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 26401 WHERE team_id = 28768;
UPDATE public.league_standings         SET team_id = 26401 WHERE team_id = 28768;

SELECT public.merge_team(28768, 26401, 'merge Chiclana dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- CHOJNICE keep = 14657
-- old = 26305
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26305
  AND newa.team_id = 14657
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 14657 WHERE team_id = 26305;
UPDATE public.league_standings         SET team_id = 14657 WHERE team_id = 26305;

SELECT public.merge_team(26305, 14657, 'merge Chojniczanka dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- CIUDAD DE LUCENA keep = 27721
-- old = 28816
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28816
  AND newa.team_id = 27721
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 27721 WHERE team_id = 28816;
UPDATE public.league_standings         SET team_id = 27721 WHERE team_id = 28816;

SELECT public.merge_team(28816, 27721, 'merge Ciudad de Lucena dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- COMPOSTELA keep = 16806
-- old = 27505
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27505
  AND newa.team_id = 16806
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 16806 WHERE team_id = 27505;
UPDATE public.league_standings         SET team_id = 16806 WHERE team_id = 27505;

SELECT public.merge_team(27505, 16806, 'merge Compostela dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- CONCORDIA keep = 13304
-- old = 28545
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28545
  AND newa.team_id = 13304
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13304 WHERE team_id = 28545;
UPDATE public.league_standings         SET team_id = 13304 WHERE team_id = 28545;

SELECT public.merge_team(28545, 13304, 'merge Concordia dup', 'FB_MULTI_MATCH', true, true);