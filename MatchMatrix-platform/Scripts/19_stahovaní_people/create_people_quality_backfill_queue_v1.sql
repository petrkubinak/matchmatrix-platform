DROP TABLE IF EXISTS ops.people_quality_backfill_queue;

CREATE TABLE ops.people_quality_backfill_queue AS

SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            CASE
                WHEN league_name = 'Premier League' THEN 1
                WHEN league_name = 'La Liga' THEN 2
                WHEN league_name = 'Serie A' THEN 3
                WHEN league_name = 'Ligue 1' THEN 4
                WHEN league_name = 'Bundesliga' THEN 5
                ELSE 100
            END,
            appearances_coverage_pct ASC
    ) AS priority,

    sport_code,
    league_id,
    league_name,
    season,
    total_rows,
    rows_with_appearances,
    rows_with_rating,
    appearances_coverage_pct,
    rating_coverage_pct,
    'pending'::text AS status,
    NOW() AS created_at

FROM public.v_people_stats_quality_audit
WHERE sport_code = 'FB'
AND season = '2024'
AND (
    appearances_coverage_pct < 80
    OR rating_coverage_pct < 50
)
ORDER BY priority;