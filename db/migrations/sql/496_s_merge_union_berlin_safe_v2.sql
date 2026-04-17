-- 496_s_merge_union_berlin_safe_v2.sql
-- Cíl:
-- bezpečný merge Union Berlin:
-- OLD = 27654
-- NEW = 533
-- navíc přepis league_standings před merge

BEGIN;

-- 0) přepiš FK reference v league_standings
UPDATE public.league_standings
SET team_id = 533
WHERE team_id = 27654;

-- 1) smaž konfliktní aliasy ze starého týmu,
-- které už na novém týmu existují
DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27654
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 533
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

-- 2) proveď merge
SELECT public.merge_team(
    27654,
    533,
    'Audit 496: Bundesliga duplicate cleanup (safe merge v2)',
    'audit_496_merge_union_berlin',
    true,
    true
);

COMMIT;