-- 512_e_merge_alaves_safe.sql
-- Cíl:
-- sloučit duplicitní Alavés
-- OLD = 12093
-- NEW = 622

BEGIN;

UPDATE public.league_standings
SET team_id = 622
WHERE team_id = 12093;

UPDATE public.player_season_statistics
SET team_id = 622
WHERE team_id = 12093;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12093
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 622
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12093,
    622,
    'Audit 512: duplicate cleanup - Alaves',
    'audit_512_merge_alaves',
    true,
    true
);

COMMIT;