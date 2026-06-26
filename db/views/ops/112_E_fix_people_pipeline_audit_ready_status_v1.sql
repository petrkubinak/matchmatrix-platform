CREATE OR REPLACE VIEW ops.v_people_pipeline_audit_v1 AS
WITH raw_payloads AS (
    SELECT
        p.provider,
        CASE
            WHEN lower(p.sport_code) = 'football' THEN 'FB'
            WHEN lower(p.sport_code) = 'basketball' THEN 'BK'
            WHEN lower(p.sport_code) = 'hockey' THEN 'HK'
            WHEN lower(p.sport_code) = 'cricket' THEN 'CK'
            WHEN lower(p.sport_code) = 'baseball' THEN 'BSB'
            WHEN lower(p.sport_code) = 'american_football' THEN 'AFB'
            WHEN lower(p.sport_code) = 'field_hockey' THEN 'FH'
            ELSE upper(p.sport_code)
        END AS sport_code,
        COUNT(*) AS raw_payloads,
        COUNT(*) FILTER (WHERE p.parse_status = 'pending') AS raw_pending,
        COUNT(*) FILTER (WHERE p.parse_status = 'parsed') AS raw_parsed,
        COUNT(*) FILTER (WHERE p.parse_status = 'error') AS raw_error
    FROM staging.stg_api_payloads p
    WHERE p.entity_type = 'players'
    GROUP BY
        p.provider,
        CASE
            WHEN lower(p.sport_code) = 'football' THEN 'FB'
            WHEN lower(p.sport_code) = 'basketball' THEN 'BK'
            WHEN lower(p.sport_code) = 'hockey' THEN 'HK'
            WHEN lower(p.sport_code) = 'cricket' THEN 'CK'
            WHEN lower(p.sport_code) = 'baseball' THEN 'BSB'
            WHEN lower(p.sport_code) = 'american_football' THEN 'AFB'
            WHEN lower(p.sport_code) = 'field_hockey' THEN 'FH'
            ELSE upper(p.sport_code)
        END
),
staging_players AS (
    SELECT
        sp.provider,
        CASE
            WHEN lower(sp.sport_code) = 'football' THEN 'FB'
            WHEN lower(sp.sport_code) = 'basketball' THEN 'BK'
            WHEN lower(sp.sport_code) = 'hockey' THEN 'HK'
            WHEN lower(sp.sport_code) = 'cricket' THEN 'CK'
            WHEN lower(sp.sport_code) = 'baseball' THEN 'BSB'
            WHEN lower(sp.sport_code) = 'american_football' THEN 'AFB'
            WHEN lower(sp.sport_code) = 'field_hockey' THEN 'FH'
            ELSE upper(sp.sport_code)
        END AS sport_code,
        COUNT(*) AS staging_players,
        COUNT(DISTINCT sp.external_player_id) AS staging_distinct_players
    FROM staging.stg_provider_players sp
    GROUP BY
        sp.provider,
        CASE
            WHEN lower(sp.sport_code) = 'football' THEN 'FB'
            WHEN lower(sp.sport_code) = 'basketball' THEN 'BK'
            WHEN lower(sp.sport_code) = 'hockey' THEN 'HK'
            WHEN lower(sp.sport_code) = 'cricket' THEN 'CK'
            WHEN lower(sp.sport_code) = 'baseball' THEN 'BSB'
            WHEN lower(sp.sport_code) = 'american_football' THEN 'AFB'
            WHEN lower(sp.sport_code) = 'field_hockey' THEN 'FH'
            ELSE upper(sp.sport_code)
        END
),
public_players AS (
    SELECT
        p.ext_source AS provider,
        s.code AS sport_code,
        COUNT(*) AS public_players
    FROM public.players p
    JOIN public.sports s
        ON s.id = p.sport_id
    GROUP BY p.ext_source, s.code
),
provider_maps AS (
    SELECT
        ppm.provider,
        s.code AS sport_code,
        COUNT(*) AS provider_maps
    FROM public.player_provider_map ppm
    JOIN public.players p
        ON p.id = ppm.player_id
    JOIN public.sports s
        ON s.id = p.sport_id
    GROUP BY ppm.provider, s.code
)
SELECT
    COALESCE(r.provider, sp.provider, pp.provider) AS provider,
    COALESCE(r.sport_code, sp.sport_code, pp.sport_code) AS sport_code,
    COALESCE(r.raw_payloads, 0::bigint) AS raw_payloads,
    COALESCE(r.raw_pending, 0::bigint) AS raw_pending,
    COALESCE(r.raw_parsed, 0::bigint) AS raw_parsed,
    COALESCE(r.raw_error, 0::bigint) AS raw_error,
    COALESCE(sp.staging_players, 0::bigint) AS staging_players,
    COALESCE(sp.staging_distinct_players, 0::bigint) AS staging_distinct_players,
    COALESCE(pp.public_players, 0::bigint) AS public_players,
    COALESCE(pm.provider_maps, 0::bigint) AS provider_maps,

    CASE
        WHEN COALESCE(sp.staging_distinct_players, 0::bigint) = 0 THEN 0::numeric
        ELSE LEAST(
            ROUND(
                COALESCE(pp.public_players, 0::bigint)::numeric
                / sp.staging_distinct_players::numeric * 100::numeric,
                2
            ),
            100.00
        )
    END AS public_coverage_pct,

    CASE
        WHEN COALESCE(sp.staging_distinct_players, 0::bigint) > 0
         AND COALESCE(pp.public_players, 0::bigint) >= COALESCE(sp.staging_distinct_players, 0::bigint)
         AND COALESCE(pm.provider_maps, 0::bigint) >= COALESCE(sp.staging_distinct_players, 0::bigint)
            THEN 'READY'::text

        WHEN COALESCE(sp.staging_players, 0::bigint) > 0
         AND COALESCE(pp.public_players, 0::bigint) = 0
            THEN 'READY_FOR_MERGE'::text

        WHEN COALESCE(r.raw_pending, 0::bigint) > 0
            THEN 'RAW_PENDING_PARSE'::text

        WHEN COALESCE(r.raw_error, 0::bigint) > 0
            THEN 'HAS_ERRORS'::text

        ELSE 'DATA_GAP'::text
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
   AND pm.sport_code = COALESCE(r.sport_code, sp.sport_code, pp.sport_code)
ORDER BY
    COALESCE(r.sport_code, sp.sport_code, pp.sport_code),
    COALESCE(r.provider, sp.provider, pp.provider);