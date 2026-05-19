SELECT
    status,
    COUNT(*) AS jobs_count
FROM ops.ingest_planner
WHERE run_group = 'FB_PEOPLE_TEAM_SCALE_01'
GROUP BY status
ORDER BY status;

SELECT
    provider,
    sport_code,
    entity_type,
    parse_status,
    COUNT(*) AS raw_count,
    SUM(jsonb_array_length(payload_json->'response')) AS response_rows
FROM staging.stg_api_payloads
WHERE id BETWEEN 779 AND 798
GROUP BY provider, sport_code, entity_type, parse_status;

SELECT
    COUNT(*) AS mapped_players_from_team_scale_01
FROM staging.stg_provider_players p
JOIN public.player_provider_map ppm
    ON ppm.provider = p.provider
   AND ppm.provider_player_id = p.external_player_id::text
WHERE p.raw_payload_id BETWEEN 779 AND 798;