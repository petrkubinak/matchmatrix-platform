-- =====================================================================
-- 252_premerge_fk_and_alias_cleanup_final_pairs.sql
-- Finalni ciste 2x duplicity pred 3x pripady
-- =====================================================================

-- =========================
-- REAL MADRID keep = 118250
-- old = 118275
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 118275
  AND newa.team_id = 118250
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics
SET team_id = 118250
WHERE team_id = 118275;

UPDATE public.league_standings
SET team_id = 118250
WHERE team_id = 118275;

SELECT public.merge_team(
    118275,
    118250,
    'merge Real Madrid dup final pair',
    'FB_MULTI_MATCH',
    true,
    true
);

-- =========================
-- VALENCIA keep = 27891
-- old = 118278
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 118278
  AND newa.team_id = 27891
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics
SET team_id = 27891
WHERE team_id = 118278;

UPDATE public.league_standings
SET team_id = 27891
WHERE team_id = 118278;

SELECT public.merge_team(
    118278,
    27891,
    'merge Valencia dup final pair',
    'FB_MULTI_MATCH',
    true,
    true
);