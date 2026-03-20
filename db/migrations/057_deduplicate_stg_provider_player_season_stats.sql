-- ============================================================================
-- 057_deduplicate_stg_provider_player_season_stats.sql
-- Cíl:
--   Odstranit duplicitní řádky ze staging.stg_provider_player_season_stats
--   podle business klíče a ponechat vždy nejnovější záznam.
-- ============================================================================

WITH ranked AS (
    SELECT
        id,
        ROW_NUMBER() OVER (
            PARTITION BY
                provider,
                sport_code,
                COALESCE(external_league_id, ''),
                COALESCE(season, ''),
                player_external_id,
                COALESCE(team_external_id, ''),
                stat_name,
                COALESCE(source_endpoint, '')
            ORDER BY
                updated_at DESC NULLS LAST,
                created_at DESC NULLS LAST,
                id DESC
        ) AS rn
    FROM staging.stg_provider_player_season_stats
)
DELETE FROM staging.stg_provider_player_season_stats t
USING ranked r
WHERE t.id = r.id
  AND r.rn > 1;