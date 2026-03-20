-- ============================================================================
-- 064_insert_missing_players_from_staging.sql
-- FINÁLNÍ FUNKČNÍ VERZE
-- Cíl:
--   Vložit chybějící hráče do public.players.
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
SELECT
    tpm.team_id,
    sp.player_name,
    NULLIF(BTRIM(sp.first_name), '') AS first_name,
    NULLIF(BTRIM(sp.last_name), '') AS last_name,
    NULLIF(BTRIM(sp.short_name), '') AS short_name,
    NULL::date AS birth_date,
    NULLIF(BTRIM(sp.nationality), '') AS nationality,
    NULLIF(BTRIM(sp.position_code), '') AS position,
    sp.height_cm,
    sp.weight_kg,
    COALESCE(sp.is_active, true) AS is_active,
    sp.provider AS ext_source,
    sp.external_player_id AS ext_player_id,
    NOW(),
    NOW()
FROM staging.stg_provider_players sp
LEFT JOIN public.team_provider_map tpm
  ON tpm.provider = sp.provider
 AND tpm.provider_team_id = sp.external_team_id
LEFT JOIN public.players p
  ON p.ext_source = sp.provider
 AND p.ext_player_id = sp.external_player_id
WHERE p.id IS NULL;