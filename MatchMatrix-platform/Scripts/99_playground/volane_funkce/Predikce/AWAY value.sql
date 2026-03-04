select kickoff, match_id, p_away, market_away, ev_away, kelly_away
from ml_value_ev_latest_v1
order by ev_away desc
limit 30;
