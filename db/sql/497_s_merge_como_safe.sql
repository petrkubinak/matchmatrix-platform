-- 497_s_merge_como_safe.sql
-- Cíl:
-- sloučit duplicitní Como
-- OLD = 12139
-- NEW = 1075

BEGIN;

UPDATE public.league_standings
SET team_id = 1075
WHERE team_id = 12139;

UPDATE public.player_season_statistics
SET team_id = 1075
WHERE team_id = 12139;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12139
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 1075
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12139,
    1075,
    'Audit 497: Serie A duplicate cleanup - Como',
    'audit_497_merge_como',
    true,
    true
);

COMMIT;