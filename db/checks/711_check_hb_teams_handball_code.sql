-- 711_check_hb_teams_handball_code.sql
-- Cíl:
-- Ověřit, zda se HB teams ukládají pod sport_code = 'handball'
-- místo sport_code = 'HB'.

-- 1) raw payloady pro api_handball teams bez filtru na HB
SELECT
    id,
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    external_id,
    season,
    fetched_at,
    parse_status,
    parse_message,
    created_at
FROM staging.stg_api_payloads
WHERE provider = 'api_handball'
  AND entity_type = 'teams'
ORDER BY id DESC
LIMIT 100;

-- 2) souhrn raw payloadů podle sport_code
SELECT
    provider,
    sport_code,
    entity_type,
    parse_status,
    COUNT(*) AS rows_total
FROM staging.stg_api_payloads
WHERE provider = 'api_handball'
  AND entity_type = 'teams'
GROUP BY
    provider,
    sport_code,
    entity_type,
    parse_status
ORDER BY sport_code, parse_status;

-- 3) staging teams pro api_handball bez filtru na HB
SELECT
    id,
    provider,
    sport_code,
    external_team_id,
    team_name,
    country_name,
    external_league_id,
    season,
    raw_payload_id,
    is_active,
    created_at,
    updated_at
FROM staging.stg_provider_teams
WHERE provider = 'api_handball'
ORDER BY id DESC
LIMIT 200;

-- 4) souhrn staging teams podle sport_code
SELECT
    provider,
    sport_code,
    external_league_id,
    season,
    COUNT(*) AS rows_total,
    COUNT(DISTINCT external_team_id) AS teams_distinct
FROM staging.stg_provider_teams
WHERE provider = 'api_handball'
GROUP BY
    provider,
    sport_code,
    external_league_id,
    season
ORDER BY sport_code, external_league_id, season;