-- 512_h_merge_real_madrid_safe.sql
-- Cíl:
-- sloučit duplicitní Real Madrid
-- OLD = 12092
-- NEW = 81

BEGIN;

UPDATE public.league_standings
SET team_id = 81
WHERE team_id = 12092;

UPDATE public.player_season_statistics
SET team_id = 81
WHERE team_id = 12092;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12092
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 81
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12092,
    81,
    'Audit 512: duplicate cleanup - Real Madrid',
    'audit_512_merge_real_madrid',
    true,
    true
);

COMMIT;