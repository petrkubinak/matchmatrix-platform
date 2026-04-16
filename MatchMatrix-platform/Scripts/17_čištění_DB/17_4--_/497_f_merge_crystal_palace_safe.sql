-- 497_f_merge_crystal_palace_safe.sql
-- Cíl:
-- sloučit duplicitní Crystal Palace
-- OLD = 11918
-- NEW = 63

BEGIN;

UPDATE public.league_standings
SET team_id = 63
WHERE team_id = 11918;

UPDATE public.player_season_statistics
SET team_id = 63
WHERE team_id = 11918;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 11918
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 63
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    11918,
    63,
    'Audit 497: Premier League duplicate cleanup - Crystal Palace',
    'audit_497_merge_crystal_palace',
    true,
    true
);

COMMIT;