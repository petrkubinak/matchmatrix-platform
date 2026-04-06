-- 497_n_merge_psv_safe.sql
-- Cíl:
-- sloučit duplicitní PSV Eindhoven
-- OLD = 12163
-- NEW = 1101

BEGIN;

UPDATE public.league_standings
SET team_id = 1101
WHERE team_id = 12163;

UPDATE public.player_season_statistics
SET team_id = 1101
WHERE team_id = 12163;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12163
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 1101
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12163,
    1101,
    'Audit 497: Eredivisie duplicate cleanup - PSV Eindhoven',
    'audit_497_merge_psv',
    true,
    true
);

COMMIT;