-- základní objemy
SELECT 'public.players' AS metric, COUNT(*)::text AS value
FROM public.players

UNION ALL
SELECT 'public.player_provider_map', COUNT(*)::text
FROM public.player_provider_map

UNION ALL
SELECT 'staging.players_import rows', COUNT(*)::text
FROM staging.players_import

UNION ALL
SELECT 'staging.players_import distinct provider players',
       COUNT(DISTINCT provider_code || ':' || provider_player_id)::text
FROM staging.players_import;

-- rozpad podle providera
SELECT
    ext_source,
    COUNT(*) AS cnt
FROM public.players
GROUP BY ext_source
ORDER BY cnt DESC;

-- kolik je staging dat s kontextem
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE provider_league_id IS NOT NULL) AS rows_with_league,
    COUNT(*) FILTER (WHERE provider_team_id IS NOT NULL) AS rows_with_team,
    COUNT(*) FILTER (WHERE season IS NOT NULL) AS rows_with_season
FROM staging.players_import;

-- top ligy ve staging
SELECT
    provider_code,
    provider_league_id,
    season,
    COUNT(DISTINCT provider_player_id) AS distinct_players
FROM staging.players_import
GROUP BY provider_code, provider_league_id, season
ORDER BY distinct_players DESC, provider_code, provider_league_id;