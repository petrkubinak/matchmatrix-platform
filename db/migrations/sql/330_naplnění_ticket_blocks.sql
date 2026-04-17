insert into public.ticket_blocks (
    ticket_id,
    block_code,
    sort_order,
    created_at
)
select
    t.id as ticket_id,
    case gtb.block_index
        when 1 then 'A'
        when 2 then 'B'
        when 3 then 'C'
    end as block_code,
    gtb.block_index as sort_order,
    now()
from public.tickets t
join (
    select distinct
        run_id,
        block_index
    from public.generated_ticket_blocks
    where run_id = 97
) gtb
    on t.note = 'generated_run_id=' || gtb.run_id
left join public.ticket_blocks tb
    on tb.ticket_id = t.id
   and tb.sort_order = gtb.block_index
where tb.id is null
  and gtb.block_index between 1 and 3
order by gtb.block_index;