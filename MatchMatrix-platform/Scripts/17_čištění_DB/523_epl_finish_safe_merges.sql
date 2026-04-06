-- 523_epl_finish_safe_merges.sql
-- EPL final cleanup
-- Spouštěj BLOK PO BLOKU

-- =========================================================
-- Brentford
-- OLD = 11919
-- NEW = 65
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 65
WHERE team_id = 11919;

UPDATE public.player_season_statistics
SET team_id = 65
WHERE team_id = 11919;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 11919
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 65
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    11919,
    65,
    'Audit 523: Brentford final cleanup',
    'audit_523_brentford',
    true,
    true
);

COMMIT;


-- =========================================================
-- Everton
-- OLD = 11911
-- NEW = 51
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 51
WHERE team_id = 11911;

UPDATE public.player_season_statistics
SET team_id = 51
WHERE team_id = 11911;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 11911
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 51
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    11911,
    51,
    'Audit 523: Everton final cleanup',
    'audit_523_everton',
    true,
    true
);

COMMIT;


-- =========================================================
-- Liverpool
-- OLD = 3
-- NEW = 53
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 53
WHERE team_id = 3;

UPDATE public.player_season_statistics
SET team_id = 53
WHERE team_id = 3;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 3
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 53
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    3,
    53,
    'Audit 523: Liverpool final cleanup',
    'audit_523_liverpool',
    true,
    true
);

COMMIT;


-- =========================================================
-- Fulham
-- OLD = 11906
-- NEW = 52
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 52
WHERE team_id = 11906;

UPDATE public.player_season_statistics
SET team_id = 52
WHERE team_id = 11906;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 11906
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 52
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    11906,
    52,
    'Audit 523: Fulham final cleanup',
    'audit_523_fulham',
    true,
    true
);

COMMIT;


-- =========================================================
-- Nottingham Forest
-- OLD = 11921
-- NEW = 62
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 62
WHERE team_id = 11921;

UPDATE public.player_season_statistics
SET team_id = 62
WHERE team_id = 11921;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 11921
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 62
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    11921,
    62,
    'Audit 523: Nottingham Forest final cleanup',
    'audit_523_nottingham_forest',
    true,
    true
);

COMMIT;


-- =========================================================
-- Aston Villa
-- OLD = 11922
-- NEW = 49
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 49
WHERE team_id = 11922;

UPDATE public.player_season_statistics
SET team_id = 49
WHERE team_id = 11922;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 11922
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 49
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    11922,
    49,
    'Audit 523: Aston Villa final cleanup',
    'audit_523_aston_villa',
    true,
    true
);

COMMIT;


-- =========================================================
-- Sunderland
-- OLD = 12202
-- NEW = 57
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 57
WHERE team_id = 12202;

UPDATE public.player_season_statistics
SET team_id = 57
WHERE team_id = 12202;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12202
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 57
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12202,
    57,
    'Audit 523: Sunderland final cleanup',
    'audit_523_sunderland',
    true,
    true
);

COMMIT;


-- =========================================================
-- Chelsea
-- OLD = 2
-- NEW = 50
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 50
WHERE team_id = 2;

UPDATE public.player_season_statistics
SET team_id = 50
WHERE team_id = 2;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 2
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 50
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    2,
    50,
    'Audit 523: Chelsea final cleanup',
    'audit_523_chelsea',
    true,
    true
);

COMMIT;


-- =========================================================
-- Manchester City
-- OLD = 11916
-- NEW = 54
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 54
WHERE team_id = 11916;

UPDATE public.player_season_statistics
SET team_id = 54
WHERE team_id = 11916;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 11916
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 54
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    11916,
    54,
    'Audit 523: Manchester City final cleanup',
    'audit_523_manchester_city',
    true,
    true
);

COMMIT;