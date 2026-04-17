-- 496_x_merge_nice_safe.sql
-- Cíl:
-- sloučit duplicitní Nice
-- OLD = 12108
-- NEW = 505

BEGIN;

-- 0) přepiš FK reference v league_standings
UPDATE public.league_standings
SET team_id = 505
WHERE team_id = 12108;

-- 1) smaž konfliktní aliasy ze starého týmu,
-- které už na novém týmu existují
DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12108
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 505
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

-- 2) proveď merge
SELECT public.merge_team(
    12108,
    505,
    'Audit 496: Ligue 1 duplicate cleanup - Nice',
    'audit_496_merge_nice',
    true,
    true
);

COMMIT;