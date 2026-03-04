create or replace function public.mm_ui_run_tickets_with_stake(
  p_run_id bigint,
  p_stake_per_ticket numeric
)
returns table (
  run_id bigint,
  ticket_index int,
  bookmaker_id int,
  total_odd numeric,
  possible_win numeric,
  items jsonb
)
language sql
stable
as $$
  select
    t.run_id,
    t.ticket_index,
    t.bookmaker_id,
    t.total_odd,
    round(t.total_odd * p_stake_per_ticket, 2) as possible_win,
    t.items
  from public.mm_ui_run_tickets(p_run_id) t
  order by t.ticket_index;
$$;
