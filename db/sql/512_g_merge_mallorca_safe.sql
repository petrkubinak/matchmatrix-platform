-- 512_g_merge_mallorca_safe.sql
-- Cíl:
-- sloučit duplicitní Mallorca
-- OLD = 12101
-- NEW = 617

BEGIN;

UPDATE public.league_standings
SET team_id = 617
WHERE team_id = 12101;

UPDATE public.player_season_statistics
SET team_id = 617
WHERE team_id = 12101;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12101
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 617
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12101,
    617,
    'Audit 512: duplicate cleanup - Mallorca',
    'audit_512_merge_mallorca',
    true,
    true
);

COMMIT;