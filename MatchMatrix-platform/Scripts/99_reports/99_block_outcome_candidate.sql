select
    match_id,
    home_team,
    away_team,
    odds_1,
    odds_x,
    odds_2,
    block_score_1,
    block_score_x,
    block_score_2,
    best_block_outcome
from public.vw_block_outcome_candidates
order by greatest(block_score_1, block_score_x, block_score_2) desc
limit 30;