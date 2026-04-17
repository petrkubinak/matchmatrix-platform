-- 496_w_merge_lyon_safe.sql
-- Cíl:
-- sloučit duplicitní Lyon
-- OLD = 12104
-- NEW = 506

BEGIN;

-- 0) přepiš FK reference v league_standings
UPDATE public.league_standings
SET team_id = 506
WHERE team_id = 12104;

-- 1) smaž konfliktní aliasy ze starého týmu,
-- které už na novém týmu existují
DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12104
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 506
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

-- 2) proveď merge
SELECT public.merge_team(
    12104,
    506,
    'Audit 496: Ligue 1 duplicate cleanup - Lyon',
    'audit_496_merge_lyon',
    true,
    true
);

COMMIT;