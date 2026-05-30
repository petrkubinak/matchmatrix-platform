/*
===============================================================================
MATCHMATRIX – UPSERT MISSING PLAYERS FROM FIXTURE RAW V1
===============================================================================

CO TO DĚLÁ
-----------
Doplní chybějící hráče z RAW payloadu fixtures_players do:
- public.players
- public.player_provider_map

K ČEMU TO JE
-------------
Aby bylo možné naplnit:
public.player_match_statistics

ZDROJ
------
staging.stg_api_payloads.id = 1329

POZNÁMKA
---------
Toto je bezpečný minimální bootstrap:
- jméno
- provider id
- fotka
- tým z RAW
- aktivní hráč

Detailní profily se později doplní z /players endpointu.
===============================================================================
*/

WITH raw_players AS (
    SELECT DISTINCT
        player_item->'player'->>'id' AS provider_player_id,
        player_item->'player'->>'name' AS player_name,
        player_item->'player'->>'photo' AS photo_url,
        team_item->'team'->>'id' AS provider_team_id
    FROM staging.stg_api_payloads p
    CROSS JOIN LATERAL jsonb_array_elements(p.payload_json->'response') team_item
    CROSS JOIN LATERAL jsonb_array_elements(team_item->'players') player_item
    WHERE p.id = 1329
),
mapped AS (
    SELECT
        rp.*,
        tpm.team_id
    FROM raw_players rp
    LEFT JOIN public.team_provider_map tpm
        ON tpm.provider = 'api_football'
       AND tpm.provider_team_id = rp.provider_team_id
),
insert_players AS (
    INSERT INTO public.players
    (
        team_id,
        name,
        is_active,
        ext_source,
        ext_player_id,
        photo_url,
        created_at,
        updated_at
    )
    SELECT
        m.team_id,
        m.player_name,
        TRUE,
        'api_football',
        m.provider_player_id,
        m.photo_url,
        NOW(),
        NOW()
    FROM mapped m
    LEFT JOIN public.players p
        ON p.ext_source = 'api_football'
       AND p.ext_player_id = m.provider_player_id
    WHERE p.id IS NULL
    RETURNING
        id,
        ext_player_id,
        name,
        team_id
)
INSERT INTO public.player_provider_map
(
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
    'api_football',
    rp.provider_player_id,
    COALESCE(ip.id, p.id),
    rp.provider_team_id,
    NULL,
    rp.player_name,
    TRUE,
    NOW(),
    NOW()
FROM raw_players rp
LEFT JOIN insert_players ip
    ON ip.ext_player_id = rp.provider_player_id
LEFT JOIN public.players p
    ON p.ext_source = 'api_football'
   AND p.ext_player_id = rp.provider_player_id
LEFT JOIN public.player_provider_map ppm
    ON ppm.provider = 'api_football'
   AND ppm.provider_player_id = rp.provider_player_id
WHERE ppm.id IS NULL;