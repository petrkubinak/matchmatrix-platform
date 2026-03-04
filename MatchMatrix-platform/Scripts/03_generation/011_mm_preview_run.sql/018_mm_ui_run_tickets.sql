create or replace function public.mm_ui_run_tickets(
  p_run_id bigint
)
returns table (
  run_id bigint,
  ticket_index int,
  bookmaker_id int,
  total_odd numeric,
  items jsonb
)
language plpgsql
as $$
declare
  v_template_id bigint;
  v_bookmaker_id int;
begin
  select gr.template_id, gr.bookmaker_id
    into v_template_id, v_bookmaker_id
  from public.generated_runs gr
  where gr.id = p_run_id;

  if v_template_id is null then
    raise exception 'Run % not found', p_run_id;
  end if;

  return query
  with ticket_matches as (
    select
      gtb.run_id,
      gtb.ticket_index as ti,
      gtb.block_index,
      tbm.match_id
    from public.generated_ticket_blocks gtb
    join public.template_block_matches tbm
      on tbm.template_id = v_template_id
     and tbm.block_index = gtb.block_index
    where gtb.run_id = p_run_id
  ),
  ticket_odds as (
    select
      gtb.run_id,
      gtb.ticket_index as ti,
      tm.block_index,
      tm.match_id,
      gtb.market_outcome_id,
      o.odd_value,
      o.collected_at
    from public.generated_ticket_blocks gtb
    join ticket_matches tm
      on tm.run_id = gtb.run_id
     and tm.ti = gtb.ticket_index
     and tm.block_index = gtb.block_index
    left join public.odds o
      on o.match_id = tm.match_id
     and o.market_outcome_id = gtb.market_outcome_id
     and o.bookmaker_id = v_bookmaker_id
    where gtb.run_id = p_run_id
  ),
  agg as (
    select
      p_run_id as run_id,
      to1.ti as ticket_index,
      v_bookmaker_id as bookmaker_id,
      exp(sum(ln(nullif(to1.odd_value,0))))::numeric as total_odd,
      jsonb_agg(
        jsonb_build_object(
          'block_index', to1.block_index,
          'match_id', to1.match_id,
          'market_outcome_id', to1.market_outcome_id,
          'odd', to1.odd_value
        )
        order by to1.block_index, to1.match_id
      ) as items
    from ticket_odds to1
    group by to1.ti
  )
  select
    a.run_id,
    a.ticket_index,
    a.bookmaker_id,
    a.total_odd,
    a.items
  from agg a
  order by a.ticket_index;

end;
$$;
