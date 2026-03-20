-- ============================================================================
-- 056_check_player_season_stats_loaded.sql
-- Cíl:
--   Ověřit, co se nahrálo do staging.stg_provider_player_season_stats
-- ============================================================================

SELECT 'rows_total' AS metric, COUNT(*)::text AS value
FROM staging.stg_provider_player_season_stats

UNION ALL

SELECT 'players_distinct', COUNT(DISTINCT player_external_id)::text
FROM staging.stg_provider_player_season_stats

UNION ALL

SELECT 'teams_distinct', COUNT(DISTINCT team_external_id)::text
FROM staging.stg_provider_player_season_stats

UNION ALL

SELECT 'leagues_distinct', COUNT(DISTINCT external_league_id)::text
FROM staging.stg_provider_player_season_stats

UNION ALL

SELECT 'seasons_distinct', COUNT(DISTINCT season)::text
FROM staging.stg_provider_player_season_stats

UNION ALL

SELECT 'top_stat_1',
       COALESCE((
           SELECT stat_name
           FROM staging.stg_provider_player_season_stats
           GROUP BY stat_name
           ORDER BY COUNT(*) DESC, stat_name
           LIMIT 1
       ), '(none)')

UNION ALL

SELECT 'top_stat_2',
       COALESCE((
           SELECT stat_name
           FROM (
               SELECT stat_name,
                      ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC, stat_name) AS rn
               FROM staging.stg_provider_player_season_stats
               GROUP BY stat_name
           ) q
           WHERE rn = 2
       ), '(none)')

UNION ALL

SELECT 'top_stat_3',
       COALESCE((
           SELECT stat_name
           FROM (
               SELECT stat_name,
                      ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC, stat_name) AS rn
               FROM staging.stg_provider_player_season_stats
               GROUP BY stat_name
           ) q
           WHERE rn = 3
       ), '(none)');