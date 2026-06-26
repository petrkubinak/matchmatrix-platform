/*
767_merge_afb_players_to_public_v1.sql

Účel:
- merge AFB players ze staging do public.players
- vytvoří player_provider_map
*/

BEGIN;

INSERT INTO public.players (
    name,
    team_id,
    nationality,
    birth_date,
    position,
    ext_source,
    ext_player_id,
    created_at,
    updated_at
)
SELECT
    p.player_name,
    tpm.team_id,
    p.nationality,
    p.birth_date,
    p.position_code,
    p.provider,
    p.external_player_id::text,
    now(),
    now()
FROM staging.stg_provider_players p
JOIN public.team_provider_map tpm
    ON tpm.provider = p.provider
   AND tpm.provider_team_id = p.external_team_id::text
LEFT JOIN public.player_provider_map ppm
    ON ppm.provider = p.provider
   AND ppm.provider_player_id = p.external_player_id::text
WHERE p.raw_payload_id = 746
  AND ppm.player_id IS NULL
  AND p.player_name IS NOT NULL;

INSERT INTO public.player_provider_map (
    provider,
    provider_player_id,
    player_id,
    provider_team_id,
    provider_team_name,
    provider_player_name,
    is_active,
    created_at,
    updated_at
)
SELECT
    p.provider,
    p.external_player_id::text,
    pl.id,
    p.external_team_id::text,
    p.team_name,
    p.player_name,
    true,
    now(),
    now()
FROM staging.stg_provider_players p
JOIN public.players pl
    ON pl.ext_source = p.provider
   AND pl.ext_player_id = p.external_player_id::text
LEFT JOIN public.player_provider_map ppm
    ON ppm.provider = p.provider
   AND ppm.provider_player_id = p.external_player_id::text
WHERE p.raw_payload_id = 746
  AND ppm.player_id IS NULL;

COMMIT;

SELECT
    p.provider,
    p.sport_code,
    p.raw_payload_id,
    COUNT(*) AS staging_players,
    COUNT(ppm.player_id) AS mapped_players
FROM staging.stg_provider_players p
LEFT JOIN public.player_provider_map ppm
    ON ppm.provider = p.provider
   AND ppm.provider_player_id = p.external_player_id::text
WHERE p.raw_payload_id = 746
GROUP BY p.provider, p.sport_code, p.raw_payload_id;