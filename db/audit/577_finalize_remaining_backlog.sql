-- =====================================================================
-- 577_finalize_remaining_backlog.sql
-- Účel:
-- finální klasifikace zbytku unmatched_theodds po safe attach
-- =====================================================================

SELECT
    league_name,
    event_name,
    home_raw,
    away_raw,
    best_home_candidate,
    best_away_candidate,
    best_home_score,
    best_away_score,
    CASE
        WHEN league_name IN ('soccer_spain_la_liga', 'soccer_uefa_champs_league')
             AND (
                    lower(home_raw) IN ('atlético madrid', 'barcelona', 'sevilla')
                 OR lower(away_raw) IN ('atlético madrid', 'barcelona', 'sevilla')
             )
        THEN 'COMPETITION_RISK'

        WHEN lower(home_raw) = 'barcelona sc'
          OR lower(away_raw) = 'barcelona sc'
        THEN 'FALSE_POSITIVE_RISK'

        WHEN coalesce(best_home_candidate, '') = ''
          OR coalesce(best_away_candidate, '') = ''
        THEN 'MAPPING_GAP'

        WHEN lower(home_raw) LIKE '%universidad católica%'
          OR lower(away_raw) LIKE '%universidad católica%'
        THEN 'MAPPING_EDGE'

        WHEN event_name = 'Australia vs Jordan'
        THEN 'SOURCE_GAP'

        ELSE 'PAIR_MISSING'
    END AS final_bucket
FROM public.unmatched_theodds
WHERE COALESCE(match_id, '') = ''
ORDER BY
    final_bucket,
    league_name,
    event_name;