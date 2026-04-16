-- 551_merge_newcastle_safe.sql
-- Cíl:
-- safe merge duplicate team branch
--   Newcastle: 11904 -> 56

BEGIN;

-- =========================================================
-- A) provider map: odstranit konflikty providerů
-- =========================================================
DELETE FROM public.team_provider_map src
WHERE src.team_id = 11904
  AND EXISTS (
      SELECT 1
      FROM public.team_provider_map dst
      WHERE dst.team_id = 56
        AND dst.provider = src.provider
  );

UPDATE public.team_provider_map
SET team_id = 56
WHERE team_id = 11904;

-- =========================================================
-- B) aliases: odstranit kolizní aliasy
-- =========================================================
DELETE FROM public.team_aliases src
WHERE src.team_id = 11904
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases dst
      WHERE dst.team_id = 56
        AND lower(dst.alias) = lower(src.alias)
  );

UPDATE public.team_aliases
SET team_id = 56
WHERE team_id = 11904;

-- =========================================================
-- C) league_teams: odstranit kolize
-- =========================================================
DELETE FROM public.league_teams src
WHERE src.team_id = 11904
  AND EXISTS (
      SELECT 1
      FROM public.league_teams dst
      WHERE dst.team_id = 56
        AND dst.league_id = src.league_id
  );

UPDATE public.league_teams
SET team_id = 56
WHERE team_id = 11904;

-- =========================================================
-- D) ostatní FK tabulky
-- =========================================================
UPDATE public.article_team_map         SET team_id = 56 WHERE team_id = 11904;
UPDATE public.injuries                 SET team_id = 56 WHERE team_id = 11904;
UPDATE public.league_standings         SET team_id = 56 WHERE team_id = 11904;
UPDATE public.league_team_seasons      SET team_id = 56 WHERE team_id = 11904;
UPDATE public.lineups                  SET team_id = 56 WHERE team_id = 11904;
UPDATE public.match_events             SET team_id = 56 WHERE team_id = 11904;
UPDATE public.matches                  SET home_team_id = 56 WHERE home_team_id = 11904;
UPDATE public.matches                  SET away_team_id = 56 WHERE away_team_id = 11904;
UPDATE public.player_match_statistics  SET team_id = 56 WHERE team_id = 11904;
UPDATE public.player_season_statistics SET team_id = 56 WHERE team_id = 11904;
UPDATE public.player_team_history      SET team_id = 56 WHERE team_id = 11904;
UPDATE public.players                  SET team_id = 56 WHERE team_id = 11904;
UPDATE public.team_coach_history       SET team_id = 56 WHERE team_id = 11904;
UPDATE public.team_coaches             SET team_id = 56 WHERE team_id = 11904;
UPDATE public.team_match_statistics    SET team_id = 56 WHERE team_id = 11904;
UPDATE public.team_social_links        SET team_id = 56 WHERE team_id = 11904;
UPDATE public.team_stadiums            SET team_id = 56 WHERE team_id = 11904;
UPDATE public.team_transfers           SET from_team_id = 56 WHERE from_team_id = 11904;
UPDATE public.team_transfers           SET to_team_id   = 56 WHERE to_team_id   = 11904;
UPDATE public.team_translations        SET team_id = 56 WHERE team_id = 11904;
UPDATE public.user_favorite_teams      SET team_id = 56 WHERE team_id = 11904;

-- =========================================================
-- E) zachovat jednoduchý alias
-- =========================================================
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 56, 'Newcastle', 'merge_551'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases
    WHERE team_id = 56
      AND lower(alias) = lower('Newcastle')
);

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 56, 'Newcastle United', 'merge_551'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases
    WHERE team_id = 56
      AND lower(alias) = lower('Newcastle United')
);

-- =========================================================
-- F) smazat starou větev
-- =========================================================
DELETE FROM public.teams
WHERE id = 11904;

-- =========================================================
-- G) po kontrole
-- =========================================================
SELECT id, name
FROM public.teams
WHERE id IN (56, 11904)
ORDER BY id;

SELECT team_id, COUNT(*) AS cnt
FROM public.team_provider_map
WHERE team_id IN (56, 11904)
GROUP BY team_id
ORDER BY team_id;

SELECT team_id, COUNT(*) AS cnt
FROM public.team_aliases
WHERE team_id IN (56, 11904)
GROUP BY team_id
ORDER BY team_id;

COMMIT;