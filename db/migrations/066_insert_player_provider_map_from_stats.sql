-- ============================================================================
-- 066_insert_player_provider_map_from_stats.sql
-- Cíl:
--   Doplnit player_provider_map z player stats (správný zdroj dat)
-- ============================================================================

INSERT INTO public.player_provider_map (
    provider,
    provider_player_id,
    player_id,
    provider_team_id,
    provider_player_name,
    is_active,
    created_at,
    updated_at
)
SELECT DISTINCT
    s.provider,
    s.player_external_id,
    p.id AS player_id,
    s.team_external_id,
    NULL AS provider_player_name,
    true,
    NOW(),
    NOW()
FROM staging.stg_provider_player_season_stats s
JOIN public.players p
  ON p.ext_source = s.provider
 AND p.ext_player_id = s.player_external_id
LEFT JOIN public.player_provider_map ppm
  ON ppm.provider = s.provider
 AND ppm.provider_player_id = s.player_external_id
WHERE ppm.id IS NULL;