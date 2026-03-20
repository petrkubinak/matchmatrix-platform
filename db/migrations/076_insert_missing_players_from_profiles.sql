-- ============================================================================
-- 076_insert_missing_players_from_profiles.sql
-- Cíl:
--   Doplnit chybějící hráče z staging.stg_provider_player_profiles
--   do public.players
-- ============================================================================

INSERT INTO public.players (
    team_id,
    name,
    first_name,
    last_name,
    short_name,
    birth_date,
    nationality,
    position,
    height_cm,
    weight_kg,
    is_active,
    ext_source,
    ext_player_id,
    created_at,
    updated_at
)
SELECT DISTINCT
    tpm.team_id,
    spp.player_name,
    NULLIF(BTRIM(spp.first_name), '') AS first_name,
    NULLIF(BTRIM(spp.last_name), '') AS last_name,
    NULLIF(BTRIM(spp.player_name), '') AS short_name,
    NULL::date AS birth_date,
    NULLIF(BTRIM(spp.nationality), '') AS nationality,
    NULLIF(BTRIM(spp.position_code), '') AS position,
    NULLIF(regexp_replace(COALESCE(spp.height_cm::text, ''), '[^0-9]', '', 'g'), '')::integer AS height_cm,
    NULLIF(regexp_replace(COALESCE(spp.weight_kg::text, ''), '[^0-9]', '', 'g'), '')::integer AS weight_kg,
    COALESCE(spp.is_active, true) AS is_active,
    spp.provider AS ext_source,
    spp.external_player_id AS ext_player_id,
    NOW(),
    NOW()
FROM staging.stg_provider_player_profiles spp
LEFT JOIN public.team_provider_map tpm
  ON tpm.provider = spp.provider
 AND tpm.provider_team_id = spp.external_team_id
LEFT JOIN public.players p
  ON p.ext_source = spp.provider
 AND p.ext_player_id = spp.external_player_id
WHERE p.id IS NULL;