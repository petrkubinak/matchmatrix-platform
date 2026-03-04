select kickoff, match_id, p_home, market_home, ev_home, kelly_home
from ml_value_ev_latest_v1
order by ev_home desc
limit 30;
