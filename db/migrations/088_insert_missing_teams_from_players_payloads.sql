-- ============================================================================
-- 088_insert_missing_teams_from_players_payloads.sql
-- Cíl:
--   Doplnit chybějící týmy do public.teams
--   přímo z EXISTUJÍCÍCH season payloadů v staging.stg_api_payloads
-- ============================================================================

WITH team_src AS (
    SELECT DISTINCT
        p.provider,
        stat_block -> 'team' ->> 'id' AS external_team_id,
        NULLIF(BTRIM(stat_block -> 'team' ->> 'name'), '') AS team_name
    FROM staging.stg_api_payloads p
    CROSS JOIN LATERAL jsonb_array_elements(p.payload_json -> 'response') AS resp(player_row)
    CROSS JOIN LATERAL jsonb_array_elements(resp.player_row -> 'statistics') AS stat(stat_block)
    WHERE p.provider = 'api_football'
      AND p.sport_code = 'football'
      AND p.entity_type = 'players'
      AND p.endpoint_name = 'players'
      AND COALESCE((p.payload_json ->> 'results')::int, 0) > 0
      AND stat_block -> 'team' ->> 'id' IS NOT NULL
      AND NULLIF(BTRIM(stat_block -> 'team' ->> 'name'), '') IS NOT NULL
),
missing_only AS (
    SELECT DISTINCT
        ts.provider,
        ts.external_team_id,
        ts.team_name
    FROM team_src ts
    LEFT JOIN public.team_provider_map tpm
      ON tpm.provider = ts.provider
     AND tpm.provider_team_id = ts.external_team_id
    LEFT JOIN public.teams t
      ON t.ext_source = ts.provider
     AND t.ext_team_id = ts.external_team_id
    WHERE tpm.team_id IS NULL
      AND t.id IS NULL
)
INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id,
    created_at,
    updated_at
)
SELECT
    team_name,
    provider,
    external_team_id,
    NOW(),
    NOW()
FROM missing_only;