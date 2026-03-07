-- =====================================================
-- MatchMatrix
-- Merge script: player_provider_map
-- Purpose: mapování hráčů na provider ID
-- =====================================================

INSERT INTO public.player_provider_map (
    player_id,
    provider_name,
    provider_player_id
)
SELECT
    player_id,
    provider_name,
    provider_player_id
FROM staging.player_provider_map_import
ON CONFLICT (provider_name, provider_player_id)
DO UPDATE SET
    player_id = EXCLUDED.player_id;