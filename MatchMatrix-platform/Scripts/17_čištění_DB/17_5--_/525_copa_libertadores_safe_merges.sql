-- 525_copa_libertadores_safe_merges.sql
-- Spouštěj BLOK PO BLOKU

-- =========================================================
-- Always Ready
-- OLD = 27920
-- NEW = 35236
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 35236
WHERE team_id = 27920;

UPDATE public.player_season_statistics
SET team_id = 35236
WHERE team_id = 27920;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 27920
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 35236
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    27920,
    35236,
    'Audit 525: Always Ready',
    'audit_525_always_ready',
    true,
    true
);

COMMIT;


-- =========================================================
-- LDU de Quito
-- OLD = 25943
-- NEW = 35237
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 35237
WHERE team_id = 25943;

UPDATE public.player_season_statistics
SET team_id = 35237
WHERE team_id = 25943;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 25943
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 35237
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    25943,
    35237,
    'Audit 525: LDU de Quito',
    'audit_525_ldu_de_quito',
    true,
    true
);

COMMIT;