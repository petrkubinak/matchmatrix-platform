select
  kickoff, match_id,
  ev_home,
  kelly_home,
  (kelly_home * 0.25) as stake_home_quarter_kelly
from ml_value_ev_latest_v1
order by ev_home desc
limit 30;
