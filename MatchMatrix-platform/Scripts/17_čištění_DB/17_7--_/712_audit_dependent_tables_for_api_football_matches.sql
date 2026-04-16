-- 712_audit_dependent_tables_for_api_football_matches.sql
-- Audit: co všechno visí na matches s ext_source = 'api_football'

WITH api_matches AS (
    SELECT id
    FROM public.matches
    WHERE ext_source = 'api_football'
)
SELECT 'article_match_map' AS table_name, COUNT(*) AS row_count
FROM public.article_match_map
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'generated_ticket_fixed', COUNT(*)
FROM public.generated_ticket_fixed
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'lineups', COUNT(*)
FROM public.lineups
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'match_events', COUNT(*)
FROM public.match_events
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'match_features', COUNT(*)
FROM public.match_features
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'match_officials', COUNT(*)
FROM public.match_officials
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'match_weather', COUNT(*)
FROM public.match_weather
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'ml_predictions', COUNT(*)
FROM public.ml_predictions
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'mm_ticket_scenario_block_matches', COUNT(*)
FROM public.mm_ticket_scenario_block_matches
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'odds', COUNT(*)
FROM public.odds
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'player_match_statistics', COUNT(*)
FROM public.player_match_statistics
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'selection_items', COUNT(*)
FROM public.selection_items
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'team_match_statistics', COUNT(*)
FROM public.team_match_statistics
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'template_block_matches', COUNT(*)
FROM public.template_block_matches
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'template_fixed_picks', COUNT(*)
FROM public.template_fixed_picks
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'ticket_block_matches', COUNT(*)
FROM public.ticket_block_matches
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'ticket_constants', COUNT(*)
FROM public.ticket_constants
WHERE match_id IN (SELECT id FROM api_matches)

UNION ALL
SELECT 'ticket_variant_matches', COUNT(*)
FROM public.ticket_variant_matches
WHERE match_id IN (SELECT id FROM api_matches)

ORDER BY row_count DESC, table_name;