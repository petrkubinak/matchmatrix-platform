-- 497_m_merge_cagliari_safe.sql
-- Cíl:
-- sloučit duplicitní Cagliari
-- OLD = 12123
-- NEW = 1073

BEGIN;

UPDATE public.league_standings
SET team_id = 1073
WHERE team_id = 12123;

UPDATE public.player_season_statistics
SET team_id = 1073
WHERE team_id = 12123;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12123
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 1073
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12123,
    1073,
    'Audit 497: Serie A duplicate cleanup - Cagliari',
    'audit_497_merge_cagliari',
    true,
    true
);

COMMIT;