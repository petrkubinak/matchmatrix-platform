-- 497_a_merge_auxerre_safe.sql
-- Cíl:
-- sloučit duplicitní Auxerre
-- OLD = 1019
-- NEW = 12116

BEGIN;

-- 0) přepiš FK reference v league_standings
UPDATE public.league_standings
SET team_id = 12116
WHERE team_id = 1019;

-- 0b) přepiš FK reference v player_season_statistics
UPDATE public.player_season_statistics
SET team_id = 12116
WHERE team_id = 1019;

-- 1) smaž konfliktní aliasy ze starého týmu,
-- které už na novém týmu existují
DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 1019
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 12116
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

-- 2) proveď merge
SELECT public.merge_team(
    1019,
    12116,
    'Audit 496/497: Ligue 1 duplicate cleanup - Auxerre',
    'audit_497_merge_auxerre',
    true,
    true
);

COMMIT;