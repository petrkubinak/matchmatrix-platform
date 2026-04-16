-- 512_v_merge_girona_safe.sql
-- Cíl:
-- sloučit duplicitní Girona
-- OLD = 12096
-- NEW = 624

BEGIN;

UPDATE public.league_standings
SET team_id = 624
WHERE team_id = 12096;

UPDATE public.player_season_statistics
SET team_id = 624
WHERE team_id = 12096;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12096
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 624
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12096,
    624,
    'Audit 512: duplicate cleanup - Girona',
    'audit_512_merge_girona',
    true,
    true
);

COMMIT;