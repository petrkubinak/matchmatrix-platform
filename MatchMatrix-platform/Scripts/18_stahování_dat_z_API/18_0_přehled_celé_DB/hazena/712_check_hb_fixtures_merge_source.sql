-- 712_check_hb_fixtures_merge_source.sql
-- Cíl:
-- Zjistit skutecnou strukturu staging.stg_provider_fixtures
-- a pripravit presny podklad pro HB smoke merge do public.matches.

-- =========================================================
-- 1) Skutecne sloupce staging.stg_provider_fixtures
-- =========================================================
SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'stg_provider_fixtures'
ORDER BY ordinal_position;

-- =========================================================
-- 2) Ukazkove HB fixtures rows
-- =========================================================
SELECT *
FROM staging.stg_provider_fixtures
WHERE provider = 'api_handball'
  AND sport_code = 'handball'
ORDER BY 1 DESC
LIMIT 100;

-- =========================================================
-- 3) Souhrn HB fixtures podle external_league_id / season
-- =========================================================
SELECT
    provider,
    sport_code,
    external_league_id,
    season,
    COUNT(*) AS rows_total
FROM staging.stg_provider_fixtures
WHERE provider = 'api_handball'
  AND sport_code = 'handball'
GROUP BY
    provider,
    sport_code,
    external_league_id,
    season
ORDER BY external_league_id, season;

-- =========================================================
-- 4) Kontrola mapovatelnosti tymu pro league 131 / season 2024
--    (predpoklad: fixtures nesou external home/away team id;
--     tady to uvidime primo z plneho radku v casti 2)
-- =========================================================
SELECT
    tpm.provider,
    COUNT(*) AS mapped_teams
FROM public.team_provider_map tpm
WHERE tpm.provider = 'api_handball'
GROUP BY tpm.provider;

-- =========================================================
-- 5) Existujici HB matches v public.matches
-- =========================================================
SELECT
    id,
    league_id,
    home_team_id,
    away_team_id,
    kickoff,
    ext_source,
    ext_match_id,
    status,
    home_score,
    away_score,
    season,
    sport_id,
    updated_at
FROM public.matches
WHERE ext_source = 'api_handball'
ORDER BY id DESC
LIMIT 100;