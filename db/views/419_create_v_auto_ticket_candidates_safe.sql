-- 419_create_v_auto_ticket_candidates_safe.sql
-- Kandidátní view pro SAFE strategie
-- V1 = football TOP/aktivní nabídka s 1X2 odds
-- Rozdělení:
--   candidate_type = FIX_SAFE / BLOCK_SAFE

CREATE OR REPLACE VIEW public.v_auto_ticket_candidates_safe AS
WITH base AS (
    SELECT
        m.id AS match_id,
        m.kickoff,
        m.league_id,
        l.name AS league_name,
        COALESCE(s.code, '?') AS sport_code,
        ht.id AS home_team_id,
        ht.name AS home_team,
        at.id AS away_team_id,
        at.name AS away_team,

        MAX(CASE WHEN mo.code = '1' THEN o.odd_value END) AS odd_1,
        MAX(CASE WHEN mo.code = 'X' THEN o.odd_value END) AS odd_x,
        MAX(CASE WHEN mo.code = '2' THEN o.odd_value END) AS odd_2

    FROM public.matches m
    JOIN public.leagues l
      ON l.id = m.league_id
    LEFT JOIN public.sports s
      ON s.id = COALESCE(m.sport_id, l.sport_id)
    JOIN public.teams ht
      ON ht.id = m.home_team_id
    JOIN public.teams at
      ON at.id = m.away_team_id
    JOIN public.odds o
      ON o.match_id = m.id
    JOIN public.market_outcomes mo
      ON mo.id = o.market_outcome_id
    JOIN public.markets mk
      ON mk.id = mo.market_id
    WHERE COALESCE(s.code, '?') = 'FB'
      AND m.kickoff >= NOW()
      AND m.kickoff < NOW() + INTERVAL '7 days'
      AND lower(mk.code) IN (lower('h2h'), lower('1x2'))
      AND mo.code IN ('1', 'X', '2')
      AND o.odd_value IS NOT NULL
      AND o.odd_value > 0
    GROUP BY
        m.id, m.kickoff, m.league_id, l.name,
        COALESCE(s.code, '?'),
        ht.id, ht.name, at.id, at.name
),
scored AS (
    SELECT
        b.*,

        LEAST(b.odd_1, b.odd_2) AS favorite_odd,
        GREATEST(b.odd_1, b.odd_2) AS outsider_odd,

        ABS(b.odd_1 - b.odd_2) AS home_away_gap,
        ((b.odd_1 + b.odd_2) / 2.0) AS avg_side_odd,

        CASE
            WHEN b.odd_1 <= b.odd_2 THEN '1'
            ELSE '2'
        END AS favorite_pick_code,

        -- čím menší gap a současně vyšší avg_side_odd, tím lepší block kandidát
        ROUND(
            (
                ((b.odd_1 + b.odd_2) / 2.0)
                / NULLIF(ABS(b.odd_1 - b.odd_2) + 0.15, 0)
            )::numeric
        , 6) AS balanced_high_score

    FROM base b
    WHERE b.odd_1 IS NOT NULL
      AND b.odd_x IS NOT NULL
      AND b.odd_2 IS NOT NULL
),
fix_candidates AS (
    SELECT
        'FIX_SAFE'::text AS candidate_type,
        s.match_id,
        s.kickoff,
        s.league_id,
        s.league_name,
        s.sport_code,
        s.home_team_id,
        s.home_team,
        s.away_team_id,
        s.away_team,
        s.odd_1,
        s.odd_x,
        s.odd_2,
        s.favorite_odd,
        s.outsider_odd,
        s.home_away_gap,
        s.avg_side_odd,
        s.favorite_pick_code AS recommended_pick_code,
        s.balanced_high_score,
        CASE
            WHEN s.favorite_odd BETWEEN 1.20 AND 1.50 THEN 'SAFE_01_OR_SAFE_02'
            WHEN s.favorite_odd BETWEEN 1.50 AND 1.80 THEN 'SAFE_03'
            ELSE NULL
        END AS strategy_fit
    FROM scored s
    WHERE
        (s.favorite_odd BETWEEN 1.20 AND 1.50)
        OR
        (s.favorite_odd BETWEEN 1.50 AND 1.80)
),
block_candidates AS (
    SELECT
        'BLOCK_SAFE'::text AS candidate_type,
        s.match_id,
        s.kickoff,
        s.league_id,
        s.league_name,
        s.sport_code,
        s.home_team_id,
        s.home_team,
        s.away_team_id,
        s.away_team,
        s.odd_1,
        s.odd_x,
        s.odd_2,
        s.favorite_odd,
        s.outsider_odd,
        s.home_away_gap,
        s.avg_side_odd,
        NULL::text AS recommended_pick_code,
        s.balanced_high_score,
        'SAFE_01_SAFE_02_SAFE_03'::text AS strategy_fit
    FROM scored s
    WHERE s.home_away_gap <= 0.60
      AND s.avg_side_odd >= 2.10
)
SELECT *
FROM fix_candidates

UNION ALL

SELECT *
FROM block_candidates;