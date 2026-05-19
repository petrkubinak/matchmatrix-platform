/*
756_people_public_merge_readiness_check_v1.sql

Účel:
- ověřit, jestli staging players mají týmové mapování do public.teams
- bez toho by public.players merge mohl zapsat hráče bez správného team_id
*/

SELECT
    p.provider,
    p.sport_code,
    p.raw_payload_id,
    COUNT(*) AS staging_players,
    COUNT(tpm.team_id) AS mapped_team_rows,
    COUNT(*) - COUNT(tpm.team_id) AS missing_team_map_rows
FROM staging.stg_provider_players p
LEFT JOIN public.team_provider_map tpm
    ON tpm.provider = p.provider
   AND tpm.provider_team_id = p.external_team_id::text
WHERE p.raw_payload_id IN (743, 745, 746)
GROUP BY p.provider, p.sport_code, p.raw_payload_id
ORDER BY p.raw_payload_id;

SELECT
    provider,
    sport_code,
    raw_payload_id,
    external_team_id,
    team_name,
    COUNT(*) AS players_count
FROM staging.stg_provider_players
WHERE raw_payload_id IN (743, 745, 746)
GROUP BY provider, sport_code, raw_payload_id, external_team_id, team_name
ORDER BY raw_payload_id, players_count DESC;