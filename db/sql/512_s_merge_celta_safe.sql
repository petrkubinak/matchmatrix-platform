-- 512_s_merge_celta_safe.sql
-- Cíl:
-- sloučit duplicitní Celta Vigo
-- OLD = 12090
-- NEW = 625

BEGIN;

UPDATE public.league_standings
SET team_id = 625
WHERE team_id = 12090;

UPDATE public.player_season_statistics
SET team_id = 625
WHERE team_id = 12090;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12090
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 625
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12090,
    625,
    'Audit 512: duplicate cleanup - Celta Vigo',
    'audit_512_merge_celta',
    true,
    true
);

COMMIT;