-- =====================================================================
-- 235_premerge_fk_and_alias_cleanup_batch_10_next.sql
-- Batch 10 týmů
-- =====================================================================

-- =========================
-- BRYNE keep = 13178
-- old = 27408
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27408
  AND newa.team_id = 13178
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13178 WHERE team_id = 27408;
UPDATE public.league_standings         SET team_id = 13178 WHERE team_id = 27408;

SELECT public.merge_team(
    27408, 13178,
    'merge Bryne dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- CADIZ keep = 1159
-- old = 13513
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 13513
  AND newa.team_id = 1159
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1159 WHERE team_id = 13513;
UPDATE public.league_standings         SET team_id = 1159 WHERE team_id = 13513;

SELECT public.merge_team(
    13513, 1159,
    'merge Cadiz dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- CAERNARFON TOWN keep = 13413
-- old = 26981
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26981
  AND newa.team_id = 13413
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13413 WHERE team_id = 26981;
UPDATE public.league_standings         SET team_id = 13413 WHERE team_id = 26981;

SELECT public.merge_team(
    26981, 13413,
    'merge Caernarfon Town dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- CARRARESE keep = 12319
-- old = 27644
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27644
  AND newa.team_id = 12319
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12319 WHERE team_id = 27644;
UPDATE public.league_standings         SET team_id = 12319 WHERE team_id = 27644;

SELECT public.merge_team(
    27644, 12319,
    'merge Carrarese dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- CATANZARO keep = 12285
-- old = 27096
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27096
  AND newa.team_id = 12285
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12285 WHERE team_id = 27096;
UPDATE public.league_standings         SET team_id = 12285 WHERE team_id = 27096;

SELECT public.merge_team(
    27096, 12285,
    'merge Catanzaro dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- CD CORIA keep = 16987
-- old = 26247
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26247
  AND newa.team_id = 16987
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 16987 WHERE team_id = 26247;
UPDATE public.league_standings         SET team_id = 16987 WHERE team_id = 26247;

SELECT public.merge_team(
    26247, 16987,
    'merge CD Coria dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- CELTIC keep = 13635
-- old = 26869
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26869
  AND newa.team_id = 13635
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13635 WHERE team_id = 26869;
UPDATE public.league_standings         SET team_id = 13635 WHERE team_id = 26869;

SELECT public.merge_team(
    26869, 13635,
    'merge Celtic dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- CFR 1907 CLUJ keep = 13044
-- old = 25818
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25818
  AND newa.team_id = 13044
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13044 WHERE team_id = 25818;
UPDATE public.league_standings         SET team_id = 13044 WHERE team_id = 25818;

SELECT public.merge_team(
    25818, 13044,
    'merge CFR 1907 Cluj dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- CHAVES keep = 1136
-- old = 13956
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 13956
  AND newa.team_id = 1136
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1136 WHERE team_id = 13956;
UPDATE public.league_standings         SET team_id = 1136 WHERE team_id = 13956;

SELECT public.merge_team(
    13956, 1136,
    'merge Chaves dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- CHINDIA TARGOVISTE keep = 13422
-- old = 25765
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25765
  AND newa.team_id = 13422
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13422 WHERE team_id = 25765;
UPDATE public.league_standings         SET team_id = 13422 WHERE team_id = 25765;

SELECT public.merge_team(
    25765, 13422,
    'merge Chindia Targoviste dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);