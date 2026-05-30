/*
===============================================================================
MATCHMATRIX – FIXTURE PLAYERS MAPPING CHECK V1
===============================================================================
Ověří, jestli RAW payload 1329 lze napojit na:
- public.matches
- public.teams
- public.players
===============================================================================
*/

-- 1) Match mapping
SELECT
    id AS match_id,
    ext_source,
    ext_match_id,
    league_id,
    home_team_id,
    away_team_id,
    kickoff,
    status
FROM public.matches
WHERE ext_source = 'api_football'
  AND ext_match_id = '1208310';


-- 2) Team mapping
SELECT
    provider,
    provider_team_id,
    team_id
FROM public.team_provider_map
WHERE provider = 'api_football'
  AND provider_team_id IN ('50', '51');


-- 3) Player mapping z RAW payloadu
WITH raw_players AS (
    SELECT DISTINCT
        player_item->'player'->>'id' AS provider_player_id,
        player_item->'player'->>'name' AS player_name
    FROM staging.stg_api_payloads p
    CROSS JOIN LATERAL jsonb_array_elements(p.payload_json->'response') team_item
    CROSS JOIN LATERAL jsonb_array_elements(team_item->'players') player_item
    WHERE p.id = 1329
)
SELECT
    rp.provider_player_id,
    rp.player_name,
    ppm.player_id
FROM raw_players rp
LEFT JOIN public.player_provider_map ppm
    ON ppm.provider = 'api_football'
   AND ppm.provider_player_id = rp.provider_player_id
ORDER BY
    ppm.player_id NULLS FIRST,
    rp.player_name;