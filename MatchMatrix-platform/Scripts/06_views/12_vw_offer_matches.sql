DROP VIEW IF EXISTS public.vw_offer_matches;

CREATE VIEW public.vw_offer_matches AS
WITH best_odds AS (
    SELECT
        o.match_id,
        mo.code AS outcome_code,
        MAX(o.odd_value) AS best_odd
    FROM public.odds o
    JOIN public.market_outcomes mo
      ON mo.id = o.market_outcome_id
    JOIN public.markets m
      ON m.id = mo.market_id
    WHERE lower(m.code) IN ('h2h', '1x2')
    GROUP BY o.match_id, mo.code
),
best_odds_pivot AS (
    SELECT
        bo.match_id,
        MAX(CASE WHEN bo.outcome_code = '1' THEN bo.best_odd END) AS odd_1,
        MAX(CASE WHEN bo.outcome_code IN ('X', '0') THEN bo.best_odd END) AS odd_x,
        MAX(CASE WHEN bo.outcome_code = '2' THEN bo.best_odd END) AS odd_2
    FROM best_odds bo
    GROUP BY bo.match_id
),
latest_pred_run AS (
    SELECT MAX(run_ts) AS run_ts
    FROM public.ml_predictions
),
pred_latest AS (
    SELECT
        mp.match_id,
        mp.p_home,
        mp.p_draw,
        mp.p_away
    FROM public.ml_predictions mp
    JOIN latest_pred_run lpr
      ON lpr.run_ts = mp.run_ts
),
offer_base AS (
    SELECT
        m.id AS match_id,
        m.kickoff,
        l.id AS league_id,
        l.name AS league_name,
        th.name AS home_team,
        ta.name AS away_team,
        bop.odd_1,
        bop.odd_x,
        bop.odd_2,
        pl.p_home,
        pl.p_draw,
        pl.p_away,
        CASE WHEN pl.match_id IS NOT NULL THEN 1 ELSE 0 END AS has_prediction,
        m.status
    FROM public.matches m
    JOIN public.leagues l
      ON l.id = m.league_id
    LEFT JOIN public.teams th
      ON th.id = m.home_team_id
    LEFT JOIN public.teams ta
      ON ta.id = m.away_team_id
    LEFT JOIN best_odds_pivot bop
      ON bop.match_id = m.id
    LEFT JOIN pred_latest pl
      ON pl.match_id = m.id
    WHERE m.kickoff >= now()
      AND m.status = 'SCHEDULED'
      AND bop.odd_1 IS NOT NULL
      AND bop.odd_2 IS NOT NULL
)
SELECT
    ob.*,
    CASE
        WHEN ob.has_prediction = 0 THEN NULL
        WHEN ob.p_home >= ob.p_draw AND ob.p_home >= ob.p_away THEN '1'
        WHEN ob.p_draw >= ob.p_home AND ob.p_draw >= ob.p_away THEN 'X'
        ELSE '2'
    END AS main_pick
FROM offer_base ob
ORDER BY ob.kickoff, ob.league_name, ob.home_team, ob.away_team;