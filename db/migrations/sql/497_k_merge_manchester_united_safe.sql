-- 497_k_merge_manchester_united_safe.sql
-- Cíl:
-- sloučit duplicitní Manchester United
-- OLD = 11903
-- NEW = 55

BEGIN;

UPDATE public.league_standings
SET team_id = 55
WHERE team_id = 11903;

UPDATE public.player_season_statistics
SET team_id = 55
WHERE team_id = 11903;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 11903
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 55
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    11903,
    55,
    'Audit 497: Premier League duplicate cleanup - Manchester United',
    'audit_497_merge_manchester_united',
    true,
    true
);

COMMIT;