-- ============================================================================
-- 061_list_unmapped_players_for_provider_map.sql
-- Cíl:
--   Vypsat hráče ze staging.stg_provider_player_season_stats,
--   kteří ještě nemají záznam v public.player_provider_map
-- ============================================================================

SELECT
    s.provider,
    s.sport_code,
    s.player_external_id,
    MIN(s.team_external_id) AS sample_team_external_id,
    MIN(s.external_league_id) AS sample_league_external_id,
    MIN(s.season) AS sample_season,
    COUNT(*) AS stat_rows
FROM staging.stg_provider_player_season_stats s
LEFT JOIN public.player_provider_map ppm
  ON ppm.provider = s.provider
 AND ppm.provider_player_id = s.player_external_id
WHERE ppm.player_id IS NULL
GROUP BY
    s.provider,
    s.sport_code,
    s.player_external_id
ORDER BY
    stat_rows DESC,
    s.player_external_id;