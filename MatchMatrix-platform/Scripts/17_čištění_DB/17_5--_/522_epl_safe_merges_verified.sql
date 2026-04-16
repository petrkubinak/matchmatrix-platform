-- 522_epl_safe_merges_verified.sql
-- Spouštěj BLOK PO BLOKU

-- =========================================================
-- Arsenal
-- OLD = 11910
-- NEW = 48
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 48
WHERE team_id = 11910;

UPDATE public.player_season_statistics
SET team_id = 48
WHERE team_id = 11910;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 11910
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 48
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    11910,
    48,
    'Audit 522 verified: Arsenal',
    'audit_522_verified_arsenal',
    true,
    true
);

COMMIT;


-- =========================================================
-- Chelsea
-- OLD = 11915
-- NEW = 50
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 50
WHERE team_id = 11915;

UPDATE public.player_season_statistics
SET team_id = 50
WHERE team_id = 11915;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 11915
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 50
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    11915,
    50,
    'Audit 522 verified: Chelsea',
    'audit_522_verified_chelsea',
    true,
    true
);

COMMIT;


-- =========================================================
-- Liverpool
-- OLD = 11908
-- NEW = 53
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 53
WHERE team_id = 11908;

UPDATE public.player_season_statistics
SET team_id = 53
WHERE team_id = 11908;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 11908
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 53
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    11908,
    53,
    'Audit 522 verified: Liverpool',
    'audit_522_verified_liverpool',
    true,
    true
);

COMMIT;


-- =========================================================
-- Brentford
-- OLD = 25875
-- NEW = 11919
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 11919
WHERE team_id = 25875;

UPDATE public.player_season_statistics
SET team_id = 11919
WHERE team_id = 25875;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 25875
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 11919
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    25875,
    11919,
    'Audit 522 verified: Brentford',
    'audit_522_verified_brentford',
    true,
    true
);

COMMIT;


-- =========================================================
-- Aston Villa
-- OLD = 27927
-- NEW = 11922
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 11922
WHERE team_id = 27927;

UPDATE public.player_season_statistics
SET team_id = 11922
WHERE team_id = 27927;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27927
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 11922
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    27927,
    11922,
    'Audit 522 verified: Aston Villa',
    'audit_522_verified_aston_villa',
    true,
    true
);

COMMIT;


-- =========================================================
-- Sunderland
-- OLD = 26985
-- NEW = 12202
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 12202
WHERE team_id = 26985;

UPDATE public.player_season_statistics
SET team_id = 12202
WHERE team_id = 26985;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 26985
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 12202
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    26985,
    12202,
    'Audit 522 verified: Sunderland',
    'audit_522_verified_sunderland',
    true,
    true
);

COMMIT;


-- =========================================================
-- Fulham
-- OLD = 26596
-- NEW = 11906
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 11906
WHERE team_id = 26596;

UPDATE public.player_season_statistics
SET team_id = 11906
WHERE team_id = 26596;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 26596
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 11906
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    26596,
    11906,
    'Audit 522 verified: Fulham',
    'audit_522_verified_fulham',
    true,
    true
);

COMMIT;