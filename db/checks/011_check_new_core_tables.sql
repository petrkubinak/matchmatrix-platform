-- =========================================================
-- Soubor: 011_check_new_core_tables.sql
-- Uložit do: C:\MatchMatrix-platform\db\checks
-- Účel: kontrola existence nových tabulek, indexů a FK vazeb
-- =========================================================

-- ---------------------------------------------------------
-- 1) Kontrola existence tabulek
-- ---------------------------------------------------------
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
      'seasons',
      'players',
      'player_provider_map',
      'lineups',
      'injuries',
      'content_sources',
      'articles',
      'article_team_map',
      'article_league_map',
      'article_match_map'
  )
ORDER BY table_name;

-- ---------------------------------------------------------
-- 2) Kontrola sloupců nových tabulek
-- ---------------------------------------------------------
SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
      'seasons',
      'players',
      'player_provider_map',
      'lineups',
      'injuries',
      'content_sources',
      'articles',
      'article_team_map',
      'article_league_map',
      'article_match_map'
  )
ORDER BY table_name, ordinal_position;

-- ---------------------------------------------------------
-- 3) Kontrola foreign key constraintů
-- ---------------------------------------------------------
SELECT
    tc.table_name,
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
   AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
  AND tc.table_name IN (
      'seasons',
      'players',
      'player_provider_map',
      'lineups',
      'injuries',
      'articles',
      'article_team_map',
      'article_league_map',
      'article_match_map'
  )
ORDER BY tc.table_name, tc.constraint_name;

-- ---------------------------------------------------------
-- 4) Kontrola indexů
-- ---------------------------------------------------------
SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN (
      'seasons',
      'players',
      'player_provider_map',
      'lineups',
      'injuries',
      'content_sources',
      'articles',
      'article_team_map',
      'article_league_map',
      'article_match_map'
  )
ORDER BY tablename, indexname;

-- ---------------------------------------------------------
-- 5) Rychlá kontrola počtu řádků ve všech nových tabulkách
--    (po vytvoření budou většinou 0)
-- ---------------------------------------------------------
SELECT 'public.seasons'               AS table_name, COUNT(*) AS row_count FROM public.seasons
UNION ALL
SELECT 'public.players'               AS table_name, COUNT(*) AS row_count FROM public.players
UNION ALL
SELECT 'public.player_provider_map'   AS table_name, COUNT(*) AS row_count FROM public.player_provider_map
UNION ALL
SELECT 'public.lineups'               AS table_name, COUNT(*) AS row_count FROM public.lineups
UNION ALL
SELECT 'public.injuries'              AS table_name, COUNT(*) AS row_count FROM public.injuries
UNION ALL
SELECT 'public.content_sources'       AS table_name, COUNT(*) AS row_count FROM public.content_sources
UNION ALL
SELECT 'public.articles'              AS table_name, COUNT(*) AS row_count FROM public.articles
UNION ALL
SELECT 'public.article_team_map'      AS table_name, COUNT(*) AS row_count FROM public.article_team_map
UNION ALL
SELECT 'public.article_league_map'    AS table_name, COUNT(*) AS row_count FROM public.article_league_map
UNION ALL
SELECT 'public.article_match_map'     AS table_name, COUNT(*) AS row_count FROM public.article_match_map
ORDER BY table_name;