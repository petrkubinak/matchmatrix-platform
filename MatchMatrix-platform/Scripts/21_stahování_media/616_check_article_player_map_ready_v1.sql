-- check_article_player_map_ready_v1.sql

SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
      'article_player_map',
      'players',
      'player_provider_map'
  )
ORDER BY table_name, ordinal_position;


SELECT
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'public'
              AND table_name = 'article_player_map'
        )
        THEN 'EXISTS'
        ELSE 'MISSING'
    END AS article_player_map_status;


SELECT
    COUNT(*) AS players_count
FROM public.players;


SELECT
    COUNT(*) AS player_provider_map_count
FROM public.player_provider_map;