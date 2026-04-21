-- =====================================================================
-- 230_premerge_fk_and_alias_cleanup_batch_5_next.sql
-- Batch 5 týmů
-- =====================================================================

-- =========================
-- AFC WIMBLEDON keep = 13535
-- old = 26524
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26524
  AND newa.team_id = 13535
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13535 WHERE team_id = 26524;
UPDATE public.league_standings         SET team_id = 13535 WHERE team_id = 26524;

SELECT public.merge_team(
    26524, 13535,
    'merge AFC Wimbledon dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- AIK STOCKHOLM keep = 13267
-- old = 25830
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25830
  AND newa.team_id = 13267
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13267 WHERE team_id = 25830;
UPDATE public.league_standings         SET team_id = 13267 WHERE team_id = 25830;

SELECT public.merge_team(
    25830, 13267,
    'merge AIK Stockholm dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- AJACCIO keep = 1029
-- old = 13579
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 13579
  AND newa.team_id = 1029
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 1029 WHERE team_id = 13579;
UPDATE public.league_standings         SET team_id = 1029 WHERE team_id = 13579;

SELECT public.merge_team(
    13579, 1029,
    'merge Ajaccio dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- ALANYASPOR keep = 13492
-- old = 25810
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25810
  AND newa.team_id = 13492
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 13492 WHERE team_id = 25810;
UPDATE public.league_standings         SET team_id = 13492 WHERE team_id = 25810;

SELECT public.merge_team(
    25810, 13492,
    'merge Alanyaspor dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- ALCORCON keep = 26319
-- old = 28678
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28678
  AND newa.team_id = 26319
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 26319 WHERE team_id = 28678;
UPDATE public.league_standings         SET team_id = 26319 WHERE team_id = 28678;

SELECT public.merge_team(
    28678, 26319,
    'merge Alcorcon dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);