CREATE OR REPLACE VIEW public.vw_match_feed_for_user AS
SELECT
    v.match_id,
    v.league_id,
    v.match_date,
    v.home_team,
    v.away_team,

    v.model_p_home,
    v.model_p_draw,
    v.model_p_away,

    v.odds_home,
    v.odds_draw,
    v.odds_away,

    v.edge_home,
    v.edge_draw,
    v.edge_away,

    v.recommended_pick,

    GREATEST(
        COALESCE(v.edge_home, -999),
        COALESCE(v.edge_draw, -999),
        COALESCE(v.edge_away, -999)
    ) AS best_edge

FROM public.mm_value_bets v;