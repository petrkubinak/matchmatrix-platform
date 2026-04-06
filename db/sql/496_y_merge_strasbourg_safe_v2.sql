-- 496_y_merge_strasbourg_safe_v2.sql
-- Cíl:
-- bezpečný merge Strasbourg
-- OLD = 12113
-- NEW = 1022
-- navíc ošetření player_season_statistics

BEGIN;

-- 0) přepiš FK reference v league_standings
UPDATE public.league_standings
SET team_id = 1022
WHERE team_id = 12113;

-- 0b) přepiš FK reference v player_season_statistics
UPDATE public.player_season_statistics
SET team_id = 1022
WHERE team_id = 12113;

-- 1) smaž konfliktní aliasy ze starého týmu,
-- které už na novém týmu existují
DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12113
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 1022
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

-- 2) proveď merge
SELECT public.merge_team(
    12113,
    1022,
    'Audit 496: Ligue 1 duplicate cleanup - Strasbourg v2',
    'audit_496_merge_strasbourg',
    true,
    true
);

COMMIT;