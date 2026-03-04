insert into template_fixed_picks (template_id, match_id, market_outcome_id)
select template_id, match_id, market_outcome_id
from template_blocks
where block_type = 'FIXED'
  and match_id is not null
  and market_outcome_id is not null
on conflict do nothing;
