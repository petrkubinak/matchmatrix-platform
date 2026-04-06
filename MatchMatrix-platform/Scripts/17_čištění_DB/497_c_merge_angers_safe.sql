-- 497_c_merge_angers_safe.sql
-- Cíl:
-- sloučit duplicitní Angers
-- OLD = 12102
-- NEW = 1018

BEGIN;

-- 0) přepiš FK reference v league_standings
UPDATE public.league_standings
SET team_id = 1018
WHERE team_id = 12102;

-- 0b) přepiš FK reference v player_season_statistics
UPDATE public.player_season_statistics
SET team_id = 1018
WHERE team_id = 12102;

-- 1) smaž konfliktní aliasy ze starého týmu,
-- které už na novém týmu existují
DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12102
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 1018
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

-- 2) proveď merge
SELECT public.merge_team(
    12102,
    1018,
    'Audit 497: Ligue 1 duplicate cleanup - Angers',
    'audit_497_merge_angers',
    true,
    true
);

COMMIT;