-- 512_k_merge_gil_vicente_safe.sql
-- Cíl:
-- sloučit duplicitní Gil Vicente
-- OLD = 12155
-- NEW = 585

BEGIN;

UPDATE public.league_standings
SET team_id = 585
WHERE team_id = 12155;

UPDATE public.player_season_statistics
SET team_id = 585
WHERE team_id = 12155;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12155
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 585
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12155,
    585,
    'Audit 512: duplicate cleanup - Gil Vicente',
    'audit_512_merge_gil_vicente',
    true,
    true
);

COMMIT;