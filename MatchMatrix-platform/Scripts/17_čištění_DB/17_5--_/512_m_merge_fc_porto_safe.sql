-- 512_m_merge_fc_porto_safe.sql
-- Cíl:
-- sloučit duplicitní FC Porto
-- OLD = 27770
-- NEW = 576

BEGIN;

UPDATE public.league_standings
SET team_id = 576
WHERE team_id = 27770;

UPDATE public.player_season_statistics
SET team_id = 576
WHERE team_id = 27770;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27770
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 576
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    27770,
    576,
    'Audit 512: duplicate cleanup - FC Porto',
    'audit_512_merge_fc_porto',
    true,
    true
);

COMMIT;