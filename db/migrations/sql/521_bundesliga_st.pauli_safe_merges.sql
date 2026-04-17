-- =========================================================
-- FC St. Pauli
-- OLD = 12079
-- NEW = 532
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 532
WHERE team_id = 12079;

UPDATE public.player_season_statistics
SET team_id = 532
WHERE team_id = 12079;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 12079
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 532
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    12079,
    532,
    'Audit 521: FC St. Pauli',
    'audit_521_fc_st_pauli',
    true,
    true
);

COMMIT;