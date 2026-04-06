-- 512_p_merge_casa_pia_safe.sql
-- Cíl:
-- sloučit duplicitní Casa Pia
-- OLD = 12157
-- NEW = 588

BEGIN;

UPDATE public.league_standings
SET team_id = 588
WHERE team_id = 12157;

UPDATE public.player_season_statistics
SET team_id = 588
WHERE team_id = 12157;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12157
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 588
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12157,
    588,
    'Audit 512: duplicate cleanup - Casa Pia',
    'audit_512_merge_casa_pia',
    true,
    true
);

COMMIT;