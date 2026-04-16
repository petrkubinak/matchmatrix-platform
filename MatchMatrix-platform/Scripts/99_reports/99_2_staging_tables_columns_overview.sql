-- ============================================================
-- 711_staging_key_tables_columns_overview.sql
-- MatchMatrix - STAGING key tables columns overview
--
-- Kam ulozit:
-- C:\MatchMatrix-platform\db\audit\711_staging_key_tables_columns_overview.sql
--
-- Jak spustit:
-- DBeaver -> otevrit soubor -> spustit cely script
--
-- Co dela:
-- 1) vypise sloupce, datove typy a poradi pro nejcasteji pouzivane
--    staging tabulky
-- 2) ukaze nullability a defaulty
-- 3) da rychly stabilni prehled, ze ktereho budeme pri dalsi praci vychazet
--
-- Poznamka:
-- Tento script nic nemeni v databazi.
-- Je pouze auditni / introspekcni.
-- ============================================================

-- ------------------------------------------------------------
-- 1) seznam klicovych staging tabulek
--    sem davame hlavne tabulky, se kterymi realne pracujeme
-- ------------------------------------------------------------
WITH key_tables AS (
    SELECT 'stg_provider_teams'::text              AS table_name, 1 AS sort_order
    UNION ALL SELECT 'stg_provider_fixtures',             2
    UNION ALL SELECT 'stg_provider_leagues',              3
    UNION ALL SELECT 'stg_provider_odds',                 4
    UNION ALL SELECT 'stg_provider_players',              5
    UNION ALL SELECT 'stg_provider_player_stats',         6
    UNION ALL SELECT 'stg_provider_player_season_stats',  7
    UNION ALL SELECT 'stg_provider_player_profiles',      8
    UNION ALL SELECT 'stg_provider_team_stats',           9
    UNION ALL SELECT 'stg_provider_coaches',             10
    UNION ALL SELECT 'stg_provider_events',              11
    UNION ALL SELECT 'stg_api_payloads',                 12
    UNION ALL SELECT 'stg_player_source_payloads',       13
    UNION ALL SELECT 'stg_api_american_football_teams',  14
    UNION ALL SELECT 'stg_api_american_football_fixtures', 15
    UNION ALL SELECT 'api_hockey_teams_raw',            16
    UNION ALL SELECT 'api_hockey_leagues_raw',          17
    UNION ALL SELECT 'api_football_teams',              18
    UNION ALL SELECT 'api_football_fixtures',           19
    UNION ALL SELECT 'api_football_leagues',            20
    UNION ALL SELECT 'api_football_odds',               21
    UNION ALL SELECT 'players_import',                  22
    UNION ALL SELECT 'player_provider_map_import',      23
    UNION ALL SELECT 'api_hockey_teams',                24
    UNION ALL SELECT 'api_hockey_leagues',              25
)

-- ------------------------------------------------------------
-- 2) hlavni prehled sloupcu
-- ------------------------------------------------------------
SELECT
    kt.sort_order,
    c.table_schema,
    c.table_name,
    c.ordinal_position,
    c.column_name,
    c.data_type,
    c.udt_name,
    c.is_nullable,
    c.column_default
FROM information_schema.columns c
JOIN key_tables kt
  ON kt.table_name = c.table_name
WHERE c.table_schema = 'staging'
ORDER BY
    kt.sort_order,
    c.table_name,
    c.ordinal_position;

-- ------------------------------------------------------------
-- 3) zkraceny souhrn po tabulkach
--    rychly prehled kolik ma kazda tabulka sloupcu
-- ------------------------------------------------------------
WITH key_tables AS (
    SELECT 'stg_provider_teams'::text              AS table_name, 1 AS sort_order
    UNION ALL SELECT 'stg_provider_fixtures',             2
    UNION ALL SELECT 'stg_provider_leagues',              3
    UNION ALL SELECT 'stg_provider_odds',                 4
    UNION ALL SELECT 'stg_provider_players',              5
    UNION ALL SELECT 'stg_provider_player_stats',         6
    UNION ALL SELECT 'stg_provider_player_season_stats',  7
    UNION ALL SELECT 'stg_provider_player_profiles',      8
    UNION ALL SELECT 'stg_provider_team_stats',           9
    UNION ALL SELECT 'stg_provider_coaches',             10
    UNION ALL SELECT 'stg_provider_events',              11
    UNION ALL SELECT 'stg_api_payloads',                 12
    UNION ALL SELECT 'stg_player_source_payloads',       13
    UNION ALL SELECT 'stg_api_american_football_teams',  14
    UNION ALL SELECT 'stg_api_american_football_fixtures', 15
    UNION ALL SELECT 'api_hockey_teams_raw',            16
    UNION ALL SELECT 'api_hockey_leagues_raw',          17
    UNION ALL SELECT 'api_football_teams',              18
    UNION ALL SELECT 'api_football_fixtures',           19
    UNION ALL SELECT 'api_football_leagues',            20
    UNION ALL SELECT 'api_football_odds',               21
    UNION ALL SELECT 'players_import',                  22
    UNION ALL SELECT 'player_provider_map_import',      23
    UNION ALL SELECT 'api_hockey_teams',                24
    UNION ALL SELECT 'api_hockey_leagues',              25
)
SELECT
    kt.sort_order,
    c.table_name,
    count(*) AS column_count
FROM information_schema.columns c
JOIN key_tables kt
  ON kt.table_name = c.table_name
WHERE c.table_schema = 'staging'
GROUP BY kt.sort_order, c.table_name
ORDER BY kt.sort_order, c.table_name;

-- ------------------------------------------------------------
-- 4) primary key / unique / foreign key prehled
-- ------------------------------------------------------------
WITH key_tables AS (
    SELECT 'stg_provider_teams'::text              AS table_name, 1 AS sort_order
    UNION ALL SELECT 'stg_provider_fixtures',             2
    UNION ALL SELECT 'stg_provider_leagues',              3
    UNION ALL SELECT 'stg_provider_odds',                 4
    UNION ALL SELECT 'stg_provider_players',              5
    UNION ALL SELECT 'stg_provider_player_stats',         6
    UNION ALL SELECT 'stg_provider_player_season_stats',  7
    UNION ALL SELECT 'stg_provider_player_profiles',      8
    UNION ALL SELECT 'stg_provider_team_stats',           9
    UNION ALL SELECT 'stg_provider_coaches',             10
    UNION ALL SELECT 'stg_provider_events',              11
    UNION ALL SELECT 'stg_api_payloads',                 12
    UNION ALL SELECT 'stg_player_source_payloads',       13
    UNION ALL SELECT 'stg_api_american_football_teams',  14
    UNION ALL SELECT 'stg_api_american_football_fixtures', 15
    UNION ALL SELECT 'api_hockey_teams_raw',            16
    UNION ALL SELECT 'api_hockey_leagues_raw',          17
    UNION ALL SELECT 'api_football_teams',              18
    UNION ALL SELECT 'api_football_fixtures',           19
    UNION ALL SELECT 'api_football_leagues',            20
    UNION ALL SELECT 'api_football_odds',               21
    UNION ALL SELECT 'players_import',                  22
    UNION ALL SELECT 'player_provider_map_import',      23
    UNION ALL SELECT 'api_hockey_teams',                24
    UNION ALL SELECT 'api_hockey_leagues',              25
)
SELECT
    kt.sort_order,
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name   AS foreign_table_name,
    ccu.column_name  AS foreign_column_name
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.key_column_usage kcu
       ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
      AND tc.table_name = kcu.table_name
LEFT JOIN information_schema.constraint_column_usage ccu
       ON tc.constraint_name = ccu.constraint_name
      AND tc.table_schema = ccu.table_schema
JOIN key_tables kt
  ON kt.table_name = tc.table_name
WHERE tc.table_schema = 'staging'
  AND tc.constraint_type IN ('PRIMARY KEY', 'UNIQUE', 'FOREIGN KEY')
ORDER BY
    kt.sort_order,
    tc.table_name,
    tc.constraint_type,
    tc.constraint_name,
    kcu.ordinal_position;

-- ------------------------------------------------------------
-- 5) existence check
--    ukaze, ktere z vybranych staging tabulek v databazi skutecne existuji
-- ------------------------------------------------------------
WITH key_tables AS (
    SELECT 'stg_provider_teams'::text              AS table_name, 1 AS sort_order
    UNION ALL SELECT 'stg_provider_fixtures',             2
    UNION ALL SELECT 'stg_provider_leagues',              3
    UNION ALL SELECT 'stg_provider_odds',                 4
    UNION ALL SELECT 'stg_provider_players',              5
    UNION ALL SELECT 'stg_provider_player_stats',         6
    UNION ALL SELECT 'stg_provider_player_season_stats',  7
    UNION ALL SELECT 'stg_provider_player_profiles',      8
    UNION ALL SELECT 'stg_provider_team_stats',           9
    UNION ALL SELECT 'stg_provider_coaches',             10
    UNION ALL SELECT 'stg_provider_events',              11
    UNION ALL SELECT 'stg_api_payloads',                 12
    UNION ALL SELECT 'stg_player_source_payloads',       13
    UNION ALL SELECT 'stg_api_american_football_teams',  14
    UNION ALL SELECT 'stg_api_american_football_fixtures', 15
    UNION ALL SELECT 'api_hockey_teams_raw',            16
    UNION ALL SELECT 'api_hockey_leagues_raw',          17
    UNION ALL SELECT 'api_football_teams',              18
    UNION ALL SELECT 'api_football_fixtures',           19
    UNION ALL SELECT 'api_football_leagues',            20
    UNION ALL SELECT 'api_football_odds',               21
    UNION ALL SELECT 'players_import',                  22
    UNION ALL SELECT 'player_provider_map_import',      23
    UNION ALL SELECT 'api_hockey_teams',                24
    UNION ALL SELECT 'api_hockey_leagues',              25
)
SELECT
    kt.sort_order,
    kt.table_name,
    CASE
        WHEN t.table_name IS NOT NULL THEN 'YES'
        ELSE 'NO'
    END AS table_exists
FROM key_tables kt
LEFT JOIN information_schema.tables t
       ON t.table_schema = 'staging'
      AND t.table_name = kt.table_name
ORDER BY kt.sort_order, kt.table_name;