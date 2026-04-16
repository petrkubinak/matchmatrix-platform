-- =====================================================================
-- 232_premerge_fk_and_alias_cleanup_batch_10.sql
-- Batch 10 týmů
-- Vzor:
--   1) alias cleanup
--   2) FK move player_season_statistics
--   3) FK move league_standings
--   4) merge_team
-- =====================================================================

-- =========================
-- ARAZ keep = 13132
-- old = 27491
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27491
  AND newa.team_id = 13132
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13132 WHERE team_id = 27491;
UPDATE public.league_standings         SET team_id = 13132 WHERE team_id = 27491;

SELECT public.merge_team(
    27491, 13132,
    'merge Araz dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- ARGES PITESTI keep = 12347
-- old = 27259
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27259
  AND newa.team_id = 12347
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12347 WHERE team_id = 27259;
UPDATE public.league_standings         SET team_id = 12347 WHERE team_id = 27259;

SELECT public.merge_team(
    27259, 12347,
    'merge Arges Pitesti dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- ARIS keep = 12561
-- old = 27073
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27073
  AND newa.team_id = 12561
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12561 WHERE team_id = 27073;
UPDATE public.league_standings         SET team_id = 12561 WHERE team_id = 27073;

SELECT public.merge_team(
    27073, 12561,
    'merge Aris dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- ARKA GDYNIA keep = 13208
-- old = 25817
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25817
  AND newa.team_id = 13208
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13208 WHERE team_id = 25817;
UPDATE public.league_standings         SET team_id = 13208 WHERE team_id = 25817;

SELECT public.merge_team(
    25817, 13208,
    'merge Arka Gdynia dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- AS ROMA keep = 538
-- old = 27695
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27695
  AND newa.team_id = 538
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 538 WHERE team_id = 27695;
UPDATE public.league_standings         SET team_id = 538 WHERE team_id = 27695;

SELECT public.merge_team(
    27695, 538,
    'merge AS Roma dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- ASTERAS TRIPOLIS keep = 13448
-- old = 27016
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27016
  AND newa.team_id = 13448
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13448 WHERE team_id = 27016;
UPDATE public.league_standings         SET team_id = 13448 WHERE team_id = 27016;

SELECT public.merge_team(
    27016, 13448,
    'merge Asteras Tripolis dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- ATHLETIC CLUB keep = 78
-- old = 12084
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12084
  AND newa.team_id = 78
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 78 WHERE team_id = 12084;
UPDATE public.league_standings         SET team_id = 78 WHERE team_id = 12084;

SELECT public.merge_team(
    12084, 78,
    'merge Athletic Club dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- AUDACE CERIGNOLA keep = 13835
-- old = 25873
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25873
  AND newa.team_id = 13835
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13835 WHERE team_id = 25873;
UPDATE public.league_standings         SET team_id = 13835 WHERE team_id = 25873;

SELECT public.merge_team(
    25873, 13835,
    'merge Audace Cerignola dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- AVS keep = 591
-- old = 12159
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12159
  AND newa.team_id = 591
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 591 WHERE team_id = 12159;
UPDATE public.league_standings         SET team_id = 591 WHERE team_id = 12159;

SELECT public.merge_team(
    12159, 591,
    'merge AVS dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- AZ PICERNO keep = 13968
-- old = 27874
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27874
  AND newa.team_id = 13968
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13968 WHERE team_id = 27874;
UPDATE public.league_standings         SET team_id = 13968 WHERE team_id = 27874;

SELECT public.merge_team(
    27874, 13968,
    'merge AZ Picerno dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);