-- 497_u_merge_nec_safe.sql
-- Cíl:
-- sloučit duplicitní NEC / NEC Nijmegen
-- OLD = 12176
-- NEW = 570

BEGIN;

UPDATE public.league_standings
SET team_id = 570
WHERE team_id = 12176;

UPDATE public.player_season_statistics
SET team_id = 570
WHERE team_id = 12176;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12176
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 570
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12176,
    570,
    'Audit 497: Eredivisie duplicate cleanup - NEC Nijmegen',
    'audit_497_merge_nec',
    true,
    true
);

COMMIT;