-- 497_h_merge_bournemouth_safe.sql
-- Cíl:
-- sloučit duplicitní Bournemouth
-- OLD = 11905
-- NEW = 67

BEGIN;

UPDATE public.league_standings
SET team_id = 67
WHERE team_id = 11905;

UPDATE public.player_season_statistics
SET team_id = 67
WHERE team_id = 11905;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 11905
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 67
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    11905,
    67,
    'Audit 497: Premier League duplicate cleanup - Bournemouth',
    'audit_497_merge_bournemouth',
    true,
    true
);

COMMIT;