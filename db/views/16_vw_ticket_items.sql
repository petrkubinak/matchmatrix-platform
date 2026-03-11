-- =====================================================
-- VIEW: vw_ticket_items
-- Rozpad tiketů na jednotlivé zápasy
-- =====================================================

create or replace view public.vw_ticket_items as
select
    gt.run_id,
    gt.ticket_index,
    gtb.block_index,
    tbm.match_id,
    m.league_id,
    m.home_team_id,
    m.away_team_id,
    mo.code as outcome_code,
    o.odd_value
from generated_tickets gt
join generated_ticket_blocks gtb
    on gtb.run_id = gt.run_id
    and gtb.ticket_index = gt.ticket_index

join template_block_matches tbm
    on tbm.template_id = (
        select template_id
        from generated_runs
        where id = gt.run_id
    )
    and tbm.block_index = gtb.block_index

join matches m
    on m.id = tbm.match_id

join market_outcomes mo
    on mo.id = gtb.market_outcome_id

left join odds o
    on o.match_id = tbm.match_id
    and o.market_outcome_id = gtb.market_outcome_id;