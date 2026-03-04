-- 024_show_ml_view_definitions.sql
-- Ukáže SQL definice view (co přesně počítají)

SELECT 'ml_fair_odds_latest_v1' AS view_name,
       pg_get_viewdef('public.ml_fair_odds_latest_v1'::regclass, true) AS view_sql
UNION ALL
SELECT 'ml_value_ev_latest_v1',
       pg_get_viewdef('public.ml_value_ev_latest_v1'::regclass, true)
UNION ALL
SELECT 'ml_block_candidates_latest_v1',
       pg_get_viewdef('public.ml_block_candidates_latest_v1'::regclass, true);
