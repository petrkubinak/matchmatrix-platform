-- 497_w_merge_sevilla_safe.sql
-- Cíl:
-- sloučit duplicitní Sevilla
-- OLD = 27747
-- NEW = 626

BEGIN;

UPDATE public.league_standings
SET team_id = 626
WHERE team_id = 27747;

UPDATE public.player_season_statistics
SET team_id = 626
WHERE team_id = 27747;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27747
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 626
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    27747,
    626,
    'Audit 497: La Liga duplicate cleanup - Sevilla',
    'audit_497_merge_sevilla',
    true,
    true
);

COMMIT;