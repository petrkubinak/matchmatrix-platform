CREATE OR REPLACE VIEW vw_ticket_candidate_matches AS

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

    v.recommended_pick

FROM mm_value_bets v

WHERE

recommended_pick IS NOT NULL

AND (
    edge_home > 0.05
    OR edge_draw > 0.05
    OR edge_away > 0.05
)

AND (
    odds_home BETWEEN 1.40 AND 3.50
    OR odds_draw BETWEEN 2.50 AND 4.50
    OR odds_away BETWEEN 1.40 AND 3.50
);