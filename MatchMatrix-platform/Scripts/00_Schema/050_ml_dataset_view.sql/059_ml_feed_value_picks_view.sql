CREATE OR REPLACE VIEW ml_feed_value_picks_latest_v1 AS
WITH v AS (
    SELECT *
    FROM ml_value_ev_latest_v1
),

-- rozbalíme outcomes do řádků
expanded AS (
    SELECT kickoff, match_id,
           'HOME' AS outcome,
           p_home AS p,
           market_home AS odds,
           ev_home AS ev,
           kelly_home AS kelly
    FROM v

    UNION ALL

    SELECT kickoff, match_id,
           'DRAW',
           p_draw,
           market_draw,
           ev_draw,
           kelly_draw
    FROM v

    UNION ALL

    SELECT kickoff, match_id,
           'AWAY',
           p_away,
           market_away,
           ev_away,
           kelly_away
    FROM v
),

ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY match_id ORDER BY ev DESC) AS rnk
    FROM expanded
)

SELECT
    kickoff,
    match_id,

    -- hlavní tip
    MAX(CASE WHEN rnk = 1 THEN outcome END) AS main_outcome,
    MAX(CASE WHEN rnk = 1 THEN odds END) AS main_odds,
    MAX(CASE WHEN rnk = 1 THEN p END) AS main_probability,
    MAX(CASE WHEN rnk = 1 THEN ev END) AS main_ev,
    MAX(CASE WHEN rnk = 1 THEN kelly END) AS main_kelly,

    -- alternativa 1
    MAX(CASE WHEN rnk = 2 THEN outcome END) AS alt1_outcome,
    MAX(CASE WHEN rnk = 2 THEN odds END) AS alt1_odds,
    MAX(CASE WHEN rnk = 2 THEN ev END) AS alt1_ev,

    -- alternativa 2
    MAX(CASE WHEN rnk = 3 THEN outcome END) AS alt2_outcome,
    MAX(CASE WHEN rnk = 3 THEN odds END) AS alt2_odds,
    MAX(CASE WHEN rnk = 3 THEN ev END) AS alt2_ev

FROM ranked
GROUP BY kickoff, match_id;
