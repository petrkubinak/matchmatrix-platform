-- 512_w_merge_sc_telstar_safe.sql
-- Cíl:
-- sloučit duplicitní SC Telstar
-- OLD = 12183
-- NEW = 569

BEGIN;

UPDATE public.league_standings
SET team_id = 569
WHERE team_id = 12183;

UPDATE public.player_season_statistics
SET team_id = 569
WHERE team_id = 12183;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12183
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 569
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12183,
    569,
    'Audit 512: duplicate cleanup - SC Telstar',
    'audit_512_merge_sc_telstar',
    true,
    true
);

COMMIT;