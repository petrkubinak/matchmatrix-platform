-- ============================================================================
-- 065_insert_missing_player_provider_map.sql
-- Cíl:
--   Doplnit public.player_provider_map pro hráče, kteří už existují
--   v public.players a mají ext_source + ext_player_id.
-- ============================================================================

INSERT INTO public.player_provider_map (
    provider,
    provider_player_id,
    player_id,
    provider_team_id,
    provider_team_name,
    provider_player_name,
    is_active,
    created_at,
    updated_at
)
SELECT
    p.ext_source AS provider,
    p.ext_player_id AS provider_player_id,
    p.id AS player_id,
    sp.external_team_id AS provider_team_id,
    sp.team_name AS provider_team_name,
    sp.player_name AS provider_player_name,
    COALESCE(sp.is_active, true) AS is_active,
    NOW(),
    NOW()
FROM public.players p
JOIN staging.stg_provider_players sp
  ON sp.provider = p.ext_source
 AND sp.external_player_id = p.ext_player_id
LEFT JOIN public.player_provider_map ppm
  ON ppm.provider = p.ext_source
 AND ppm.provider_player_id = p.ext_player_id
WHERE p.ext_source IS NOT NULL
  AND p.ext_player_id IS NOT NULL
  AND ppm.id IS NULL;