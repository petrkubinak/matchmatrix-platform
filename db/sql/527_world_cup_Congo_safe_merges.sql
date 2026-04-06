-- =========================================================
-- DR Congo
-- OLD = 73435
-- NEW = 80803
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 80803
WHERE team_id = 73435;

UPDATE public.player_season_statistics
SET team_id = 80803
WHERE team_id = 73435;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 73435
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 80803
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    73435,
    80803,
    'Audit 527: DR Congo',
    'audit_527_dr_congo',
    true,
    true
);

COMMIT;