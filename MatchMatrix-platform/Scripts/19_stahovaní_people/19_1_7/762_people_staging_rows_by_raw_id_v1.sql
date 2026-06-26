/*
762_people_staging_rows_by_raw_id_v1.sql

Účel:
- ověřit reálný stav staging.stg_provider_players podle RAW id
- zjistit, jestli se zapsali jen BK/AFB, nebo něco pod jiným providerem
*/

SELECT
    raw_payload_id,
    provider,
    sport_code,
    source_endpoint,
    COUNT(*) AS rows_count,
    MIN(player_name) AS sample_min,
    MAX(player_name) AS sample_max
FROM staging.stg_provider_players
WHERE raw_payload_id IN (743, 745, 746)
GROUP BY raw_payload_id, provider, sport_code, source_endpoint
ORDER BY raw_payload_id, provider, sport_code;

SELECT
    raw_payload_id,
    provider,
    sport_code,
    source_endpoint,
    COUNT(*) AS rows_count,
    MIN(coach_name) AS sample_min,
    MAX(coach_name) AS sample_max
FROM staging.stg_provider_coaches
WHERE raw_payload_id = 744
GROUP BY raw_payload_id, provider, sport_code, source_endpoint;