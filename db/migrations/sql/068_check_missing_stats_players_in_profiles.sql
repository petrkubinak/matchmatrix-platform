-- ============================================================================
-- 068_check_missing_stats_players_in_profiles.sql
-- Cíl:
--   Ověřit, zda 220 hráčů chybějících v public.players
--   existuje ve staging.stg_provider_player_profiles
-- ============================================================================

WITH missing_stats_players AS (
    SELECT DISTINCT
        s.provider,
        s.sport_code,
        s.player_external_id
    FROM staging.stg_provider_player_season_stats s
    LEFT JOIN public.players p
      ON p.ext_source = s.provider
     AND p.ext_player_id = s.player_external_id
    WHERE p.id IS NULL
)

SELECT 'missing_stats_players_total' AS metric, COUNT(*)::text AS value
FROM missing_stats_players

UNION ALL

SELECT 'found_in_stg_provider_player_profiles', COUNT(*)::text
FROM missing_stats_players m
JOIN staging.stg_provider_player_profiles spp
  ON spp.provider = m.provider
 AND spp.sport_code = m.sport_code
 AND spp.external_player_id = m.player_external_id

UNION ALL

SELECT 'missing_even_in_stg_provider_player_profiles', COUNT(*)::text
FROM missing_stats_players m
LEFT JOIN staging.stg_provider_player_profiles spp
  ON spp.provider = m.provider
 AND spp.sport_code = m.sport_code
 AND spp.external_player_id = m.player_external_id
WHERE spp.id IS NULL;