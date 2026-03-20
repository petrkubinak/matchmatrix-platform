-- ============================================================================
-- 062_match_unmapped_players_to_existing.sql
-- OPRAVENÁ VERZE
-- Cíl:
--   Najít unmapped hráče, kteří už existují v public.players
--   přes staging.stg_provider_players
-- ============================================================================

SELECT
    s.player_external_id,
    sp.player_name,
    p.id AS player_id,
    p.name,
    COUNT(*) AS stat_rows
FROM staging.stg_provider_player_season_stats s

LEFT JOIN public.player_provider_map ppm
  ON ppm.provider = s.provider
 AND ppm.provider_player_id = s.player_external_id

JOIN staging.stg_provider_players sp
  ON sp.provider = s.provider
 AND sp.sport_code = s.sport_code
 AND sp.external_player_id = s.player_external_id

JOIN public.players p
  ON LOWER(p.name) = LOWER(sp.player_name)

WHERE ppm.player_id IS NULL

GROUP BY
    s.player_external_id,
    sp.player_name,
    p.id,
    p.name

ORDER BY stat_rows DESC, sp.player_name;