CREATE OR REPLACE VIEW public.vw_ticket_candidate_matches AS
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
FROM public.mm_value_bets v
WHERE v.recommended_pick IS NOT NULL
  AND v.odds_home IS NOT NULL
  AND v.odds_draw IS NOT NULL
  AND v.odds_away IS NOT NULL
  AND (
      v.edge_home > 0.05
      OR v.edge_draw > 0.05
      OR v.edge_away > 0.05
  )
  AND (
      (v.recommended_pick = '1' AND v.odds_home BETWEEN 1.40 AND 3.50)
      OR
      (v.recommended_pick = 'X' AND v.odds_draw BETWEEN 2.50 AND 4.50)
      OR
      (v.recommended_pick = '2' AND v.odds_away BETWEEN 1.40 AND 3.50)
  );