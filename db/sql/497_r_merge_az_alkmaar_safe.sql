-- 497_r_merge_az_alkmaar_safe.sql
-- Cíl:
-- sloučit duplicitní AZ Alkmaar
-- OLD = 12166
-- NEW = 1106

BEGIN;

UPDATE public.league_standings
SET team_id = 1106
WHERE team_id = 12166;

UPDATE public.player_season_statistics
SET team_id = 1106
WHERE team_id = 12166;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12166
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 1106
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12166,
    1106,
    'Audit 497: Eredivisie duplicate cleanup - AZ Alkmaar',
    'audit_497_merge_az_alkmaar',
    true,
    true
);

COMMIT;