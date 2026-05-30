/*
===============================================================================
MATCHMATRIX – PEOPLE SEASON STATS GRAIN AUDIT V1
===============================================================================

CO TO DĚLÁ
-----------
Porovná počet raw stat položek proti počtu unikátních hráčských sezonních profilů.

K ČEMU TO JE
-------------
Zjistíme, jestli je rozdíl 105 834 vs 3 121 skutečná chyba,
nebo správný důsledek převodu stat_name/stat_value do jednoho public řádku.
===============================================================================
*/

-- 1. Raw počet stat položek
SELECT
    COUNT(*) AS raw_stat_rows
FROM staging.stg_provider_player_season_stats;


-- 2. Unikátní hráč + liga + sezóna + tým kombinace
SELECT
    COUNT(*) AS unique_player_season_team_rows
FROM (
    SELECT DISTINCT
        provider,
        player_external_id,
        external_league_id,
        season,
        team_external_id
    FROM staging.stg_provider_player_season_stats
) x;


-- 3. Public počet sezonních statistik
SELECT
    COUNT(*) AS public_player_season_statistics_rows
FROM public.player_season_statistics;


-- 4. Počet různých stat_name
SELECT
    stat_name,
    COUNT(*) AS rows_count
FROM staging.stg_provider_player_season_stats
GROUP BY stat_name
ORDER BY rows_count DESC;3414