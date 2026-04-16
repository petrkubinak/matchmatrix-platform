-- 517_next_eredivisie_safe_merges.sql
-- Cíl:
-- dočistit zbylé jasné Eredivisie duplicity
-- Spouštěj BLOK PO BLOKU.

-- =========================================================
-- Ajax
-- OLD = 12161
-- NEW = 95
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 95
WHERE team_id = 12161;

UPDATE public.player_season_statistics
SET team_id = 95
WHERE team_id = 12161;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12161
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 95
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12161,
    95,
    'Audit 517: duplicate cleanup - Ajax',
    'audit_517_merge_ajax',
    true,
    true
);

COMMIT;


-- =========================================================
-- Excelsior
-- OLD = 13365
-- NEW = 557
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 557
WHERE team_id = 13365;

UPDATE public.player_season_statistics
SET team_id = 557
WHERE team_id = 13365;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 13365
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 557
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    13365,
    557,
    'Audit 517: duplicate cleanup - Excelsior',
    'audit_517_merge_excelsior',
    true,
    true
);

COMMIT;


-- =========================================================
-- Go Ahead Eagles
-- OLD = 12175
-- NEW = 568
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 568
WHERE team_id = 12175;

UPDATE public.player_season_statistics
SET team_id = 568
WHERE team_id = 12175;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12175
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 568
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12175,
    568,
    'Audit 517: duplicate cleanup - Go Ahead Eagles',
    'audit_517_merge_go_ahead_eagles',
    true,
    true
);

COMMIT;


-- =========================================================
-- FC Volendam
-- OLD = 12604
-- NEW = 571
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 571
WHERE team_id = 12604;

UPDATE public.player_season_statistics
SET team_id = 571
WHERE team_id = 12604;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12604
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 571
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12604,
    571,
    'Audit 517: duplicate cleanup - FC Volendam',
    'audit_517_merge_fc_volendam',
    true,
    true
);

COMMIT;


-- =========================================================
-- Sparta Rotterdam
-- OLD = 12182
-- NEW = 573
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 573
WHERE team_id = 12182;

UPDATE public.player_season_statistics
SET team_id = 573
WHERE team_id = 12182;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12182
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 573
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12182,
    573,
    'Audit 517: duplicate cleanup - Sparta Rotterdam',
    'audit_517_merge_sparta_rotterdam',
    true,
    true
);

COMMIT;


-- =========================================================
-- NAC Breda
-- OLD = 27528
-- NEW = 565
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 565
WHERE team_id = 27528;

UPDATE public.player_season_statistics
SET team_id = 565
WHERE team_id = 27528;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27528
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 565
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    27528,
    565,
    'Audit 517: duplicate cleanup - NAC Breda',
    'audit_517_merge_nac_breda',
    true,
    true
);

COMMIT;


-- =========================================================
-- Heerenveen
-- OLD = 12173
-- NEW = 559
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 559
WHERE team_id = 12173;

UPDATE public.player_season_statistics
SET team_id = 559
WHERE team_id = 12173;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12173
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 559
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12173,
    559,
    'Audit 517: duplicate cleanup - Heerenveen',
    'audit_517_merge_heerenveen',
    true,
    true
);

COMMIT;