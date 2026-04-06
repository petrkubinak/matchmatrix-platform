-- 512_d_merge_real_sociedad_safe.sql
-- Cíl:
-- sloučit duplicitní Real Sociedad
-- OLD = 12097
-- NEW = 619

BEGIN;

UPDATE public.league_standings
SET team_id = 619
WHERE team_id = 12097;

UPDATE public.player_season_statistics
SET team_id = 619
WHERE team_id = 12097;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12097
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 619
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12097,
    619,
    'Audit 512: duplicate cleanup - Real Sociedad',
    'audit_512_merge_real_sociedad',
    true,
    true
);

COMMIT;