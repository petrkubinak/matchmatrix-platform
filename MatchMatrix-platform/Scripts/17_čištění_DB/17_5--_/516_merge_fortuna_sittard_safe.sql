-- 516_merge_fortuna_sittard_safe.sql
-- Cíl:
-- sloučit duplicitní Fortuna Sittard
-- OLD = 12169
-- NEW = 572

BEGIN;

UPDATE public.player_season_statistics
SET team_id = 572
WHERE team_id = 12169;

UPDATE public.league_standings
SET team_id = 572
WHERE team_id = 12169;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12169
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 572
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12169,
    572,
    'Audit 516: duplicate cleanup - Fortuna Sittard',
    'audit_516_merge_fortuna',
    true,
    true
);

COMMIT;