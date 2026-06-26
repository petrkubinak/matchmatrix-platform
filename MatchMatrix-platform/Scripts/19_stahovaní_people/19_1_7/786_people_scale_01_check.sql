SELECT
    id,
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    status,
    attempts,
    last_attempt
FROM ops.ingest_planner
WHERE run_group = 'FB_PEOPLE_SCALE_01'
ORDER BY provider_league_id::int;

SELECT
    provider,
    sport_code,
    entity_type,
    parse_status,
    COUNT(*) AS raw_count,
    SUM(jsonb_array_length(payload_json->'response')) AS response_rows
FROM staging.stg_api_payloads
WHERE id BETWEEN 759 AND 768
GROUP BY provider, sport_code, entity_type, parse_status;

SELECT
    COUNT(*) AS mapped_players_from_scale_raws
FROM staging.stg_provider_players p
JOIN public.player_provider_map ppm
    ON ppm.provider = p.provider
   AND ppm.provider_player_id = p.external_player_id::text
WHERE p.raw_payload_id BETWEEN 759 AND 768;