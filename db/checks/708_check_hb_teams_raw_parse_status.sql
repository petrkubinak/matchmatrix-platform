-- 708_check_hb_teams_raw_parse_status.sql
-- Cíl:
-- Ověřit, zda HB teams payloady existují v raw vrstvě
-- a jaký mají parse_status / parse_message.

-- =========================================================
-- 1) HB teams raw payloady
-- =========================================================
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
  AND sport_code = 'HB'
  AND entity_type = 'teams'
ORDER BY id DESC
LIMIT 100;

-- =========================================================
-- 2) Souhrn HB teams raw payloadů podle parse_status
-- =========================================================
SELECT
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    external_id,
    season,
    parse_status,
    COUNT(*) AS rows_total
FROM staging.stg_api_payloads
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity_type = 'teams'
GROUP BY
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    external_id,
    season,
    parse_status
ORDER BY external_id, season, parse_status;

-- =========================================================
-- 3) HB teams ve staging.stg_provider_teams
-- =========================================================
SELECT
    id,
    provider,
    sport_code,
    external_team_id,
    team_name,
    external_league_id,
    season,
    raw_payload_id,
    is_active,
    created_at,
    updated_at
FROM staging.stg_provider_teams
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
ORDER BY id DESC
LIMIT 100;

-- =========================================================
-- 4) Souhrn HB teams ve staging.stg_provider_teams
-- =========================================================
SELECT
    provider,
    sport_code,
    external_league_id,
    season,
    COUNT(*) AS rows_total,
    COUNT(DISTINCT external_team_id) AS teams_distinct
FROM staging.stg_provider_teams
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
GROUP BY
    provider,
    sport_code,
    external_league_id,
    season
ORDER BY external_league_id, season;