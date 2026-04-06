-- 512_t_merge_real_betis_safe.sql
-- Cíl:
-- sloučit duplicitní Real Betis
-- OLD = 12094
-- NEW = 618

BEGIN;

UPDATE public.league_standings
SET team_id = 618
WHERE team_id = 12094;

UPDATE public.player_season_statistics
SET team_id = 618
WHERE team_id = 12094;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12094
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 618
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12094,
    618,
    'Audit 512: duplicate cleanup - Real Betis',
    'audit_512_merge_real_betis',
    true,
    true
);

COMMIT;