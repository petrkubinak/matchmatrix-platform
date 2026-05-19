SELECT
    p.provider,
    p.sport_code,
    p.raw_payload_id,
    COUNT(*) AS staging_players,
    COUNT(ppm.player_id) AS already_mapped_players,
    COUNT(*) - COUNT(ppm.player_id) AS missing_player_map
FROM staging.stg_provider_players p
LEFT JOIN public.player_provider_map ppm
    ON ppm.provider = p.provider
   AND ppm.provider_player_id = p.external_player_id::text
WHERE p.raw_payload_id IN (743, 746)
GROUP BY p.provider, p.sport_code, p.raw_payload_id
ORDER BY p.raw_payload_id;