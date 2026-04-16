-- 511_merge_arsenal_safe.sql
-- Cíl:
-- sloučit duplicitní Arsenal
-- OLD = 13102
-- NEW = 11910

BEGIN;

UPDATE public.league_standings
SET team_id = 11910
WHERE team_id = 13102;

UPDATE public.player_season_statistics
SET team_id = 11910
WHERE team_id = 13102;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 13102
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 11910
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    13102,
    11910,
    'Audit 511: duplicate cleanup - Arsenal',
    'audit_511_merge_arsenal',
    true,
    true
);

COMMIT;