-- =========================================================
-- Auxerre
-- OLD = 12116
-- NEW = 503
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 503
WHERE team_id = 12116;

UPDATE public.player_season_statistics
SET team_id = 503
WHERE team_id = 12116;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12116
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 503
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12116,
    503,
    'Audit 519: Auxerre',
    'audit_519_auxerre',
    true,
    true
);

COMMIT;