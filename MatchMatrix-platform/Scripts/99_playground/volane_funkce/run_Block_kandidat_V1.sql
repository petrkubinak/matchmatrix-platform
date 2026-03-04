SELECT kickoff, match_id, min_odds, balance_score, block_score,
       market_home, market_draw, market_away
FROM ml_block_candidates_latest_v1
WHERE min_odds >= 2.20
  AND balance_score >= 0.88
  AND GREATEST(market_home, market_draw, market_away) <= 5.00
ORDER BY block_score DESC
LIMIT 50;
