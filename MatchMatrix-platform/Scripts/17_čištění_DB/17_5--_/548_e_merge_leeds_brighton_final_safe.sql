-- 548_e_merge_leeds_brighton_final_safe.sql
-- Cíl:
-- finální safe merge duplicate team branches
--   Leeds    956   -> 61
--   Brighton 11917 -> 64

BEGIN;

-- =========================================================
-- A) LEEDS 956 -> 61
-- =========================================================

-- provider map: odstranit konflikty providerů
DELETE FROM public.team_provider_map src
WHERE src.team_id = 956
  AND EXISTS (
      SELECT 1
      FROM public.team_provider_map dst
      WHERE dst.team_id = 61
        AND dst.provider = src.provider
  );

UPDATE public.team_provider_map
SET team_id = 61
WHERE team_id = 956;

-- aliases: odstranit kolizní aliasy
DELETE FROM public.team_aliases src
WHERE src.team_id = 956
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases dst
      WHERE dst.team_id = 61
        AND lower(dst.alias) = lower(src.alias)
  );

UPDATE public.team_aliases
SET team_id = 61
WHERE team_id = 956;

-- league_teams: odstranit kolize
DELETE FROM public.league_teams src
WHERE src.team_id = 956
  AND EXISTS (
      SELECT 1
      FROM public.league_teams dst
      WHERE dst.team_id = 61
        AND dst.league_id = src.league_id
  );

UPDATE public.league_teams
SET team_id = 61
WHERE team_id = 956;

-- ostatní FK tabulky
UPDATE public.article_team_map         SET team_id = 61 WHERE team_id = 956;
UPDATE public.injuries                 SET team_id = 61 WHERE team_id = 956;
UPDATE public.league_standings         SET team_id = 61 WHERE team_id = 956;
UPDATE public.league_team_seasons      SET team_id = 61 WHERE team_id = 956;
UPDATE public.lineups                  SET team_id = 61 WHERE team_id = 956;
UPDATE public.match_events             SET team_id = 61 WHERE team_id = 956;
UPDATE public.matches                  SET home_team_id = 61 WHERE home_team_id = 956;
UPDATE public.matches                  SET away_team_id = 61 WHERE away_team_id = 956;
UPDATE public.player_match_statistics  SET team_id = 61 WHERE team_id = 956;
UPDATE public.player_season_statistics SET team_id = 61 WHERE team_id = 956;
UPDATE public.player_team_history      SET team_id = 61 WHERE team_id = 956;
UPDATE public.players                  SET team_id = 61 WHERE team_id = 956;
UPDATE public.team_coach_history       SET team_id = 61 WHERE team_id = 956;
UPDATE public.team_coaches             SET team_id = 61 WHERE team_id = 956;
UPDATE public.team_match_statistics    SET team_id = 61 WHERE team_id = 956;
UPDATE public.team_social_links        SET team_id = 61 WHERE team_id = 956;
UPDATE public.team_stadiums            SET team_id = 61 WHERE team_id = 956;
UPDATE public.team_transfers           SET from_team_id = 61 WHERE from_team_id = 956;
UPDATE public.team_transfers           SET to_team_id   = 61 WHERE to_team_id   = 956;
UPDATE public.team_translations        SET team_id = 61 WHERE team_id = 956;
UPDATE public.user_favorite_teams      SET team_id = 61 WHERE team_id = 956;

-- zachovat jednoduchý alias
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 61, 'Leeds', 'merge_548_e'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases
    WHERE team_id = 61
      AND lower(alias) = lower('Leeds')
);

DELETE FROM public.teams
WHERE id = 956;

-- =========================================================
-- B) BRIGHTON 11917 -> 64
-- =========================================================

DELETE FROM public.team_provider_map src
WHERE src.team_id = 11917
  AND EXISTS (
      SELECT 1
      FROM public.team_provider_map dst
      WHERE dst.team_id = 64
        AND dst.provider = src.provider
  );

UPDATE public.team_provider_map
SET team_id = 64
WHERE team_id = 11917;

DELETE FROM public.team_aliases src
WHERE src.team_id = 11917
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases dst
      WHERE dst.team_id = 64
        AND lower(dst.alias) = lower(src.alias)
  );

UPDATE public.team_aliases
SET team_id = 64
WHERE team_id = 11917;

DELETE FROM public.league_teams src
WHERE src.team_id = 11917
  AND EXISTS (
      SELECT 1
      FROM public.league_teams dst
      WHERE dst.team_id = 64
        AND dst.league_id = src.league_id
  );

UPDATE public.league_teams
SET team_id = 64
WHERE team_id = 11917;

UPDATE public.article_team_map         SET team_id = 64 WHERE team_id = 11917;
UPDATE public.injuries                 SET team_id = 64 WHERE team_id = 11917;
UPDATE public.league_standings         SET team_id = 64 WHERE team_id = 11917;
UPDATE public.league_team_seasons      SET team_id = 64 WHERE team_id = 11917;
UPDATE public.lineups                  SET team_id = 64 WHERE team_id = 11917;
UPDATE public.match_events             SET team_id = 64 WHERE team_id = 11917;
UPDATE public.matches                  SET home_team_id = 64 WHERE home_team_id = 11917;
UPDATE public.matches                  SET away_team_id = 64 WHERE away_team_id = 11917;
UPDATE public.player_match_statistics  SET team_id = 64 WHERE team_id = 11917;
UPDATE public.player_season_statistics SET team_id = 64 WHERE team_id = 11917;
UPDATE public.player_team_history      SET team_id = 64 WHERE team_id = 11917;
UPDATE public.players                  SET team_id = 64 WHERE team_id = 11917;
UPDATE public.team_coach_history       SET team_id = 64 WHERE team_id = 11917;
UPDATE public.team_coaches             SET team_id = 64 WHERE team_id = 11917;
UPDATE public.team_match_statistics    SET team_id = 64 WHERE team_id = 11917;
UPDATE public.team_social_links        SET team_id = 64 WHERE team_id = 11917;
UPDATE public.team_stadiums            SET team_id = 64 WHERE team_id = 11917;
UPDATE public.team_transfers           SET from_team_id = 64 WHERE from_team_id = 11917;
UPDATE public.team_transfers           SET to_team_id   = 64 WHERE to_team_id   = 11917;
UPDATE public.team_translations        SET team_id = 64 WHERE team_id = 11917;
UPDATE public.user_favorite_teams      SET team_id = 64 WHERE team_id = 11917;

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 64, 'Brighton', 'merge_548_e'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases
    WHERE team_id = 64
      AND lower(alias) = lower('Brighton')
);

DELETE FROM public.teams
WHERE id = 11917;

-- =========================================================
-- C) PO KONTROLA
-- =========================================================
SELECT id, name
FROM public.teams
WHERE id IN (61, 64, 956, 11917)
ORDER BY id;

SELECT team_id, COUNT(*) AS cnt
FROM public.player_season_statistics
WHERE team_id IN (61, 64, 956, 11917)
GROUP BY team_id
ORDER BY team_id;

SELECT team_id, COUNT(*) AS cnt
FROM public.team_provider_map
WHERE team_id IN (61, 64, 956, 11917)
GROUP BY team_id
ORDER BY team_id;

SELECT team_id, COUNT(*) AS cnt
FROM public.team_aliases
WHERE team_id IN (61, 64, 956, 11917)
GROUP BY team_id
ORDER BY team_id;

COMMIT;