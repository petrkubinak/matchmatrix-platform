
-- 496_u_merge_fc_st_pauli_safe.sql
-- Cíl:
-- sloučit duplicitní FC St. Pauli
-- OLD = 27217
-- NEW = 12079

BEGIN;

-- 0) přepiš FK reference v league_standings, pokud existují
UPDATE public.league_standings
SET team_id = 12079
WHERE team_id = 27217;

-- 1) smaž konfliktní aliasy ze starého týmu,
-- které už na novém týmu existují
DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27217
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 12079
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

-- 2) proveď merge
SELECT public.merge_team(
    27217,
    12079,
    'Audit 496: Bundesliga duplicate cleanup - FC St. Pauli',
    'audit_496_merge_fc_st_pauli',
    true,
    true
);

COMMIT;