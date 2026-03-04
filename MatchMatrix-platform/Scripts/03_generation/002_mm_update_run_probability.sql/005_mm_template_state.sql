-- Stav šablony pro UI (bloky + zápasy + fixed)
select
  tb.template_id,
  tb.block_index,
  tb.block_type,
  count(tbm.match_id) as matches_in_block
from template_blocks tb
left join template_block_matches tbm
  on tbm.template_id = tb.template_id
 and tbm.block_index = tb.block_index
where tb.template_id = 1   -- <<< změň template_id
group by tb.template_id, tb.block_index, tb.block_type
order by tb.block_index;

select
  tfp.template_id,
  tfp.match_id,
  tfp.market_outcome_id
from template_fixed_picks tfp
where tfp.template_id = 1  -- <<< změň template_id
order by tfp.match_id;
