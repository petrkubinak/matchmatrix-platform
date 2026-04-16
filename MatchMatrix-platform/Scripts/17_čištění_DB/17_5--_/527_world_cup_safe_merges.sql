-- 527_world_cup_safe_merges.sql
-- Spouštěj BLOK PO BLOKU

-- =========================================================
-- USA -> United States
-- OLD = 11896
-- NEW = 639
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 639
WHERE team_id = 11896;

UPDATE public.player_season_statistics
SET team_id = 639
WHERE team_id = 11896;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 11896
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 639
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    11896,
    639,
    'Audit 527: USA -> United States',
    'audit_527_usa',
    true,
    true
);

COMMIT;


-- =========================================================
-- Ivory Coast
-- OLD = 11897
-- NEW = 662
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 662
WHERE team_id = 11897;

UPDATE public.player_season_statistics
SET team_id = 662
WHERE team_id = 11897;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 11897
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 662
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    11897,
    662,
    'Audit 527: Ivory Coast',
    'audit_527_ivory_coast',
    true,
    true
);

COMMIT;


-- =========================================================
-- Iraq
-- OLD = 73438
-- NEW = 80796
-- =========================================================
BEGIN;

UPDATE public.league_standings
SET team_id = 80796
WHERE team_id = 73438;

UPDATE public.player_season_statistics
SET team_id = 80796
WHERE team_id = 73438;

DELETE FROM public.team_aliases a_old
WHERE a_old.team_id = 73438
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases a_new
      WHERE a_new.team_id = 80796
        AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
  );

SELECT public.merge_team(
    73438,
    80796,
    'Audit 527: Iraq',
    'audit_527_iraq',
    true,
    true
);

COMMIT;