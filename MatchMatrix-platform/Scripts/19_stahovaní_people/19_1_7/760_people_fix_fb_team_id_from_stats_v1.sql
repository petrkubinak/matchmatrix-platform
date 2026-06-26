/*
760_people_fix_fb_team_id_from_stats_v1.sql

Účel:
- doplní external_team_id pro FB players ze statistics JSON
*/

BEGIN;

UPDATE staging.stg_provider_players p
SET
    external_team_id = (payload_json->'response'->0->'statistics'->0->'team'->>'id'),
    team_name = (payload_json->'response'->0->'statistics'->0->'team'->>'name')
FROM staging.stg_api_payloads r
WHERE p.raw_payload_id = r.id
  AND p.provider = 'api_football'
  AND p.sport_code = 'FB'
  AND p.raw_payload_id = 743
  AND (p.external_team_id IS NULL OR p.external_team_id = '');

COMMIT;

-- kontrola
SELECT
    provider,
    sport_code,
    raw_payload_id,
    external_team_id,
    team_name,
    COUNT(*) AS players_count
FROM staging.stg_provider_players
WHERE raw_payload_id = 743
GROUP BY provider, sport_code, raw_payload_id, external_team_id, team_name;