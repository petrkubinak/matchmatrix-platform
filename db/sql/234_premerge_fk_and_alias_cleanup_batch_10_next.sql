-- =====================================================================
-- 234_premerge_fk_and_alias_cleanup_batch_10_next.sql
-- Batch 10 týmů
-- =====================================================================

-- =========================
-- BLANSKO keep = 14607
-- old = 26949
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26949
  AND newa.team_id = 14607
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 14607 WHERE team_id = 26949;
UPDATE public.league_standings         SET team_id = 14607 WHERE team_id = 26949;

SELECT public.merge_team(
    26949, 14607,
    'merge Blansko dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BOAVISTA keep = 1132
-- old = 12145
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12145
  AND newa.team_id = 1132
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1132 WHERE team_id = 12145;
UPDATE public.league_standings         SET team_id = 1132 WHERE team_id = 12145;

SELECT public.merge_team(
    12145, 1132,
    'merge Boavista dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BOCHUM keep = 1055
-- old = 14347
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 14347
  AND newa.team_id = 1055
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1055 WHERE team_id = 14347;
UPDATE public.league_standings         SET team_id = 1055 WHERE team_id = 14347;

SELECT public.merge_team(
    14347, 1055,
    'merge Bochum dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BOHEMIANS 1905 II keep = 14224
-- old = 26154
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26154
  AND newa.team_id = 14224
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 14224 WHERE team_id = 26154;
UPDATE public.league_standings         SET team_id = 14224 WHERE team_id = 26154;

SELECT public.merge_team(
    26154, 14224,
    'merge Bohemians 1905 II dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BOLTON keep = 1009
-- old = 12960
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12960
  AND newa.team_id = 1009
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1009 WHERE team_id = 12960;
UPDATE public.league_standings         SET team_id = 1009 WHERE team_id = 12960;

SELECT public.merge_team(
    12960, 1009,
    'merge Bolton dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BORUSSIA MONCHENGLADBACH W keep = 14702
-- old = 26793
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26793
  AND newa.team_id = 14702
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 14702 WHERE team_id = 26793;
UPDATE public.league_standings         SET team_id = 14702 WHERE team_id = 26793;

SELECT public.merge_team(
    26793, 14702,
    'merge Borussia Monchengladbach W dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BOTEV PLOVDIV keep = 12853
-- old = 26893
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26893
  AND newa.team_id = 12853
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12853 WHERE team_id = 26893;
UPDATE public.league_standings         SET team_id = 12853 WHERE team_id = 26893;

SELECT public.merge_team(
    26893, 12853,
    'merge Botev Plovdiv dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BRANN keep = 13096
-- old = 26797
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26797
  AND newa.team_id = 13096
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13096 WHERE team_id = 26797;
UPDATE public.league_standings         SET team_id = 13096 WHERE team_id = 26797;

SELECT public.merge_team(
    26797, 13096,
    'merge Brann dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BRAVO keep = 13051
-- old = 25797
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25797
  AND newa.team_id = 13051
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13051 WHERE team_id = 25797;
UPDATE public.league_standings         SET team_id = 13051 WHERE team_id = 25797;

SELECT public.merge_team(
    25797, 13051,
    'merge Bravo dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- BRINJE-GROSUPLJE keep = 13458
-- old = 26527
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26527
  AND newa.team_id = 13458
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13458 WHERE team_id = 26527;
UPDATE public.league_standings         SET team_id = 13458 WHERE team_id = 26527;

SELECT public.merge_team(
    26527, 13458,
    'merge Brinje-Grosuplje dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);