insert into template_block_matches (template_id, block_index, match_id)
select template_id, block_index, match_id
from template_blocks
where block_type = 'VARIABLE'
  and match_id is not null
on conflict (template_id, block_index, match_id) do nothing;

