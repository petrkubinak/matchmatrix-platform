-- =====================================================================
-- 231_premerge_fk_and_alias_cleanup_batch_5_next.sql
-- Batch 5 týmů
-- =====================================================================

-- =========================
-- ALUMINIJ keep = 12574
-- old = 27650
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27650
  AND newa.team_id = 12574
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12574 WHERE team_id = 27650;
UPDATE public.league_standings         SET team_id = 12574 WHERE team_id = 27650;

SELECT public.merge_team(
    27650, 12574,
    'merge Aluminij dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- AMOREBIETA keep = 27563
-- old = 28691
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28691
  AND newa.team_id = 27563
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 27563 WHERE team_id = 28691;
UPDATE public.league_standings         SET team_id = 27563 WHERE team_id = 28691;

SELECT public.merge_team(
    28691, 27563,
    'merge Amorebieta dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- ANORTHOSIS keep = 12998
-- old = 27340
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27340
  AND newa.team_id = 12998
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12998 WHERE team_id = 27340;
UPDATE public.league_standings         SET team_id = 12998 WHERE team_id = 27340;

SELECT public.merge_team(
    27340, 12998,
    'merge Anorthosis dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- APOEL NICOSIA keep = 12860
-- old = 27339
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27339
  AND newa.team_id = 12860
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12860 WHERE team_id = 27339;
UPDATE public.league_standings         SET team_id = 12860 WHERE team_id = 27339;

SELECT public.merge_team(
    27339, 12860,
    'merge Apoel Nicosia dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);

-- =========================
-- APOLLON LIMASSOL keep = 12898
-- old = 27070
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27070
  AND newa.team_id = 12898
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics SET team_id = 12898 WHERE team_id = 27070;
UPDATE public.league_standings         SET team_id = 12898 WHERE team_id = 27070;

SELECT public.merge_team(
    27070, 12898,
    'merge Apollon Limassol dup after FK+alias cleanup',
    'FB_MULTI_MATCH', true, true
);