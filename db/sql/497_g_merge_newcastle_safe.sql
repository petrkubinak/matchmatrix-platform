-- 497_g_merge_newcastle_safe.sql
-- Cíl:
-- sloučit duplicitní Newcastle
-- OLD = 949
-- NEW = 11904

BEGIN;

UPDATE public.league_standings
SET team_id = 11904
WHERE team_id = 949;

UPDATE public.player_season_statistics
SET team_id = 11904
WHERE team_id = 949;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 949
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 11904
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    949,
    11904,
    'Audit 497: Premier League duplicate cleanup - Newcastle',
    'audit_497_merge_newcastle',
    true,
    true
);

COMMIT;