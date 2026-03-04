CREATE OR REPLACE VIEW public.ml_match_dataset_v2 AS
SELECT
    m.id AS match_id,
    m.league_id,
    m.kickoff,

    -- form features
    f.home_last5_points,
    f.away_last5_points,
    f.home_last5_gf,
    f.home_last5_ga,
    f.away_last5_gf,
    f.away_last5_ga,
    f.home_rest_days,
    f.away_rest_days,
    f.h2h_last5_goal_diff,

    -- v2 diffs (co už máš)
    (f.home_last5_points - f.away_last5_points) AS last5_points_diff,
    ((f.home_last5_gf - f.home_last5_ga) - (f.away_last5_gf - f.away_last5_ga)) AS last5_gd_diff,
    (f.home_rest_days - f.away_rest_days) AS rest_days_diff,

    -- rating features (baseline)
    mr.home_rating,
    mr.away_rating,
    mr.rating_diff,
    ABS(mr.rating_diff) AS abs_rating_diff,
	ABS(mr.ha_diff) AS abs_ha_diff,

    -- rating v2 (HA + momentum + volatility)
    mr.home_rating_home,
    mr.away_rating_away,
    mr.ha_diff,

    mr.home_momentum,
    mr.away_momentum,
    mr.momentum_diff,

    mr.home_volatility,
    mr.away_volatility,
    mr.volatility_diff,
    mr.volatility_sum,

    -- label
    CASE
        WHEN (m.home_score > m.away_score) THEN 1
        WHEN (m.home_score < m.away_score) THEN -1::integer
        ELSE 0
    END AS result_label

FROM matches m
JOIN match_features f
  ON f.match_id = m.id
JOIN mm_match_ratings mr
  ON mr.match_id = m.id
WHERE m.status = 'FINISHED'::text;
