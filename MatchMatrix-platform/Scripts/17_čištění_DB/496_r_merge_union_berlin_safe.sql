-- 496_r_merge_union_berlin_safe.sql
-- Cíl:
-- bezpečný merge Union Berlin:
-- OLD = 27654
-- NEW = 533
-- Nejprve odstraníme konfliktní aliasy ze starého týmu,
-- které už na novém týmu existují.

BEGIN;

-- 1) smaž konfliktní aliasy ze starého týmu
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
    27654,                         -- old team_id
    533,                           -- new team_id
    'Audit 496: Bundesliga duplicate cleanup (safe merge)',
    'audit_496_merge_union_berlin',
    true,                          -- delete old
    true                           -- create alias
);

COMMIT;