TRUNCATE TABLE public.mm_value_bets;

WITH latest_predictions AS (
    SELECT *
    FROM (
        SELECT
            p.*,
            ROW_NUMBER() OVER (
                PARTITION BY p.match_id
                ORDER BY p.run_ts DESC, p.id DESC
            ) AS rn
        FROM public.ml_predictions p
    ) x
    WHERE x.rn = 1
)
INSERT INTO public.mm_value_bets (
    match_id,
    league_id,
    match_date,
    home_team,
    away_team,
    model_p_home,
    model_p_draw,
    model_p_away,
    odds_home,
    odds_draw,
    odds_away,
    book_p_home,
    book_p_draw,
    book_p_away,
    edge_home,
    edge_draw,
    edge_away,
    recommended_pick
)
SELECT
    p.match_id,
    m.league_id,
    m.kickoff AS match_date,
    th.name AS home_team,
    ta.name AS away_team,

    p.p_home,
    p.p_draw,
    p.p_away,

    o.odds_home,
    o.odds_draw,
    o.odds_away,

    CASE WHEN o.odds_home > 0 THEN 1.0 / o.odds_home END AS book_p_home,
    CASE WHEN o.odds_draw > 0 THEN 1.0 / o.odds_draw END AS book_p_draw,
    CASE WHEN o.odds_away > 0 THEN 1.0 / o.odds_away END AS book_p_away,

    CASE WHEN o.odds_home > 0 THEN p.p_home - (1.0 / o.odds_home) END AS edge_home,
    CASE WHEN o.odds_draw > 0 THEN p.p_draw - (1.0 / o.odds_draw) END AS edge_draw,
    CASE WHEN o.odds_away > 0 THEN p.p_away - (1.0 / o.odds_away) END AS edge_away,

    CASE
        WHEN COALESCE(p.p_home - (1.0 / NULLIF(o.odds_home, 0)), -999) >= GREATEST(
             COALESCE(p.p_home - (1.0 / NULLIF(o.odds_home, 0)), -999),
             COALESCE(p.p_draw - (1.0 / NULLIF(o.odds_draw, 0)), -999),
             COALESCE(p.p_away - (1.0 / NULLIF(o.odds_away, 0)), -999)
        )
        AND COALESCE(p.p_home - (1.0 / NULLIF(o.odds_home, 0)), -999) > 0.05 THEN '1'

        WHEN COALESCE(p.p_draw - (1.0 / NULLIF(o.odds_draw, 0)), -999) >= GREATEST(
             COALESCE(p.p_home - (1.0 / NULLIF(o.odds_home, 0)), -999),
             COALESCE(p.p_draw - (1.0 / NULLIF(o.odds_draw, 0)), -999),
             COALESCE(p.p_away - (1.0 / NULLIF(o.odds_away, 0)), -999)
        )
        AND COALESCE(p.p_draw - (1.0 / NULLIF(o.odds_draw, 0)), -999) > 0.05 THEN 'X'

        WHEN COALESCE(p.p_away - (1.0 / NULLIF(o.odds_away, 0)), -999) >= GREATEST(
             COALESCE(p.p_home - (1.0 / NULLIF(o.odds_home, 0)), -999),
             COALESCE(p.p_draw - (1.0 / NULLIF(o.odds_draw, 0)), -999),
             COALESCE(p.p_away - (1.0 / NULLIF(o.odds_away, 0)), -999)
        )
        AND COALESCE(p.p_away - (1.0 / NULLIF(o.odds_away, 0)), -999) > 0.05 THEN '2'

        ELSE NULL
    END AS recommended_pick

FROM latest_predictions p
JOIN public.matches m
    ON m.id = p.match_id
LEFT JOIN public.teams th
    ON th.id = m.home_team_id
LEFT JOIN public.teams ta
    ON ta.id = m.away_team_id
LEFT JOIN public.best_match_odds o
    ON o.match_id = p.match_id;