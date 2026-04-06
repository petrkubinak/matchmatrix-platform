-- 512_q_merge_arouca_safe.sql
-- Cíl:
-- sloučit duplicitní Arouca
-- OLD = 12153
-- NEW = 579

BEGIN;

UPDATE public.league_standings
SET team_id = 579
WHERE team_id = 12153;

UPDATE public.player_season_statistics
SET team_id = 579
WHERE team_id = 12153;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12153
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 579
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12153,
    579,
    'Audit 512: duplicate cleanup - Arouca',
    'audit_512_merge_arouca',
    true,
    true
);

COMMIT;