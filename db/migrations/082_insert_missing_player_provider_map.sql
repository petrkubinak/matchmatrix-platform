-- ============================================================================
-- 082_insert_missing_player_provider_map.sql
-- Cíl:
--   Doplnit mapování hráčů (provider → player_id)
-- ============================================================================

INSERT INTO public.player_provider_map (
    provider,
    provider_player_id,
    player_id,
    is_active,
    created_at,
    updated_at
)
SELECT
    p.ext_source AS provider,
    p.ext_player_id AS provider_player_id,
    p.id AS player_id,
    true,
    NOW(),
    NOW()
FROM public.players p
LEFT JOIN public.player_provider_map ppm
  ON ppm.provider = p.ext_source
 AND ppm.provider_player_id = p.ext_player_id
WHERE ppm.id IS NULL;