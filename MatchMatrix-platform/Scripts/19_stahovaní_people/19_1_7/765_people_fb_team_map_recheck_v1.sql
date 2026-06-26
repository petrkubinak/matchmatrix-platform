SELECT
    p.provider,
    p.sport_code,
    p.raw_payload_id,
    p.external_team_id,
    p.team_name,
    COUNT(*) AS staging_players,
    COUNT(tpm.team_id) AS mapped_team_rows,
    COUNT(*) - COUNT(tpm.team_id) AS missing_team_map_rows
FROM staging.stg_provider_players p
LEFT JOIN public.team_provider_map tpm
    ON tpm.provider = p.provider
   AND tpm.provider_team_id = p.external_team_id::text
WHERE p.raw_payload_id = 743
GROUP BY
    p.provider,
    p.sport_code,
    p.raw_payload_id,
    p.external_team_id,
    p.team_name
ORDER BY missing_team_map_rows DESC, staging_players DESC;