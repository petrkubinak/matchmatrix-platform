-- 497_q_merge_utrecht_safe.sql
-- Cíl:
-- sloučit duplicitní Utrecht
-- OLD = 12171
-- NEW = 562

BEGIN;

UPDATE public.league_standings
SET team_id = 562
WHERE team_id = 12171;

UPDATE public.player_season_statistics
SET team_id = 562
WHERE team_id = 12171;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12171
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 562
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12171,
    562,
    'Audit 497: Eredivisie duplicate cleanup - Utrecht',
    'audit_497_merge_utrecht',
    true,
    true
);

COMMIT;