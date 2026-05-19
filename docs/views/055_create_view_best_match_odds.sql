CREATE OR REPLACE VIEW public.best_match_odds AS
WITH base AS (
    SELECT
        o.match_id,
        mo.code AS outcome_code,
        MAX(o.odd_value) AS best_odd
    FROM public.odds o
    JOIN public.market_outcomes mo
        ON mo.id = o.market_outcome_id
    JOIN public.markets m
        ON m.id = mo.market_id
    WHERE m.code IN ('1X2', 'h2h')
      AND mo.code IN ('1', 'X', '2')
    GROUP BY
        o.match_id,
        mo.code
)
SELECT
    b.match_id,
    MAX(CASE WHEN b.outcome_code = '1' THEN b.best_odd END) AS odds_home,
    MAX(CASE WHEN b.outcome_code = 'X' THEN b.best_odd END) AS odds_draw,
    MAX(CASE WHEN b.outcome_code = '2' THEN b.best_odd END) AS odds_away
FROM base b
GROUP BY b.match_id;