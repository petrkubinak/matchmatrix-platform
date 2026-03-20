-- ============================================================================
-- 081_insert_missing_players_from_existing_players_payloads.sql
-- Cíl:
--   Doplnit chybějící hráče do public.players přímo z EXISTUJÍCÍCH
--   season payloadů v staging.stg_api_payloads (entity_type='players')
--   bez dalších API callů.
-- ============================================================================

WITH player_src AS (
    SELECT DISTINCT
        p.provider,
        p.sport_code,
        player_obj ->> 'id' AS external_player_id,
        NULLIF(BTRIM(player_obj ->> 'name'), '') AS player_name,
        NULLIF(BTRIM(player_obj ->> 'firstname'), '') AS first_name,
        NULLIF(BTRIM(player_obj ->> 'lastname'), '') AS last_name,
        NULLIF(BTRIM(player_obj ->> 'name'), '') AS short_name,
        NULLIF(BTRIM(player_obj ->> 'nationality'), '') AS nationality,
        NULLIF(regexp_replace(COALESCE(player_obj ->> 'height', ''), '[^0-9]', '', 'g'), '')::integer AS height_cm,
        NULLIF(regexp_replace(COALESCE(player_obj ->> 'weight', ''), '[^0-9]', '', 'g'), '')::integer AS weight_kg,
        COALESCE((player_obj ->> 'injured')::boolean, false) = false AS is_active,
        stat_block -> 'team' ->> 'id' AS external_team_id,
        NULLIF(BTRIM(stat_block -> 'games' ->> 'position'), '') AS position_code
    FROM staging.stg_api_payloads p
    CROSS JOIN LATERAL jsonb_array_elements(p.payload_json -> 'response') AS resp(player_row)
    CROSS JOIN LATERAL (SELECT resp.player_row -> 'player' AS player_obj) po
    CROSS JOIN LATERAL jsonb_array_elements(resp.player_row -> 'statistics') AS stat(stat_block)
    WHERE p.provider = 'api_football'
      AND p.sport_code = 'football'
      AND p.entity_type = 'players'
      AND p.endpoint_name = 'players'
      AND COALESCE((p.payload_json ->> 'results')::int, 0) > 0
      AND player_obj ->> 'id' IS NOT NULL
),

dedup AS (
    SELECT DISTINCT ON (provider, sport_code, external_player_id)
        provider,
        sport_code,
        external_player_id,
        player_name,
        first_name,
        last_name,
        short_name,
        nationality,
        position_code,
        height_cm,
        weight_kg,
        is_active,
        external_team_id
    FROM player_src
    ORDER BY
        provider,
        sport_code,
        external_player_id,
        CASE WHEN external_team_id IS NOT NULL THEN 0 ELSE 1 END,
        CASE WHEN position_code IS NOT NULL THEN 0 ELSE 1 END
)

INSERT INTO public.players (
    team_id,
    name,
    first_name,
    last_name,
    short_name,
    birth_date,
    nationality,
    position,
    shirt_number,
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
    d.player_name,
    d.first_name,
    d.last_name,
    d.short_name,
    NULL::date AS birth_date,
    d.nationality,
    d.position_code AS position,
    NULL::integer AS shirt_number,
    d.height_cm,
    d.weight_kg,
    COALESCE(d.is_active, true),
    d.provider AS ext_source,
    d.external_player_id AS ext_player_id,
    NOW(),
    NOW()
FROM dedup d
LEFT JOIN public.team_provider_map tpm
  ON tpm.provider = d.provider
 AND tpm.provider_team_id = d.external_team_id
LEFT JOIN public.players p
  ON p.ext_source = d.provider
 AND p.ext_player_id = d.external_player_id
WHERE p.id IS NULL;