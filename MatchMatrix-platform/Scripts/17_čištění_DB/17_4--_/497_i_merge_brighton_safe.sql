-- 497_i_merge_brighton_safe.sql
-- Cíl:
-- sloučit duplicitní Brighton
-- OLD = 950
-- NEW = 11917

BEGIN;

UPDATE public.league_standings
SET team_id = 11917
WHERE team_id = 950;

UPDATE public.player_season_statistics
SET team_id = 11917
WHERE team_id = 950;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 950
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 11917
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    950,
    11917,
    'Audit 497: Premier League duplicate cleanup - Brighton',
    'audit_497_merge_brighton',
    true,
    true
);

COMMIT;