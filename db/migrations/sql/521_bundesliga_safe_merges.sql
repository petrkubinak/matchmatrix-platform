-- 521_bundesliga_safe_merges.sql
-- Spouštěj BLOK PO BLOKU

-- =========================================================
-- VfL Wolfsburg
-- OLD = 12065
-- NEW = 525
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 525
WHERE team_id = 12065;

UPDATE public.player_season_statistics
SET team_id = 525
WHERE team_id = 12065;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12065
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 525
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12065,
    525,
    'Audit 521: VfL Wolfsburg',
    'audit_521_vfl_wolfsburg',
    true,
    true
);

COMMIT;


-- =========================================================
-- Bayer Leverkusen
-- OLD = 12071
-- NEW = 68
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 68
WHERE team_id = 12071;

UPDATE public.player_season_statistics
SET team_id = 68
WHERE team_id = 12071;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12071
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 68
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12071,
    68,
    'Audit 521: Bayer Leverkusen',
    'audit_521_bayer_leverkusen',
    true,
    true
);

COMMIT;


-- =========================================================
-- 1. FC Heidenheim
-- OLD = 12077
-- NEW = 530
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 530
WHERE team_id = 12077;

UPDATE public.player_season_statistics
SET team_id = 530
WHERE team_id = 12077;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12077
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 530
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12077,
    530,
    'Audit 521: 1. FC Heidenheim',
    'audit_521_heidenheim',
    true,
    true
);

COMMIT;


-- =========================================================
-- Hamburger SV
-- OLD = 12379
-- NEW = 523
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 523
WHERE team_id = 12379;

UPDATE public.player_season_statistics
SET team_id = 523
WHERE team_id = 12379;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12379
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 523
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12379,
    523,
    'Audit 521: Hamburger SV',
    'audit_521_hamburger_sv',
    true,
    true
);

COMMIT;


-- =========================================================
-- RB Leipzig
-- OLD = 12075
-- NEW = 535
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 535
WHERE team_id = 12075;

UPDATE public.player_season_statistics
SET team_id = 535
WHERE team_id = 12075;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12075
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 535
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12075,
    535,
    'Audit 521: RB Leipzig',
    'audit_521_rb_leipzig',
    true,
    true
);

COMMIT;


-- =========================================================
-- FSV Mainz 05
-- OLD = 12068
-- NEW = 527
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 527
WHERE team_id = 12068;

UPDATE public.player_season_statistics
SET team_id = 527
WHERE team_id = 12068;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12068
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 527
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12068,
    527,
    'Audit 521: FSV Mainz 05',
    'audit_521_mainz_05',
    true,
    true
);

COMMIT;


-- =========================================================
-- SC Freiburg
-- OLD = 12064
-- NEW = 529
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 529
WHERE team_id = 12064;

UPDATE public.player_season_statistics
SET team_id = 529
WHERE team_id = 12064;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12064
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 529
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12064,
    529,
    'Audit 521: SC Freiburg',
    'audit_521_sc_freiburg',
    true,
    true
);

COMMIT;


-- =========================================================
-- VfB Stuttgart
-- OLD = 12074
-- NEW = 524
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 524
WHERE team_id = 12074;

UPDATE public.player_season_statistics
SET team_id = 524
WHERE team_id = 12074;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12074
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 524
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12074,
    524,
    'Audit 521: VfB Stuttgart',
    'audit_521_vfb_stuttgart',
    true,
    true
);

COMMIT;


-- =========================================================
-- Borussia Dortmund
-- OLD = 12069
-- NEW = 69
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 69
WHERE team_id = 12069;

UPDATE public.player_season_statistics
SET team_id = 69
WHERE team_id = 12069;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12069
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 69
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12069,
    69,
    'Audit 521: Borussia Dortmund',
    'audit_521_borussia_dortmund',
    true,
    true
);

COMMIT;


-- =========================================================
-- Union Berlin / Eintracht Frankfurt
-- POZOR: OLD 12072 se v datech používá pro Eintracht Frankfurt,
-- zatímco Union Berlin už je 533.
-- Proto 12072 -> 71.
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 71
WHERE team_id = 12072;

UPDATE public.player_season_statistics
SET team_id = 71
WHERE team_id = 12072;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12072
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 71
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12072,
    71,
    'Audit 521: Eintracht Frankfurt',
    'audit_521_eintracht_frankfurt',
    true,
    true
);

COMMIT;


-- =========================================================
-- FC St. Pauli
-- OLD = 12079
-- NEW = 533
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 533
WHERE team_id = 12079;

UPDATE public.player_season_statistics
SET team_id = 533
WHERE team_id = 12079;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12079
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 533
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12079,
    533,
    'Audit 521: FC St. Pauli',
    'audit_521_fc_st_pauli',
    true,
    true
);

COMMIT;


-- =========================================================
-- Werder Bremen
-- OLD = 27655
-- NEW = 526
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 526
WHERE team_id = 27655;

UPDATE public.player_season_statistics
SET team_id = 526
WHERE team_id = 27655;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27655
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 526
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    27655,
    526,
    'Audit 521: Werder Bremen',
    'audit_521_werder_bremen',
    true,
    true
);

COMMIT;