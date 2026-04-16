-- 512_u_merge_espanyol_safe.sql
-- Cíl:
-- sloučit duplicitní Espanyol
-- OLD = 25884
-- NEW = 611

BEGIN;

UPDATE public.league_standings
SET team_id = 611
WHERE team_id = 25884;

UPDATE public.player_season_statistics
SET team_id = 611
WHERE team_id = 25884;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 25884
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 611
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    25884,
    611,
    'Audit 512: duplicate cleanup - Espanyol',
    'audit_512_merge_espanyol',
    true,
    true
);

COMMIT;