-- =========================================================
-- Southampton
-- OLD = 26597
-- NEW = 34
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 34
WHERE team_id = 26597;

UPDATE public.player_season_statistics
SET team_id = 34
WHERE team_id = 26597;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 26597
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 34
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    26597,
    34,
    'Audit 524: Southampton',
    'audit_524_southampton',
    true,
    true
);

COMMIT;