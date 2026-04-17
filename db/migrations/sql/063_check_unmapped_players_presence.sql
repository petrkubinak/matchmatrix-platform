-- ============================================================================
-- 063_check_unmapped_players_presence.sql
-- Cíl:
--   Zjistit, kolik unmapped hráčů už existuje v public.players přes ext_player_id
--   a kolik jich chybí úplně
-- ============================================================================

WITH unmapped AS (
    SELECT DISTINCT
        s.provider,
        s.sport_code,
        s.player_external_id
    FROM staging.stg_provider_player_season_stats s
    LEFT JOIN public.player_provider_map ppm
      ON ppm.provider = s.provider
     AND ppm.provider_player_id = s.player_external_id
    WHERE ppm.player_id IS NULL
)

SELECT 'unmapped_total' AS metric, COUNT(*)::text AS value
FROM unmapped

UNION ALL

SELECT 'exists_in_public_players_by_ext_id', COUNT(*)::text
FROM unmapped u
JOIN public.players p
  ON p.ext_source = u.provider
 AND p.ext_player_id = u.player_external_id

UNION ALL

SELECT 'missing_in_public_players_by_ext_id', COUNT(*)::text
FROM unmapped u
LEFT JOIN public.players p
  ON p.ext_source = u.provider
 AND p.ext_player_id = u.player_external_id
WHERE p.id IS NULL;