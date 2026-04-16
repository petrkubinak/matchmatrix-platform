-- 512_i_merge_villarreal_safe.sql
-- Cíl:
-- sloučit duplicitní Villarreal
-- OLD = 12086
-- NEW = 82

BEGIN;

UPDATE public.league_standings
SET team_id = 82
WHERE team_id = 12086;

UPDATE public.player_season_statistics
SET team_id = 82
WHERE team_id = 12086;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12086
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 82
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12086,
    82,
    'Audit 512: duplicate cleanup - Villarreal',
    'audit_512_merge_villarreal',
    true,
    true
);

COMMIT;