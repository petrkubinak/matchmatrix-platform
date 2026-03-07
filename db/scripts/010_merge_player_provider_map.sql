-- =====================================================
-- MatchMatrix
-- Merge staging.player_provider_map_import
-- -> public.player_provider_map
-- =====================================================

INSERT INTO public.player_provider_map
(
    provider,
    provider_player_id,
    player_id,
    provider_player_name,
    is_active
)

SELECT
    s.provider_code,
    s.provider_player_id,
    p.id,
    s.player_name,
    true

FROM staging.player_provider_map_import s

JOIN public.players p
    ON p.ext_source = s.provider_code
   AND p.ext_player_id = s.provider_player_id

ON CONFLICT (provider, provider_player_id)
DO UPDATE SET
    player_id = EXCLUDED.player_id,
    provider_player_name = EXCLUDED.provider_player_name,
    updated_at = now();