-- 524_efl_champ_safe_merges.sql
-- Spouštěj BLOK PO BLOKU

-- =========================================================
-- Middlesbrough
-- OLD = 27653
-- NEW = 36
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 36
WHERE team_id = 27653;

UPDATE public.player_season_statistics
SET team_id = 36
WHERE team_id = 27653;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27653
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 36
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    27653,
    36,
    'Audit 524: Middlesbrough',
    'audit_524_middlesbrough',
    true,
    true
);

COMMIT;


-- =========================================================
-- Millwall
-- OLD = 12188
-- NEW = 42
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 42
WHERE team_id = 12188;

UPDATE public.player_season_statistics
SET team_id = 42
WHERE team_id = 12188;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12188
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 42
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12188,
    42,
    'Audit 524: Millwall',
    'audit_524_millwall',
    true,
    true
);

COMMIT;


-- =========================================================
-- Sheffield Wednesday
-- OLD = 12199
-- NEW = 37
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 37
WHERE team_id = 12199;

UPDATE public.player_season_statistics
SET team_id = 37
WHERE team_id = 12199;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12199
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 37
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12199,
    37,
    'Audit 524: Sheffield Wednesday',
    'audit_524_sheffield_wednesday',
    true,
    true
);

COMMIT;


-- =========================================================
-- Watford
-- OLD = 12184
-- NEW = 38
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 38
WHERE team_id = 12184;

UPDATE public.player_season_statistics
SET team_id = 38
WHERE team_id = 12184;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12184
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 38
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12184,
    38,
    'Audit 524: Watford',
    'audit_524_watford',
    true,
    true
);

COMMIT;


-- =========================================================
-- Stoke City
-- OLD = 12200
-- NEW = 27
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 27
WHERE team_id = 12200;

UPDATE public.player_season_statistics
SET team_id = 27
WHERE team_id = 12200;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12200
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 27
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12200,
    27,
    'Audit 524: Stoke City',
    'audit_524_stoke_city',
    true,
    true
);

COMMIT;


-- =========================================================
-- Oxford United
-- OLD = 12203
-- NEW = 47
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 47
WHERE team_id = 12203;

UPDATE public.player_season_statistics
SET team_id = 47
WHERE team_id = 12203;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12203
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 47
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12203,
    47,
    'Audit 524: Oxford United',
    'audit_524_oxford_united',
    true,
    true
);

COMMIT;


-- =========================================================
-- Hull City
-- OLD = 12193
-- NEW = 30
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 30
WHERE team_id = 12193;

UPDATE public.player_season_statistics
SET team_id = 30
WHERE team_id = 12193;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12193
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 30
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12193,
    30,
    'Audit 524: Hull City',
    'audit_524_hull_city',
    true,
    true
);

COMMIT;


-- =========================================================
-- Portsmouth
-- OLD = 12205
-- NEW = 31
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 31
WHERE team_id = 12205;

UPDATE public.player_season_statistics
SET team_id = 31
WHERE team_id = 12205;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12205
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 31
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12205,
    31,
    'Audit 524: Portsmouth',
    'audit_524_portsmouth',
    true,
    true
);

COMMIT;


-- =========================================================
-- Bristol City
-- OLD = 12187
-- NEW = 43
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 43
WHERE team_id = 12187;

UPDATE public.player_season_statistics
SET team_id = 43
WHERE team_id = 12187;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12187
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 43
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12187,
    43,
    'Audit 524: Bristol City',
    'audit_524_bristol_city',
    true,
    true
);

COMMIT;