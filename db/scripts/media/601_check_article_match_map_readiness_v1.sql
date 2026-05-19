-- check_article_match_map_readiness_v1.sql
-- Účel:
-- Ověřit připravenost pro MEDIA article_match_map:
-- 1) existuje/neexistuje public.article_match_map
-- 2) existuje public.articles
-- 3) existuje public.matches
-- 4) ukázat dostupné sloupce pro návrh matcheru

SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
      'articles',
      'article_match_map',
      'matches',
      'teams',
      'leagues'
  )
ORDER BY table_name, ordinal_position;


-- Počty hlavních tabulek
SELECT 'public.articles' AS table_name, COUNT(*) AS row_count FROM public.articles
UNION ALL
SELECT 'public.matches', COUNT(*) FROM public.matches
UNION ALL
SELECT 'public.teams', COUNT(*) FROM public.teams
UNION ALL
SELECT 'public.leagues', COUNT(*) FROM public.leagues;


-- Kontrola, zda article_match_map existuje
SELECT
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'public'
              AND table_name = 'article_match_map'
        )
        THEN 'EXISTS'
        ELSE 'MISSING'
    END AS article_match_map_status;