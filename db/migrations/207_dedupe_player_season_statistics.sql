-- =========================================================
-- MatchMatrix
-- 207_dedupe_player_season_statistics.sql
--
-- Účel:
-- odstranit duplicity v public.player_season_statistics
-- pro klíč (player_id, league_id, season)
-- a ponechat vždy jen 1 řádek:
--   1) s nejnovějším updated_at
--   2) pak s nejnovějším created_at
--   3) pak s nejvyšším id
-- =========================================================

BEGIN;

WITH ranked AS (
    SELECT
        id,
        player_id,
        league_id,
        season,
        team_id,
        updated_at,
        created_at,
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

-- kontrola po spuštění:
-- select
--     player_id,
--     league_id,
--     season,
--     count(*) as dup_count
-- from public.player_season_statistics
-- group by player_id, league_id, season
-- having count(*) > 1
-- order by dup_count desc, player_id, league_id, season;