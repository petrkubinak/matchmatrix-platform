select kickoff, match_id, p_home, market_home, market_draw, market_away
from ml_market_odds_latest_v1
order by kickoff
limit 30;
