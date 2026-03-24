-- =========================================================
-- MatchMatrix
-- 206_fix_player_season_statistics_unique.sql
--
-- Účel:
-- Přidat správný unique constraint pro ON CONFLICT:
-- (player_id, league_id, season)
-- =========================================================

BEGIN;

-- 1) Přidáme správný unique index (pokud neexistuje)
CREATE UNIQUE INDEX IF NOT EXISTS ux_player_season_statistics_player_league_season
ON public.player_season_statistics (player_id, league_id, season);

COMMIT;