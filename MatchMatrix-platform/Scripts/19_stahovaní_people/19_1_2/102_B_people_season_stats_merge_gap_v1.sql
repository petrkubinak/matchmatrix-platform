/*
===============================================================================
MATCHMATRIX – PEOPLE SEASON STATS MERGE GAP AUDIT V1 - FIXED
===============================================================================

Opraveno podle skutečných sloupců:
staging.stg_provider_player_season_stats

player_external_id
team_external_id
external_league_id
===============================================================================
*/

-- 1. ZÁKLADNÍ COUNTS
SELECT
    'staging.stg_provider_player_season_stats' AS source,
    COUNT(*) AS rows_count
FROM staging.stg_provider_player_season_stats

UNION ALL

SELECT
    'public.player_season_statistics',
    COUNT(*)
FROM public.player_season_statistics;


-- 2. DISTINCT PROVIDERS VE STAGING
SELECT
    provider,
    sport_code,
    COUNT(*) AS rows_count
FROM staging.stg_provider_player_season_stats
GROUP BY provider, sport_code
ORDER BY rows_count DESC;


-- 3. DISTINCT PLAYER IDs VE STAGING
SELECT
    provider,
    COUNT(DISTINCT player_external_id) AS distinct_provider_players
FROM staging.stg_provider_player_season_stats
GROUP BY provider
ORDER BY distinct_provider_players DESC;


-- 4. PLAYER MAPPING COVERAGE
SELECT
    s.provider,
    COUNT(*) AS staging_rows,
    COUNT(ppm.player_id) AS mapped_rows,
    COUNT(*) - COUNT(ppm.player_id) AS unmapped_rows
FROM staging.stg_provider_player_season_stats s
LEFT JOIN public.player_provider_map ppm
    ON ppm.provider = s.provider
   AND ppm.provider_player_id = s.player_external_id
GROUP BY s.provider
ORDER BY unmapped_rows DESC;


-- 5. LEAGUE COVERAGE
SELECT
    s.provider,
    s.external_league_id,
    s.season,
    COUNT(*) AS rows_count
FROM staging.stg_provider_player_season_stats s
GROUP BY
    s.provider,
    s.external_league_id,
    s.season
ORDER BY rows_count DESC
LIMIT 50;


-- 6. SAMPLE UNMAPPED PLAYERS
SELECT
    s.provider,
    s.player_external_id,
    s.team_external_id,
    s.external_league_id,
    s.season,
    s.stat_name,
    s.stat_value
FROM staging.stg_provider_player_season_stats s
LEFT JOIN public.player_provider_map ppm
    ON ppm.provider = s.provider
   AND ppm.provider_player_id = s.player_external_id
WHERE ppm.player_id IS NULL
LIMIT 100;