-- 512_n_merge_famalicao_safe.sql
-- Cíl:
-- sloučit duplicitní Famalicão
-- OLD = 12154
-- NEW = 584

BEGIN;

UPDATE public.league_standings
SET team_id = 584
WHERE team_id = 12154;

UPDATE public.player_season_statistics
SET team_id = 584
WHERE team_id = 12154;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12154
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 584
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12154,
    584,
    'Audit 512: duplicate cleanup - Famalicao',
    'audit_512_merge_famalicao',
    true,
    true
);

COMMIT;