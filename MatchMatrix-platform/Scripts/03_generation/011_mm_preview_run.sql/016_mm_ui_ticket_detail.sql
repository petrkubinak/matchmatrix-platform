-- Tikety (jen seznam)
select ticket_index, probability
from public.generated_tickets
where run_id = 45
order by probability desc;

-- Detail jednoho tiketu (bloky)
select block_index, market_outcome_id
from public.generated_ticket_blocks
where run_id = 45 and ticket_index = 1
order by block_index;

-- FIXED pro run
select match_id, market_outcome_id
from public.generated_ticket_fixed
where run_id = 45
order by match_id;
