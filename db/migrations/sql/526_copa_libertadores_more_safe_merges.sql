-- 526_copa_libertadores_more_safe_merges.sql
-- Spouštěj BLOK PO BLOKU

-- =========================================================
-- Club Nacional
-- OLD = 27916
-- NEW = 35243
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 35243
WHERE team_id = 27916;

UPDATE public.player_season_statistics
SET team_id = 35243
WHERE team_id = 27916;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27916
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 35243
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    27916,
    35243,
    'Audit 526: Club Nacional',
    'audit_526_club_nacional',
    true,
    true
);

COMMIT;


-- =========================================================
-- Deportes Tolima
-- OLD = 73434
-- NEW = 11001
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 11001
WHERE team_id = 73434;

UPDATE public.player_season_statistics
SET team_id = 11001
WHERE team_id = 73434;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 73434
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 11001
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    73434,
    11001,
    'Audit 526: Deportes Tolima',
    'audit_526_deportes_tolima',
    true,
    true
);

COMMIT;


-- =========================================================
-- Universidad Catolica
-- OLD = 27969
-- NEW = 10979
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 10979
WHERE team_id = 27969;

UPDATE public.player_season_statistics
SET team_id = 10979
WHERE team_id = 27969;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27969
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 10979
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    27969,
    10979,
    'Audit 526: Universidad Catolica',
    'audit_526_universidad_catolica',
    true,
    true
);

COMMIT;


-- =========================================================
-- Universitario
-- OLD = 27940
-- NEW = 35241
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 35241
WHERE team_id = 27940;

UPDATE public.player_season_statistics
SET team_id = 35241
WHERE team_id = 27940;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27940
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 35241
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    27940,
    35241,
    'Audit 526: Universitario',
    'audit_526_universitario',
    true,
    true
);

COMMIT;