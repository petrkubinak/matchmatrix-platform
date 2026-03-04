select kickoff, match_id, p_draw, market_draw, ev_draw, kelly_draw
from ml_value_ev_latest_v1
order by ev_draw desc
limit 30;
