-- 046b_deduplicate_player_season_statistics.sql

WITH ranked AS (
    SELECT
        ctid,
        ROW_NUMBER() OVER (
            PARTITION BY player_id, team_id, league_id, season
            ORDER BY updated_at DESC NULLS LAST, created_at DESC NULLS LAST, ctid DESC
        ) AS rn
    FROM public.player_season_statistics
)
DELETE FROM public.player_season_statistics p
USING ranked r
WHERE p.ctid = r.ctid
  AND r.rn > 1;