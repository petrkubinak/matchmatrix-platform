-- 513_a_merge_groningen_safe.sql
-- Cíl:
-- sloučit duplicitní Groningen
-- OLD = 12167
-- NEW = 563

BEGIN;

UPDATE public.league_standings
SET team_id = 563
WHERE team_id = 12167;

UPDATE public.player_season_statistics
SET team_id = 563
WHERE team_id = 12167;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12167
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 563
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12167,
    563,
    'Audit 513: duplicate cleanup - Groningen',
    'audit_513_merge_groningen',
    true,
    true
);

COMMIT;