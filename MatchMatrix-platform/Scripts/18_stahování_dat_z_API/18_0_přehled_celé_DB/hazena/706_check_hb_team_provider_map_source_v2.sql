-- 706_check_hb_team_provider_map_source_v2.sql
-- Cíl:
-- Nejdriv zjistit skutecnou strukturu staging.stg_provider_teams
-- a pak bezpecne vypsat HB rows bez predpokladu neexistujicich sloupcu.

-- =========================================================
-- 1) Skutecne sloupce staging.stg_provider_teams
-- =========================================================
SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'stg_provider_teams'
ORDER BY ordinal_position;

-- =========================================================
-- 2) Ukazkove HB rows ze stagingu
--    (bez vazby na provider_league_id)
-- =========================================================
SELECT *
FROM staging.stg_provider_teams
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
ORDER BY 1
LIMIT 100;

-- =========================================================
-- 3) Souhrn HB rows podle provider/sport/season
--    Pouzijeme jen sloupce, ktere s vysokou pravdepodobnosti existuji.
-- =========================================================
SELECT
    provider,
    sport_code,
    season,
    COUNT(*) AS rows_total
FROM staging.stg_provider_teams
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
GROUP BY provider, sport_code, season
ORDER BY season;

-- =========================================================
-- 4) Co uz existuje v public.team_provider_map pro api_handball
-- =========================================================
SELECT
    tpm.team_id,
    t.name AS team_name,
    tpm.provider,
    tpm.provider_team_id,
    tpm.created_at,
    tpm.updated_at
FROM public.team_provider_map tpm
JOIN public.teams t
  ON t.id = tpm.team_id
WHERE tpm.provider = 'api_handball'
ORDER BY tpm.provider_team_id
LIMIT 200;

-- =========================================================
-- 5) Co uz existuje v public.teams pod api_handball
-- =========================================================
SELECT
    id,
    name,
    ext_source,
    ext_team_id,
    created_at,
    updated_at
FROM public.teams
WHERE ext_source = 'api_handball'
ORDER BY ext_team_id
LIMIT 200;