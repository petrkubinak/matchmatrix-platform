-- 497_d_merge_rennes_safe.sql
-- Cíl:
-- sloučit duplicitní Rennes
-- OLD = 12112
-- NEW = 1010

BEGIN;

-- 0) přepiš FK reference v league_standings
UPDATE public.league_standings
SET team_id = 1010
WHERE team_id = 12112;

-- 0b) přepiš FK reference v player_season_statistics
UPDATE public.player_season_statistics
SET team_id = 1010
WHERE team_id = 12112;

-- 1) smaž konfliktní aliasy ze starého týmu,
-- které už na novém týmu existují
DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12112
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 1010
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

-- 2) proveď merge
SELECT public.merge_team(
    12112,
    1010,
    'Audit 497: Ligue 1 duplicate cleanup - Rennes',
    'audit_497_merge_rennes',
    true,
    true
);

COMMIT;