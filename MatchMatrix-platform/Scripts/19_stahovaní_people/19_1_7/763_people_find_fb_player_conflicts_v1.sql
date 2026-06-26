/*
763_people_find_fb_player_conflicts_v1.sql

Účel:
- najít, proč FB players raw 743 neinsertuje žádné řádky
- ověřit, zda hráči už existují v staging pod jiným raw_payload_id/providerem
*/

WITH raw_players AS (
    SELECT
        x.value->'player'->>'id' AS external_player_id,
        x.value->'player'->>'name' AS player_name
    FROM staging.stg_api_payloads r
    CROSS JOIN LATERAL jsonb_array_elements(r.payload_json->'response') AS x(value)
    WHERE r.id = 743
)
SELECT
    rp.external_player_id AS raw_external_player_id,
    rp.player_name AS raw_player_name,
    p.id AS existing_staging_id,
    p.provider,
    p.sport_code,
    p.external_player_id,
    p.player_name,
    p.raw_payload_id,
    p.external_team_id,
    p.team_name,
    p.created_at
FROM raw_players rp
LEFT JOIN staging.stg_provider_players p
    ON p.external_player_id::text = rp.external_player_id::text
ORDER BY rp.external_player_id;