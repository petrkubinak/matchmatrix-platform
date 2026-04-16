-- 520_serie_a_safe_merges.sql
-- Spouštěj BLOK PO BLOKU

-- =========================================================
-- Sassuolo
-- OLD = 12303
-- NEW = 551
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 551
WHERE team_id = 12303;

UPDATE public.player_season_statistics
SET team_id = 551
WHERE team_id = 12303;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12303
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 551
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12303,
    551,
    'Audit 520: Sassuolo',
    'audit_520_sassuolo',
    true,
    true
);

COMMIT;


-- =========================================================
-- Hellas Verona
-- OLD = 12133
-- NEW = 549
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 549
WHERE team_id = 12133;

UPDATE public.player_season_statistics
SET team_id = 549
WHERE team_id = 12133;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12133
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 549
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12133,
    549,
    'Audit 520: Hellas Verona',
    'audit_520_hellas_verona',
    true,
    true
);

COMMIT;


-- =========================================================
-- Fiorentina
-- OLD = 26994
-- NEW = 537
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 537
WHERE team_id = 26994;

UPDATE public.player_season_statistics
SET team_id = 537
WHERE team_id = 26994;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 26994
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 537
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    26994,
    537,
    'Audit 520: Fiorentina',
    'audit_520_fiorentina',
    true,
    true
);

COMMIT;


-- =========================================================
-- Lazio
-- OLD = 12121
-- NEW = 545
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 545
WHERE team_id = 12121;

UPDATE public.player_season_statistics
SET team_id = 545
WHERE team_id = 12121;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12121
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 545
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12121,
    545,
    'Audit 520: Lazio',
    'audit_520_lazio',
    true,
    true
);

COMMIT;


-- =========================================================
-- Parma
-- OLD = 12137
-- NEW = 546
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 546
WHERE team_id = 12137;

UPDATE public.player_season_statistics
SET team_id = 546
WHERE team_id = 12137;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12137
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 546
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12137,
    546,
    'Audit 520: Parma',
    'audit_520_parma',
    true,
    true
);

COMMIT;


-- =========================================================
-- Cremonese
-- OLD = 26491
-- NEW = 550
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 550
WHERE team_id = 26491;

UPDATE public.player_season_statistics
SET team_id = 550
WHERE team_id = 26491;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 26491
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 550
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    26491,
    550,
    'Audit 520: Cremonese',
    'audit_520_cremonese',
    true,
    true
);

COMMIT;


-- =========================================================
-- Bologna
-- OLD = 26992
-- NEW = 540
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 540
WHERE team_id = 26992;

UPDATE public.player_season_statistics
SET team_id = 540
WHERE team_id = 26992;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 26992
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 540
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    26992,
    540,
    'Audit 520: Bologna',
    'audit_520_bologna',
    true,
    true
);

COMMIT;


-- =========================================================
-- Torino
-- OLD = 12132
-- NEW = 553
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 553
WHERE team_id = 12132;

UPDATE public.player_season_statistics
SET team_id = 553
WHERE team_id = 12132;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12132
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 553
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12132,
    553,
    'Audit 520: Torino',
    'audit_520_torino',
    true,
    true
);

COMMIT;


-- =========================================================
-- AS Roma
-- OLD = 12128
-- NEW = 538
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 538
WHERE team_id = 12128;

UPDATE public.player_season_statistics
SET team_id = 538
WHERE team_id = 12128;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12128
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 538
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12128,
    538,
    'Audit 520: AS Roma',
    'audit_520_as_roma',
    true,
    true
);

COMMIT;


-- =========================================================
-- Lecce
-- OLD = 12138
-- NEW = 554
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 554
WHERE team_id = 12138;

UPDATE public.player_season_statistics
SET team_id = 554
WHERE team_id = 12138;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12138
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 554
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12138,
    554,
    'Audit 520: Lecce',
    'audit_520_lecce',
    true,
    true
);

COMMIT;


-- =========================================================
-- Juventus
-- OLD = 12127
-- NEW = 85
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 85
WHERE team_id = 12127;

UPDATE public.player_season_statistics
SET team_id = 85
WHERE team_id = 12127;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12127
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 85
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12127,
    85,
    'Audit 520: Juventus',
    'audit_520_juventus',
    true,
    true
);

COMMIT;


-- =========================================================
-- Genoa
-- OLD = 12126
-- NEW = 542
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 542
WHERE team_id = 12126;

UPDATE public.player_season_statistics
SET team_id = 542
WHERE team_id = 12126;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12126
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 542
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12126,
    542,
    'Audit 520: Genoa',
    'audit_520_genoa',
    true,
    true
);

COMMIT;


-- =========================================================
-- Napoli
-- OLD = 12124
-- NEW = 86
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 86
WHERE team_id = 12124;

UPDATE public.player_season_statistics
SET team_id = 86
WHERE team_id = 12124;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12124
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 86
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12124,
    86,
    'Audit 520: Napoli',
    'audit_520_napoli',
    true,
    true
);

COMMIT;


-- =========================================================
-- AC Milan
-- OLD = 27887
-- NEW = 536
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 536
WHERE team_id = 27887;

UPDATE public.player_season_statistics
SET team_id = 536
WHERE team_id = 27887;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27887
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 536
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    27887,
    536,
    'Audit 520: AC Milan',
    'audit_520_ac_milan',
    true,
    true
);

COMMIT;