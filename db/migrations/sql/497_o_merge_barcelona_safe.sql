-- 497_o_merge_barcelona_safe.sql
-- Cíl:
-- sloučit duplicitní Barcelona
-- OLD = 12082
-- NEW = 80

BEGIN;

UPDATE public.league_standings
SET team_id = 80
WHERE team_id = 12082;

UPDATE public.player_season_statistics
SET team_id = 80
WHERE team_id = 12082;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12082
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 80
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12082,
    80,
    'Audit 497: duplicate cleanup - Barcelona',
    'audit_497_merge_barcelona',
    true,
    true
);

COMMIT;