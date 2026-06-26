/*
764_people_enrich_existing_fb_players_from_raw743_v1.sql

Účel:
- FB hráči z RAW 743 už existují ve staging jako sport_code='football'
- doplní jim team/league/season/raw_payload_id/source_endpoint z RAW 743
*/

BEGIN;

WITH raw_players AS (
    SELECT
        x.value->'player'->>'id' AS external_player_id,
        x.value->'statistics'->0->'team'->>'id' AS external_team_id,
        x.value->'statistics'->0->'team'->>'name' AS team_name,
        x.value->'statistics'->0->'league'->>'id' AS external_league_id,
        x.value->'statistics'->0->'league'->>'name' AS league_name,
        x.value->'statistics'->0->'league'->>'season' AS season,
        x.value->'statistics'->0->'games'->>'position' AS position_code
    FROM staging.stg_api_payloads r
    CROSS JOIN LATERAL jsonb_array_elements(r.payload_json->'response') AS x(value)
    WHERE r.id = 743
)
UPDATE staging.stg_provider_players p
SET
    sport_code = 'FB',
    external_team_id = rp.external_team_id,
    team_name = rp.team_name,
    external_league_id = rp.external_league_id,
    league_name = rp.league_name,
    season = rp.season,
    position_code = rp.position_code,
    raw_payload_id = 743,
    source_endpoint = 'players'
FROM raw_players rp
WHERE p.provider = 'api_football'
  AND p.external_player_id::text = rp.external_player_id::text;

COMMIT;

SELECT
    provider,
    sport_code,
    raw_payload_id,
    external_team_id,
    team_name,
    external_league_id,
    league_name,
    season,
    COUNT(*) AS rows_count
FROM staging.stg_provider_players
WHERE raw_payload_id = 743
GROUP BY
    provider,
    sport_code,
    raw_payload_id,
    external_team_id,
    team_name,
    external_league_id,
    league_name,
    season;