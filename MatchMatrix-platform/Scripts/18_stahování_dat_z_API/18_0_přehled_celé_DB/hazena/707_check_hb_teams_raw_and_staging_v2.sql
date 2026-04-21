-- 707_check_hb_teams_raw_and_staging_v2.sql
-- Cíl:
-- 1) zjistit skutecnou strukturu staging.stg_api_payloads
-- 2) bezpecne vypsat HB teams raw payloady
-- 3) porovnat je se staging.stg_provider_teams

-- =========================================================
-- 1) Skutecne sloupce staging.stg_api_payloads
-- =========================================================
SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'stg_api_payloads'
ORDER BY ordinal_position;

-- =========================================================
-- 2) Ukazkove radky ze staging.stg_api_payloads pro HB
--    (bez predpokladu entity_id)
-- =========================================================
SELECT *
FROM staging.stg_api_payloads
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
ORDER BY 1 DESC
LIMIT 100;

-- =========================================================
-- 3) Ukazkove radky ze staging.stg_provider_teams pro HB
-- =========================================================
SELECT *
FROM staging.stg_provider_teams
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
ORDER BY id DESC
LIMIT 100;

-- =========================================================
-- 4) Souhrn HB team rows ve staging.stg_provider_teams
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