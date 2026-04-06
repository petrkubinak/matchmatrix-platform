-- 512_o_merge_benfica_safe.sql
-- Cíl:
-- sloučit duplicitní Benfica
-- OLD = 12141
-- NEW = 99

BEGIN;

UPDATE public.league_standings
SET team_id = 99
WHERE team_id = 12141;

UPDATE public.player_season_statistics
SET team_id = 99
WHERE team_id = 12141;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12141
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 99
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12141,
    99,
    'Audit 512: duplicate cleanup - Benfica',
    'audit_512_merge_benfica',
    true,
    true
);

COMMIT;