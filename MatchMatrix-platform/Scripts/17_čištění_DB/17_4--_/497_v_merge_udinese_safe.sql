-- 497_v_merge_udinese_safe.sql
-- Cíl:
-- sloučit duplicitní Udinese
-- OLD = 12125
-- NEW = 548

BEGIN;

UPDATE public.league_standings
SET team_id = 548
WHERE team_id = 12125;

UPDATE public.player_season_statistics
SET team_id = 548
WHERE team_id = 12125;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12125
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 548
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12125,
    548,
    'Audit 497: Serie A duplicate cleanup - Udinese',
    'audit_497_merge_udinese',
    true,
    true
);

COMMIT;