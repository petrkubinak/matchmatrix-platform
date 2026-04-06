-- 512_l_merge_santa_clara_safe.sql
-- Cíl:
-- sloučit duplicitní Santa Clara
-- OLD = 27929
-- NEW = 583

BEGIN;

UPDATE public.league_standings
SET team_id = 583
WHERE team_id = 27929;

UPDATE public.player_season_statistics
SET team_id = 583
WHERE team_id = 27929;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27929
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 583
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    27929,
    583,
    'Audit 512: duplicate cleanup - Santa Clara',
    'audit_512_merge_santa_clara',
    true,
    true
);

COMMIT;