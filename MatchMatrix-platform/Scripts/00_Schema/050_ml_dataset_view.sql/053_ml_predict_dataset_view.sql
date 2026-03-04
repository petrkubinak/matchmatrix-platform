CREATE OR REPLACE VIEW ml_match_predict_dataset_v1 AS
SELECT
    m.id AS match_id,
    m.league_id,
    m.kickoff,

    f.home_last5_points,
    f.away_last5_points,
    f.home_last5_gf,
    f.home_last5_ga,
    f.away_last5_gf,
    f.away_last5_ga,
    f.home_rest_days,
    f.away_rest_days,
    f.h2h_last5_goal_diff,

    (f.home_last5_points - f.away_last5_points) AS last5_points_diff,
    ((f.home_last5_gf - f.home_last5_ga) - (f.away_last5_gf - f.away_last5_ga)) AS last5_gd_diff,
    (f.home_rest_days - f.away_rest_days) AS rest_days_diff

FROM matches m
JOIN match_features f ON f.match_id = m.id
WHERE m.status <> 'FINISHED'  -- nebo IN ('SCHEDULED','NOT_STARTED',...)
;
