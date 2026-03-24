-- =========================================================
-- MatchMatrix
-- 209_fix_player_season_statistics_key.sql
--
-- Účel:
-- 1) odstranit duplicity pro (player_id, league_id, season)
-- 2) vytvořit správný unique index pro season merge
-- =========================================================

BEGIN;

WITH ranked AS (
    SELECT
        id,
        ROW_NUMBER() OVER (
            PARTITION BY player_id, league_id, season
            ORDER BY
                updated_at DESC NULLS LAST,
                created_at DESC NULLS LAST,
                id DESC
        ) AS rn
    FROM public.player_season_statistics
),
to_delete AS (
    SELECT id
    FROM ranked
    WHERE rn > 1
)
DELETE FROM public.player_season_statistics t
USING to_delete d
WHERE t.id = d.id;

COMMIT;

CREATE UNIQUE INDEX IF NOT EXISTS ux_player_season_statistics_player_league_season
ON public.player_season_statistics (player_id, league_id, season);