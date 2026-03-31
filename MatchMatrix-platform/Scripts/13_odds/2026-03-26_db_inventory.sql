-- MatchMatrix - DB INVENTURA
-- Spouštět v DBeaveru
-- Cíl: rychle zjistit, co už v public schématu existuje a kolik v tom je dat

-- =========================================================
-- 1) Přehled všech tabulek v public
-- =========================================================
SELECT
    t.table_name
FROM information_schema.tables t
WHERE t.table_schema = 'public'
  AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name;

-- =========================================================
-- 2) Přehled vybraných klíčových tabulek + odhad počtu řádků
-- =========================================================
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    c.reltuples::bigint AS estimated_rows
FROM pg_class c
JOIN pg_namespace n
  ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND c.relname IN (
      'sports',
      'leagues',
      'teams',
      'team_aliases',
      'team_provider_map',
      'league_provider_map',
      'matches',
      'bookmakers',
      'markets',
      'market_outcomes',
      'odds',
      'players',
      'player_provider_map',
      'templates',
      'template_blocks',
      'template_block_matches',
      'template_fixed_picks',
      'generated_runs',
      'generated_tickets',
      'generated_ticket_blocks',
      'ml_predictions',
      'mm_match_ratings',
      'mm_team_ratings'
  )
ORDER BY table_name;

-- =========================================================
-- 3) Přesné počty pro nejdůležitější tabulky
-- =========================================================
SELECT 'sports' AS table_name, COUNT(*) AS row_count FROM public.sports
UNION ALL
SELECT 'leagues', COUNT(*) FROM public.leagues
UNION ALL
SELECT 'teams', COUNT(*) FROM public.teams
UNION ALL
SELECT 'team_aliases', COUNT(*) FROM public.team_aliases
UNION ALL
SELECT 'team_provider_map', COUNT(*) FROM public.team_provider_map
UNION ALL
SELECT 'league_provider_map', COUNT(*) FROM public.league_provider_map
UNION ALL
SELECT 'matches', COUNT(*) FROM public.matches
UNION ALL
SELECT 'bookmakers', COUNT(*) FROM public.bookmakers
UNION ALL
SELECT 'markets', COUNT(*) FROM public.markets
UNION ALL
SELECT 'market_outcomes', COUNT(*) FROM public.market_outcomes
UNION ALL
SELECT 'odds', COUNT(*) FROM public.odds
UNION ALL
SELECT 'players', COUNT(*) FROM public.players
UNION ALL
SELECT 'player_provider_map', COUNT(*) FROM public.player_provider_map
UNION ALL
SELECT 'templates', COUNT(*) FROM public.templates
UNION ALL
SELECT 'template_blocks', COUNT(*) FROM public.template_blocks
UNION ALL
SELECT 'template_block_matches', COUNT(*) FROM public.template_block_matches
UNION ALL
SELECT 'template_fixed_picks', COUNT(*) FROM public.template_fixed_picks
UNION ALL
SELECT 'generated_runs', COUNT(*) FROM public.generated_runs
UNION ALL
SELECT 'generated_tickets', COUNT(*) FROM public.generated_tickets
UNION ALL
SELECT 'generated_ticket_blocks', COUNT(*) FROM public.generated_ticket_blocks
UNION ALL
SELECT 'ml_predictions', COUNT(*) FROM public.ml_predictions
UNION ALL
SELECT 'mm_match_ratings', COUNT(*) FROM public.mm_match_ratings
UNION ALL
SELECT 'mm_team_ratings', COUNT(*) FROM public.mm_team_ratings
ORDER BY table_name;

-- =========================================================
-- 4) Detail alias vrstvy
-- =========================================================
SELECT
    ta.team_id,
    t.name AS team_name,
    ta.alias,
    ta.source
FROM public.team_aliases ta
JOIN public.teams t
  ON t.id = ta.team_id
ORDER BY t.name, ta.alias
LIMIT 200;

-- =========================================================
-- 5) Detail provider map vrstvy
-- =========================================================
SELECT
    tpm.team_id,
    t.name AS team_name,
    tpm.provider,
    tpm.provider_team_id
FROM public.team_provider_map tpm
JOIN public.teams t
  ON t.id = tpm.team_id
ORDER BY tpm.provider, t.name
LIMIT 200;

-- =========================================================
-- 6) Ticket Engine vrstva
-- =========================================================
SELECT
    'templates' AS section,
    id,
    name
FROM public.templates
ORDER BY id;

SELECT
    template_id,
    block_index,
    block_type
FROM public.template_blocks
ORDER BY template_id, block_index;

SELECT
    template_id,
    block_index,
    match_id,
    market_id
FROM public.template_block_matches
ORDER BY template_id, block_index, match_id
LIMIT 200;

SELECT
    template_id,
    match_id,
    market_outcome_id
FROM public.template_fixed_picks
ORDER BY template_id, match_id
LIMIT 200;