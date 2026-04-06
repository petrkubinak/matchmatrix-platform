-- =====================================================================
-- 572_remaining_unmatched_after_cleanup.sql
-- Účel:
-- ukázat skutečný aktuální zbytek v public.unmatched_theodds
-- po všech dosavadních cleanech
-- =====================================================================
SELECT
    provider,
    league_name,
    event_name,
    home_raw,
    away_raw,
    issue_code,
    match_id
FROM public.unmatched_theodds
ORDER BY provider, league_name, event_name;