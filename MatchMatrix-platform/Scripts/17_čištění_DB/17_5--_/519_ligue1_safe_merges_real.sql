-- 519_ligue1_safe_merges_real.sql
-- Spouštěj BLOK PO BLOKU

-- =========================================================
-- Toulouse
-- OLD = 12114
-- NEW = 500
-- =========================================================
BEGIN;

UPDATE public.league_standings SET team_id = 500 WHERE team_id = 12114;
UPDATE public.player_season_statistics SET team_id = 500 WHERE team_id = 12114;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12114
  AND EXISTS (
    SELECT 1 FROM public.team_aliases a_new
    WHERE a_new.team_id = 500
      AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
);

SELECT public.merge_team(12114, 500, 'Audit 519: Toulouse', 'audit_519_toulouse', true, true);

COMMIT;


-- =========================================================
-- Lille
-- OLD = 12103
-- NEW = 504
-- =========================================================
BEGIN;

UPDATE public.league_standings SET team_id = 504 WHERE team_id = 12103;
UPDATE public.player_season_statistics SET team_id = 504 WHERE team_id = 12103;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12103
  AND EXISTS (
    SELECT 1 FROM public.team_aliases a_new
    WHERE a_new.team_id = 504
      AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
);

SELECT public.merge_team(12103, 504, 'Audit 519: Lille', 'audit_519_lille', true, true);

COMMIT;


-- =========================================================
-- Marseille
-- OLD = 12105
-- NEW = 88
-- =========================================================
BEGIN;

UPDATE public.league_standings SET team_id = 88 WHERE team_id = 12105;
UPDATE public.player_season_statistics SET team_id = 88 WHERE team_id = 12105;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12105
  AND EXISTS (
    SELECT 1 FROM public.team_aliases a_new
    WHERE a_new.team_id = 88
      AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
);

SELECT public.merge_team(12105, 88, 'Audit 519: Marseille', 'audit_519_marseille', true, true);

COMMIT;


-- =========================================================
-- Metz
-- OLD = 12118
-- NEW = 1021
-- =========================================================
BEGIN;

UPDATE public.league_standings SET team_id = 1021 WHERE team_id = 12118;
UPDATE public.player_season_statistics SET team_id = 1021 WHERE team_id = 12118;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12118
  AND EXISTS (
    SELECT 1 FROM public.team_aliases a_new
    WHERE a_new.team_id = 1021
      AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
);

SELECT public.merge_team(12118, 1021, 'Audit 519: Metz', 'audit_519_metz', true, true);

COMMIT;


-- =========================================================
-- Le Havre
-- OLD = 27639
-- NEW = 511
-- =========================================================
BEGIN;

UPDATE public.league_standings SET team_id = 511 WHERE team_id = 27639;
UPDATE public.player_season_statistics SET team_id = 511 WHERE team_id = 27639;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27639
  AND EXISTS (
    SELECT 1 FROM public.team_aliases a_new
    WHERE a_new.team_id = 511
      AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
);

SELECT public.merge_team(27639, 511, 'Audit 519: Le Havre', 'audit_519_lehavre', true, true);

COMMIT;


-- =========================================================
-- Lorient
-- OLD = 12712
-- NEW = 1020
-- =========================================================
BEGIN;

UPDATE public.league_standings SET team_id = 1020 WHERE team_id = 12712;
UPDATE public.player_season_statistics SET team_id = 1020 WHERE team_id = 12712;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12712
  AND EXISTS (
    SELECT 1 FROM public.team_aliases a_new
    WHERE a_new.team_id = 1020
      AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
);

SELECT public.merge_team(12712, 1020, 'Audit 519: Lorient', 'audit_519_lorient', true, true);

COMMIT;