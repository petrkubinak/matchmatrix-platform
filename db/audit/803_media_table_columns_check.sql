-- 803_media_table_columns_check.sql
-- MATCHMATRIX MEDIA LAYER – TABLE COLUMNS DETAIL

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema IN ('public', 'staging')
  AND table_name IN (
      'content_sources',
      'articles',
      'article_match_map',
      'article_team_map',
      'article_league_map',
      'article_translations',
      'stg_media_articles'
  )
ORDER BY table_schema, table_name, ordinal_position;