select
    match_id,
    home_team,
    away_team,
    odds_2,
    edge_2,
    ev_2,
    away_sync_score,
    home_fragility_score,
    sync_reason_code
from public.vw_block_sync_signals
where sync_outcome = '2'
order by final_sync_score desc
limit 20;

select
    match_id,
    home_team,
    away_team,
    odds_x,
    edge_x,
    ev_x,
    draw_sync_score,
    open_match_score,
    sync_reason_code
from public.vw_block_sync_signals
where sync_outcome = 'X'
order by final_sync_score desc
limit 20;

select
    match_id,
    home_team,
    away_team,
    sync_outcome,
    sync_reason_code,
    final_sync_score,
    home_sync_score,
    draw_sync_score,
    away_sync_score,
    home_fragility_score,
    away_fragility_score,
    open_match_score
from public.vw_block_sync_signals
order by final_sync_score desc
limit 30;