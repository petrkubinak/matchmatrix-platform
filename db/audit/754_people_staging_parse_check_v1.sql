/*
754_people_staging_parse_check_v1.sql

Účel:
- ověřit výsledek parseru PEOPLE kandidátů ve staging
*/

SELECT
    provider,
    sport_code,
    raw_payload_id,
    COUNT(*) AS rows_count,
    MIN(player_name) AS sample_first_player,
    MAX(player_name) AS sample_last_player
FROM staging.stg_provider_players
WHERE raw_payload_id IN (743, 745, 746)
GROUP BY provider, sport_code, raw_payload_id
ORDER BY raw_payload_id;

SELECT
    provider,
    sport_code,
    raw_payload_id,
    COUNT(*) AS rows_count,
    MIN(coach_name) AS sample_first_coach,
    MAX(coach_name) AS sample_last_coach
FROM staging.stg_provider_coaches
WHERE raw_payload_id = 744
GROUP BY provider, sport_code, raw_payload_id;

SELECT
    id,
    provider,
    sport_code,
    entity_type,
    parse_status,
    parse_message
FROM staging.stg_api_payloads
WHERE id IN (743, 744, 745, 746)
ORDER BY id;