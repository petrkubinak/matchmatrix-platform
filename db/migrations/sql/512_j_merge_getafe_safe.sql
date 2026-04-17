-- 512_j_merge_getafe_safe.sql
-- Cíl:
-- sloučit duplicitní Getafe
-- OLD = 27486
-- NEW = 613

BEGIN;

UPDATE public.league_standings
SET team_id = 613
WHERE team_id = 27486;

UPDATE public.player_season_statistics
SET team_id = 613
WHERE team_id = 27486;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27486
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 613
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    27486,
    613,
    'Audit 512: duplicate cleanup - Getafe',
    'audit_512_merge_getafe',
    true,
    true
);

COMMIT;