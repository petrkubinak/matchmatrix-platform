-- 497_p_merge_nacional_safe.sql
-- Cíl:
-- sloučit duplicitní Nacional
-- OLD = 12147
-- NEW = 582

BEGIN;

UPDATE public.league_standings
SET team_id = 582
WHERE team_id = 12147;

UPDATE public.player_season_statistics
SET team_id = 582
WHERE team_id = 12147;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12147
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 582
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12147,
    582,
    'Audit 497: Primeira Liga duplicate cleanup - Nacional',
    'audit_497_merge_nacional',
    true,
    true
);

COMMIT;