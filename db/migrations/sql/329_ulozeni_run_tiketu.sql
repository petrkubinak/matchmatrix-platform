insert into public.tickets (
    ticket_code,
    strategy_code,
    constants_count,
    blocks_count,
    variants_generated,
    source_type,
    status,
    note,
    created_at,
    updated_at
)
select
    'T-' || gr.id || '-' || to_char(now(), 'YYYY-MM-DD') as ticket_code,
    'AUTO_V1',
    0,
    count(distinct gtb.block_index) as blocks_count,
    count(distinct gt.ticket_index) as variants_generated,
    'generated',
    'draft',
    'generated_run_id=' || gr.id,
    now(),
    now()
from public.generated_runs gr
join public.generated_tickets gt
    on gt.run_id = gr.id
left join public.generated_ticket_blocks gtb
    on gtb.run_id = gr.id
where gr.id = 97
group by gr.id;