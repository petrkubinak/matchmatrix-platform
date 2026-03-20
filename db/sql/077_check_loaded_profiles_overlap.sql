-- ============================================================================
-- 077_check_loaded_profiles_overlap.sql
-- Cíl:
--   Ověřit, zda nově naparsované player profiles už existují v public.players
--   a kolik z nich je stále missing.
-- ============================================================================

SELECT 'profiles_rows' AS metric, COUNT(*)::text AS value
FROM staging.stg_provider_player_profiles

UNION ALL

SELECT 'profiles_distinct_players', COUNT(DISTINCT external_player_id)::text
FROM staging.stg_provider_player_profiles

UNION ALL

SELECT 'profiles_matching_public_players', COUNT(*)::text
FROM (
    SELECT DISTINCT
        spp.provider,
        spp.external_player_id
    FROM staging.stg_provider_player_profiles spp
    JOIN public.players p
      ON p.ext_source = spp.provider
     AND p.ext_player_id = spp.external_player_id
) q

UNION ALL

SELECT 'profiles_missing_in_public_players', COUNT(*)::text
FROM (
    SELECT DISTINCT
        spp.provider,
        spp.external_player_id
    FROM staging.stg_provider_player_profiles spp
    LEFT JOIN public.players p
      ON p.ext_source = spp.provider
     AND p.ext_player_id = spp.external_player_id
    WHERE p.id IS NULL
) q;