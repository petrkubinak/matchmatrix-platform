-- =====================================================================
-- 233_premerge_fk_and_alias_cleanup_batch_10_next.sql
-- Batch 10 týmů
-- =====================================================================

-- =========================
-- BADALONA keep = 27578
-- old = 28784
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28784
  AND newa.team_id = 27578
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 27578 WHERE team_id = 28784;
UPDATE public.league_standings         SET team_id = 27578 WHERE team_id = 28784;

SELECT public.merge_team(
    28784, 27578,
    'merge Badalona dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BARAKALDO keep = 27753
-- old = 28785
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28785
  AND newa.team_id = 27753
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 27753 WHERE team_id = 28785;
UPDATE public.league_standings         SET team_id = 27753 WHERE team_id = 28785;

SELECT public.merge_team(
    28785, 27753,
    'merge Barakaldo dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BARBASTRO keep = 14590
-- old = 26359
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26359
  AND newa.team_id = 14590
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 14590 WHERE team_id = 26359;
UPDATE public.league_standings         SET team_id = 14590 WHERE team_id = 26359;

SELECT public.merge_team(
    26359, 14590,
    'merge Barbastro dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BARCELONA keep = 118203
-- old = 118267
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 118267
  AND newa.team_id = 118203
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 118203 WHERE team_id = 118267;
UPDATE public.league_standings         SET team_id = 118203 WHERE team_id = 118267;

SELECT public.merge_team(
    118267, 118203,
    'merge Barcelona dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BARNSLEY keep = 1006
-- old = 12890
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12890
  AND newa.team_id = 1006
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1006 WHERE team_id = 12890;
UPDATE public.league_standings         SET team_id = 1006 WHERE team_id = 12890;

SELECT public.merge_team(
    12890, 1006,
    'merge Barnsley dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BEASAIN keep = 16796
-- old = 27565
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27565
  AND newa.team_id = 16796
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 16796 WHERE team_id = 27565;
UPDATE public.league_standings         SET team_id = 16796 WHERE team_id = 27565;

SELECT public.merge_team(
    27565, 16796,
    'merge Beasain dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BEITAR JERUSALEM keep = 14252
-- old = 27794
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27794
  AND newa.team_id = 14252
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 14252 WHERE team_id = 27794;
UPDATE public.league_standings         SET team_id = 14252 WHERE team_id = 27794;

SELECT public.merge_team(
    27794, 14252,
    'merge Beitar Jerusalem dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BEROE keep = 13233
-- old = 26295
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26295
  AND newa.team_id = 13233
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13233 WHERE team_id = 26295;
UPDATE public.league_standings         SET team_id = 13233 WHERE team_id = 26295;

SELECT public.merge_team(
    26295, 13233,
    'merge Beroe dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BK HACKEN keep = 13610
-- old = 25831
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25831
  AND newa.team_id = 13610
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13610 WHERE team_id = 25831;
UPDATE public.league_standings         SET team_id = 13610 WHERE team_id = 25831;

SELECT public.merge_team(
    25831, 13610,
    'merge BK Hacken dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BLACKPOOL keep = 1003
-- old = 13685
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 13685
  AND newa.team_id = 1003
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1003 WHERE team_id = 13685;
UPDATE public.league_standings         SET team_id = 1003 WHERE team_id = 13685;

SELECT public.merge_team(
    13685, 1003,
    'merge Blackpool dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);