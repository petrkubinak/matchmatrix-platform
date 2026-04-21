-- =====================================================================
-- 253_premerge_fk_and_alias_cleanup_final_triples.sql
-- Finalni 3x MULTI_MATCH pripady
-- =====================================================================

-- *********************************************************************
-- HALMSTAD
-- provider_team_id = 766
-- candidates: 12614, 27621, 28368
-- keep = 12614
-- old1 = 27621
-- old2 = 28368
-- *********************************************************************

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27621
  AND newa.team_id = 12614
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics
SET team_id = 12614
WHERE team_id = 27621;

UPDATE public.league_standings
SET team_id = 12614
WHERE team_id = 27621;

SELECT public.merge_team(
    27621,
    12614,
    'merge Halmstad triple step 1',
    'FB_MULTI_MATCH',
    true,
    true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28368
  AND newa.team_id = 12614
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics
SET team_id = 12614
WHERE team_id = 28368;

UPDATE public.league_standings
SET team_id = 12614
WHERE team_id = 28368;

SELECT public.merge_team(
    28368,
    12614,
    'merge Halmstad triple step 2',
    'FB_MULTI_MATCH',
    true,
    true
);

-- *********************************************************************
-- INTER
-- provider_team_id = 505
-- candidates: 12134, 25936, 27888
-- keep = 12134
-- old1 = 25936
-- old2 = 27888
-- *********************************************************************

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25936
  AND newa.team_id = 12134
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics
SET team_id = 12134
WHERE team_id = 25936;

UPDATE public.league_standings
SET team_id = 12134
WHERE team_id = 25936;

SELECT public.merge_team(
    25936,
    12134,
    'merge Inter triple step 1',
    'FB_MULTI_MATCH',
    true,
    true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27888
  AND newa.team_id = 12134
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics
SET team_id = 12134
WHERE team_id = 27888;

UPDATE public.league_standings
SET team_id = 12134
WHERE team_id = 27888;

SELECT public.merge_team(
    27888,
    12134,
    'merge Inter triple step 2',
    'FB_MULTI_MATCH',
    true,
    true
);

-- *********************************************************************
-- MANRESA
-- provider_team_id = 9675
-- candidates: 16745, 26376, 118266
-- keep = 16745
-- old1 = 26376
-- old2 = 118266
-- *********************************************************************

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26376
  AND newa.team_id = 16745
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics
SET team_id = 16745
WHERE team_id = 26376;

UPDATE public.league_standings
SET team_id = 16745
WHERE team_id = 26376;

SELECT public.merge_team(
    26376,
    16745,
    'merge Manresa triple step 1',
    'FB_MULTI_MATCH',
    true,
    true
);

DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 118266
  AND newa.team_id = 16745
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

UPDATE public.player_season_statistics
SET team_id = 16745
WHERE team_id = 118266;

UPDATE public.league_standings
SET team_id = 16745
WHERE team_id = 118266;

SELECT public.merge_team(
    118266,
    16745,
    'merge Manresa triple step 2',
    'FB_MULTI_MATCH',
    true,
    true
);