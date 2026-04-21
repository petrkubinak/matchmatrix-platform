-- =====================================================================
-- 229_premerge_fk_and_alias_cleanup_batch_5.sql
-- Batch 5 týmů
-- =====================================================================

-- =========================
-- MARITIMO keep = 1137
-- old = 14641, 27498
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 14641
  AND newa.team_id = 1137
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1137 WHERE team_id = 14641;
UPDATE public.league_standings         SET team_id = 1137 WHERE team_id = 14641;

SELECT public.merge_team(
    14641, 1137,
    'merge Maritimo api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27498
  AND newa.team_id = 1137
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1137 WHERE team_id = 27498;
UPDATE public.league_standings         SET team_id = 1137 WHERE team_id = 27498;

SELECT public.merge_team(
    27498, 1137,
    'merge Maritimo api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- AALESUND keep = 13181
-- old = 25829
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25829
  AND newa.team_id = 13181
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13181 WHERE team_id = 25829;
UPDATE public.league_standings         SET team_id = 13181 WHERE team_id = 25829;

SELECT public.merge_team(
    25829, 13181,
    'merge Aalesund api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- AARHUS keep = 13156
-- old = 27730
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27730
  AND newa.team_id = 13156
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13156 WHERE team_id = 27730;
UPDATE public.league_standings         SET team_id = 13156 WHERE team_id = 27730;

SELECT public.merge_team(
    27730, 13156,
    'merge Aarhus api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- AC HORSENS keep = 12236
-- old = 25814
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25814
  AND newa.team_id = 12236
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12236 WHERE team_id = 25814;
UPDATE public.league_standings         SET team_id = 12236 WHERE team_id = 25814;

SELECT public.merge_team(
    25814, 12236,
    'merge AC Horsens api_sport dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- AC MILAN keep = 536
-- old = 12122
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12122
  AND newa.team_id = 536
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 536 WHERE team_id = 12122;
UPDATE public.league_standings         SET team_id = 536 WHERE team_id = 12122;

SELECT public.merge_team(
    12122, 536,
    'merge AC Milan api_football dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);