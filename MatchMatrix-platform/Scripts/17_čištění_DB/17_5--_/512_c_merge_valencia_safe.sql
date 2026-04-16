-- 512_c_merge_valencia_safe.sql
-- Cíl:
-- sloučit duplicitní Valencia
-- OLD = 12085
-- NEW = 621

BEGIN;

UPDATE public.league_standings
SET team_id = 621
WHERE team_id = 12085;

UPDATE public.player_season_statistics
SET team_id = 621
WHERE team_id = 12085;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12085
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 621
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12085,
    621,
    'Audit 512: duplicate cleanup - Valencia',
    'audit_512_merge_valencia',
    true,
    true
);

COMMIT;