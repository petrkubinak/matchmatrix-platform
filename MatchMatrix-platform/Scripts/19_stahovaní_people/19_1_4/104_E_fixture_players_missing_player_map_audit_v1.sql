WITH raw_players AS (
    SELECT DISTINCT
        player_item->'player'->>'id' AS provider_player_id,
        player_item->'player'->>'name' AS player_name,
        player_item->'player'->>'photo' AS photo_url
    FROM staging.stg_api_payloads p
    CROSS JOIN LATERAL jsonb_array_elements(p.payload_json->'response') team_item
    CROSS JOIN LATERAL jsonb_array_elements(team_item->'players') player_item
    WHERE p.id = 1329
)
SELECT
    rp.provider_player_id,
    rp.player_name,
    rp.photo_url,
    ppm.player_id AS mapped_player_id,
    p.id AS public_player_by_ext_id,
    p2.id AS public_player_by_name
FROM raw_players rp
LEFT JOIN public.player_provider_map ppm
    ON ppm.provider = 'api_football'
   AND ppm.provider_player_id = rp.provider_player_id
LEFT JOIN public.players p
    ON p.ext_source = 'api_football'
   AND p.ext_player_id = rp.provider_player_id
LEFT JOIN public.players p2
    ON lower(p2.name) = lower(rp.player_name)
ORDER BY
    ppm.player_id NULLS FIRST,
    rp.player_name;