-- 497_j_merge_leeds_safe.sql
-- Cíl:
-- sloučit duplicitní Leeds
-- OLD = 12192
-- NEW = 956

BEGIN;

UPDATE public.league_standings
SET team_id = 956
WHERE team_id = 12192;

UPDATE public.player_season_statistics
SET team_id = 956
WHERE team_id = 12192;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12192
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 956
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12192,
    956,
    'Audit 497: Premier League duplicate cleanup - Leeds',
    'audit_497_merge_leeds',
    true,
    true
);

COMMIT;