-- MatchMatrix
-- Soubor ulož do: C:\MatchMatrix-platform\db\ad_hoc\sql_players_pipeline_audit_queries.sql
-- Účel: rychlý audit players pipeline po nasazení změn

-- 1) Hlavní počty
SELECT 'staging.players_import' AS table_name, COUNT(*) AS row_count FROM staging.players_import
UNION ALL
SELECT 'staging.stg_provider_players', COUNT(*) FROM staging.stg_provider_players
UNION ALL
SELECT 'public.players', COUNT(*) FROM public.players
UNION ALL
SELECT 'public.player_provider_map', COUNT(*) FROM public.player_provider_map
ORDER BY table_name;

-- 2) Pokrytí nových atributů ve source importu
SELECT
    COUNT(*) AS total_rows,
    COUNT(first_name) AS first_name_rows,
    COUNT(last_name) AS last_name_rows,
    COUNT(position_code) AS position_code_rows,
    COUNT(height_cm) AS height_rows,
    COUNT(weight_kg) AS weight_rows,
    COUNT(preferred_foot) AS preferred_foot_rows,
    COUNT(provider_league_id) AS provider_league_id_rows,
    COUNT(team_name) AS team_name_rows,
    COUNT(league_name) AS league_name_rows,
    COUNT(source_endpoint) AS source_endpoint_rows
FROM staging.players_import;

-- 3) Pokrytí nových atributů v unified staging
SELECT
    COUNT(*) AS total_rows,
    COUNT(first_name) AS first_name_rows,
    COUNT(last_name) AS last_name_rows,
    COUNT(position_code) AS position_code_rows,
    COUNT(height_cm) AS height_rows,
    COUNT(weight_kg) AS weight_rows,
    COUNT(preferred_foot) AS preferred_foot_rows,
    COUNT(external_league_id) AS external_league_id_rows,
    COUNT(team_name) AS team_name_rows,
    COUNT(league_name) AS league_name_rows,
    COUNT(source_endpoint) AS source_endpoint_rows
FROM staging.stg_provider_players;

-- 4) Duplicitní source hráči
SELECT
    provider_code,
    provider_player_id,
    COUNT(*) AS cnt
FROM staging.players_import
GROUP BY provider_code, provider_player_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC, provider_code, provider_player_id
LIMIT 50;

-- 5) Ligy a sezóny s největším počtem hráčů
SELECT
    provider_code,
    provider_league_id,
    season,
    COUNT(*) AS cnt
FROM staging.players_import
GROUP BY provider_code, provider_league_id, season
ORDER BY cnt DESC
LIMIT 50;
