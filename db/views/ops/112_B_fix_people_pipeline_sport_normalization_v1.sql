CREATE OR REPLACE VIEW ops.v_people_pipeline_audit_v1 AS
WITH raw_payloads AS (
    SELECT
        provider,
        CASE
            WHEN LOWER(sport_code) = 'football' THEN 'FB'
            WHEN LOWER(sport_code) = 'basketball' THEN 'BK'
            WHEN LOWER(sport_code) = 'hockey' THEN 'HK'
            WHEN LOWER(sport_code) = 'cricket' THEN 'CK'
            WHEN LOWER(sport_code) = 'baseball' THEN 'BSB'
            WHEN LOWER(sport_code) = 'american_football' THEN 'AFB'
            WHEN LOWER(sport_code) = 'field_hockey' THEN 'FH'
            ELSE UPPER(sport_code)
        END AS sport_code,
        COUNT(*) AS raw_payloads,
        COUNT(*) FILTER (WHERE parse_status = 'pending') AS raw_pending,
        COUNT(*) FILTER (WHERE parse_status = 'parsed') AS raw_parsed,
        COUNT(*) FILTER (WHERE parse_status = 'error') AS raw_error
    FROM staging.stg_api_payloads
    WHERE entity_type = 'players'
    GROUP BY provider, 2
),
staging_players AS (
    SELECT
        provider,
        CASE
            WHEN LOWER(sport_code) = 'football' THEN 'FB'
            WHEN LOWER(sport_code) = 'basketball' THEN 'BK'
            WHEN LOWER(sport_code) = 'hockey' THEN 'HK'
            WHEN LOWER(sport_code) = 'cricket' THEN 'CK'
            WHEN LOWER(sport_code) = 'baseball' THEN 'BSB'
            WHEN LOWER(sport_code) = 'american_football' THEN 'AFB'
            WHEN LOWER(sport_code) = 'field_hockey' THEN 'FH'
            ELSE UPPER(sport_code)
        END AS sport_code,
        COUNT(*) AS staging_players,
        COUNT(DISTINCT external_player_id) AS staging_distinct_players
    FROM staging.stg_provider_players
    GROUP BY provider, 2
),
public_players AS (
    SELECT
        p.ext_source AS provider,
        s.code AS sport_code,
        COUNT(*) AS public_players
    FROM public.players p
    JOIN public.sports s ON s.id = p.sport_id
    GROUP BY p.ext_source, s.code
),
provider_maps AS (
    SELECT
        provider,
        COUNT(*) AS provider_maps
    FROM public.player_provider_map
    GROUP BY provider
)
SELECT
    COALESCE(r.provider, sp.provider, pp.provider) AS provider,
    COALESCE(r.sport_code, sp.sport_code, pp.sport_code) AS sport_code,
    COALESCE(r.raw_payloads, 0) AS raw_payloads,
    COALESCE(r.raw_pending, 0) AS raw_pending,
    COALESCE(r.raw_parsed, 0) AS raw_parsed,
    COALESCE(r.raw_error, 0) AS raw_error,
    COALESCE(sp.staging_players, 0) AS staging_players,
    COALESCE(sp.staging_distinct_players, 0) AS staging_distinct_players,
    COALESCE(pp.public_players, 0) AS public_players,
    COALESCE(pm.provider_maps, 0) AS provider_maps,
    CASE
        WHEN COALESCE(sp.staging_distinct_players, 0) = 0 THEN 0
        ELSE ROUND((COALESCE(pp.public_players, 0)::numeric / sp.staging_distinct_players::numeric) * 100, 2)
    END AS public_coverage_pct,
    CASE
        WHEN COALESCE(pp.public_players, 0) > 0
         AND COALESCE(pp.public_players, 0) = COALESCE(pm.provider_maps, 0)
            THEN 'READY'
        WHEN COALESCE(sp.staging_players, 0) > 0
         AND COALESCE(pp.public_players, 0) = 0
            THEN 'READY_FOR_MERGE'
        WHEN COALESCE(r.raw_pending, 0) > 0
            THEN 'RAW_PENDING_PARSE'
        WHEN COALESCE(r.raw_error, 0) > 0
            THEN 'HAS_ERRORS'
        ELSE 'DATA_GAP'
    END AS people_status
FROM raw_payloads r
FULL JOIN staging_players sp
    ON sp.provider = r.provider
   AND sp.sport_code = r.sport_code
FULL JOIN public_players pp
    ON pp.provider = COALESCE(r.provider, sp.provider)
   AND pp.sport_code = COALESCE(r.sport_code, sp.sport_code)
LEFT JOIN provider_maps pm
    ON pm.provider = COALESCE(r.provider, sp.provider, pp.provider)
ORDER BY sport_code, provider;