-- 512_r_merge_estoril_safe.sql
-- Cíl:
-- sloučit duplicitní Estoril
-- OLD = 12151
-- NEW = 577

BEGIN;

UPDATE public.league_standings
SET team_id = 577
WHERE team_id = 12151;

UPDATE public.player_season_statistics
SET team_id = 577
WHERE team_id = 12151;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12151
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 577
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12151,
    577,
    'Audit 512: duplicate cleanup - Estoril',
    'audit_512_merge_estoril',
    true,
    true
);

COMMIT;