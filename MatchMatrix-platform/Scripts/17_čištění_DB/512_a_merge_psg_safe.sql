-- 512_a_merge_psg_safe.sql
-- Cíl:
-- sloučit duplicitní Paris Saint Germain
-- OLD = 12109
-- NEW = 89

BEGIN;

UPDATE public.league_standings
SET team_id = 89
WHERE team_id = 12109;

UPDATE public.player_season_statistics
SET team_id = 89
WHERE team_id = 12109;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12109
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 89
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12109,
    89,
    'Audit 512: duplicate cleanup - Paris Saint Germain',
    'audit_512_merge_psg',
    true,
    true
);

COMMIT;