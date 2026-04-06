-- 497_e_merge_burnley_safe.sql
-- Cíl:
-- sloučit duplicitní Burnley
-- OLD = 12186
-- NEW = 60

BEGIN;

UPDATE public.league_standings
SET team_id = 60
WHERE team_id = 12186;

UPDATE public.player_season_statistics
SET team_id = 60
WHERE team_id = 12186;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12186
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 60
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12186,
    60,
    'Audit 497: Premier League duplicate cleanup - Burnley',
    'audit_497_merge_burnley',
    true,
    true
);

COMMIT;