insert into public.ticket_block_matches (
    block_id,
    match_id,
    market_id,
    bookmaker_id,
    bookmaker_odds,
    prob_1,
    prob_0,
    prob_2,
    sort_order,
    created_at
)
select
    q.block_id,
    q.match_id,
    q.market_id,
    null::bigint as bookmaker_id,
    null::numeric as bookmaker_odds,
    null::numeric as prob_1,
    null::numeric as prob_0,
    null::numeric as prob_2,
    q.sort_order,
    now()
from (
    select
        tb.id as block_id,
        tbm.match_id,
        tbm.market_id,
        row_number() over (
            partition by tb.id
            order by tbm.match_id
        ) as sort_order
    from public.tickets t
    join public.generated_runs gr
        on t.note = 'generated_run_id=' || gr.id
    join public.ticket_blocks tb
        on tb.ticket_id = t.id
    join public.template_block_matches tbm
        on tbm.template_id = gr.template_id
       and tbm.block_index = tb.sort_order
    where gr.id = 97
) q
left join public.ticket_block_matches x
    on x.block_id = q.block_id
   and x.match_id = q.match_id
where x.id is null
order by q.block_id, q.sort_order;