-- ============================================================================
-- 051_check_player_stats_pipeline.sql
-- Cíl:
--   Rychlá diagnostika players pipeline před merge do public.player_match_statistics
-- ============================================================================

SELECT 'staging_rows' AS check_name, COUNT(*)::text AS value
FROM staging.stg_provider_player_stats

UNION ALL

SELECT 'distinct_players', COUNT(DISTINCT player_external_id)::text
FROM staging.stg_provider_player_stats

UNION ALL

SELECT 'distinct_fixtures', COUNT(DISTINCT external_fixture_id)::text
FROM staging.stg_provider_player_stats

UNION ALL

SELECT 'mapped_players', COUNT(*)::text
FROM (
    SELECT DISTINCT s.provider, s.player_external_id
    FROM staging.stg_provider_player_stats s
    JOIN public.player_provider_map ppm
      ON ppm.provider = s.provider
     AND ppm.provider_player_id = s.player_external_id
) x

UNION ALL

SELECT 'mapped_matches', COUNT(*)::text
FROM (
    SELECT DISTINCT s.provider, s.external_fixture_id
    FROM staging.stg_provider_player_stats s
    JOIN public.matches m
      ON m.ext_source = s.provider
     AND m.ext_match_id = s.external_fixture_id
) x

UNION ALL

SELECT 'mapped_teams', COUNT(*)::text
FROM (
    SELECT DISTINCT s.provider, s.team_external_id
    FROM staging.stg_provider_player_stats s
    JOIN public.teams t
      ON t.ext_source = s.provider
     AND t.ext_team_id = s.team_external_id
) x

UNION ALL

SELECT 'top_stat_name_1',
       COALESCE((
           SELECT stat_name
           FROM staging.stg_provider_player_stats
           GROUP BY stat_name
           ORDER BY COUNT(*) DESC, stat_name
           LIMIT 1
       ), '(none)')

UNION ALL

SELECT 'top_stat_name_2',
       COALESCE((
           SELECT stat_name
           FROM (
               SELECT stat_name, ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC, stat_name) AS rn
               FROM staging.stg_provider_player_stats
               GROUP BY stat_name
           ) q
           WHERE rn = 2
       ), '(none)')

UNION ALL

SELECT 'top_stat_name_3',
       COALESCE((
           SELECT stat_name
           FROM (
               SELECT stat_name, ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC, stat_name) AS rn
               FROM staging.stg_provider_player_stats
               GROUP BY stat_name
           ) q
           WHERE rn = 3
       ), '(none)');