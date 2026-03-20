	-- ============================================================================
-- 067_check_players_vs_stats_overlap.sql
-- Cíl:
--   Ověřit překryv mezi public.players a staging.stg_provider_player_season_stats
-- ============================================================================

WITH stats_players AS (
    SELECT DISTINCT
        provider,
        player_external_id
    FROM staging.stg_provider_player_season_stats
),
public_players AS (
    SELECT DISTINCT
        ext_source,
        ext_player_id
    FROM public.players
    WHERE ext_source IS NOT NULL
      AND ext_player_id IS NOT NULL
)

SELECT 'stats_distinct_players' AS metric, COUNT(*)::text AS value
FROM stats_players

UNION ALL

SELECT 'public_players_with_ext_id', COUNT(*)::text
FROM public_players

UNION ALL

SELECT 'overlap_players', COUNT(*)::text
FROM stats_players s
JOIN public_players p
  ON p.ext_source = s.provider
 AND p.ext_player_id = s.player_external_id

UNION ALL

SELECT 'stats_players_missing_in_public_players', COUNT(*)::text
FROM stats_players s
LEFT JOIN public_players p
  ON p.ext_source = s.provider
 AND p.ext_player_id = s.player_external_id
WHERE p.ext_player_id IS NULL

UNION ALL

SELECT 'stats_players_already_mapped', COUNT(*)::text
FROM stats_players s
JOIN public.player_provider_map ppm
  ON ppm.provider = s.provider
 AND ppm.provider_player_id = s.player_external_id;