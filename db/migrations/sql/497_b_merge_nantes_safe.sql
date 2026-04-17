-- 497_b_merge_nantes_safe.sql
-- Cíl:
-- sloučit duplicitní Nantes
-- OLD = 12107
-- NEW = 1023

BEGIN;

-- 0) přepiš FK reference v league_standings
UPDATE public.league_standings
SET team_id = 1023
WHERE team_id = 12107;

-- 0b) přepiš FK reference v player_season_statistics
UPDATE public.player_season_statistics
SET team_id = 1023
WHERE team_id = 12107;

-- 1) smaž konfliktní aliasy ze starého týmu,
-- které už na novém týmu existují
DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12107
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 1023
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

-- 2) proveď merge
SELECT public.merge_team(
    12107,
    1023,
    'Audit 497: Ligue 1 duplicate cleanup - Nantes',
    'audit_497_merge_nantes',
    true,
    true
);

COMMIT;