-- =====================================================================
-- 573_final_backlog_classification.sql
-- Účel:
-- finální klasifikace current public.unmatched_theodds backlogu
-- =====================================================================

WITH u AS (
    SELECT
        provider,
        league_name,
        event_name,
        home_raw,
        away_raw,
        home_normalized,
        away_normalized,
        best_home_candidate,
        best_away_candidate,
        best_home_score,
        best_away_score,
        match_id,
        issue_code
    FROM public.unmatched_theodds
),

classified AS (
    SELECT
        u.*,
        CASE
            WHEN league_name IN ('soccer_spain_la_liga', 'soccer_uefa_champs_league')
                 AND (
                        lower(home_raw) IN ('atlético madrid', 'barcelona')
                     OR lower(away_raw) IN ('atlético madrid', 'barcelona')
                 )
            THEN 'COMPETITION_RISK'

            WHEN league_name = 'soccer_fifa_world_cup'
                 AND event_name = 'Australia vs Jordan'
            THEN 'SOURCE_GAP'

            WHEN league_name = 'soccer_conmebol_copa_libertadores'
                 AND (
                        lower(home_raw) like '%universidad católica%'
                     OR lower(away_raw) like '%universidad católica%'
                 )
            THEN 'TEAM_MAPPING_EDGE'

            WHEN coalesce(best_home_score, 0) >= 0.95
             AND coalesce(best_away_score, 0) >= 0.95
            THEN 'ATTACH_NOW'

            WHEN coalesce(best_home_score, 0) >= 0.80
              OR coalesce(best_away_score, 0) >= 0.80
            THEN 'REVIEW_LINKER'

            ELSE 'SOURCE_GAP'
        END AS final_bucket
    FROM u
)

SELECT
    final_bucket,
    league_name,
    COUNT(*) AS rows_count
FROM classified
GROUP BY final_bucket, league_name
ORDER BY final_bucket, rows_count DESC, league_name;