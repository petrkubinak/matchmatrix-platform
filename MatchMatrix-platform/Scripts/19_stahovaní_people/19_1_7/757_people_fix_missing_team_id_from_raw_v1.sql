/*
757_people_fix_missing_team_id_from_raw_v1.sql

Účel:
- doplní external_team_id u BK/AFB players ze stg_api_payloads.external_id
- external_id má tvar team=139 / team=1
*/

BEGIN;

UPDATE staging.stg_provider_players p
SET
    external_team_id = replace(r.external_id, 'team=', ''),
    team_name = COALESCE(p.team_name, replace(r.external_id, 'team=', 'Team '))
FROM staging.stg_api_payloads r
WHERE p.raw_payload_id = r.id
  AND p.raw_payload_id IN (745, 746)
  AND (p.external_team_id IS NULL OR p.external_team_id = '');

COMMIT;

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