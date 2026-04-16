-- 512_b_merge_atletico_safe.sql
-- Cíl:
-- sloučit duplicitní Atlético Madrid
-- OLD = 12083
-- NEW = 79

BEGIN;

UPDATE public.league_standings
SET team_id = 79
WHERE team_id = 12083;

UPDATE public.player_season_statistics
SET team_id = 79
WHERE team_id = 12083;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12083
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 79
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12083,
    79,
    'Audit 512: duplicate cleanup - Atletico Madrid',
    'audit_512_merge_atletico',
    true,
    true
);

COMMIT;