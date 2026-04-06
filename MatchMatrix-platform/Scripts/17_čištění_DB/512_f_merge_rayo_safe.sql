-- 512_f_merge_rayo_safe.sql
-- Cíl:
-- sloučit duplicitní Rayo Vallecano
-- OLD = 12100
-- NEW = 615

BEGIN;

UPDATE public.league_standings
SET team_id = 615
WHERE team_id = 12100;

UPDATE public.player_season_statistics
SET team_id = 615
WHERE team_id = 12100;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12100
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 615
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12100,
    615,
    'Audit 512: duplicate cleanup - Rayo Vallecano',
    'audit_512_merge_rayo',
    true,
    true
);

COMMIT;