create or replace function public.mm_ui_run_summary(
  p_run_id bigint,
  p_stake_per_ticket numeric
)
returns table (
  run_id bigint,
  bookmaker_id int,
  tickets_count int,
  stake_per_ticket numeric,
  total_stake numeric,
  max_total_odd numeric,
  min_total_odd numeric,
  avg_total_odd numeric,
  max_possible_win numeric
)
language sql
stable
as $$
  with gr as (
    select r.id as run_id, r.bookmaker_id
    from public.generated_runs r
    where r.id = p_run_id
  ),
  t as (
    select *
    from public.mm_ui_run_tickets(p_run_id)
  )
  select
    gr.run_id,
    gr.bookmaker_id,
    count(*)::int as tickets_count,
    p_stake_per_ticket as stake_per_ticket,
    (count(*)::numeric * p_stake_per_ticket) as total_stake,
    max(t.total_odd) as max_total_odd,
    min(t.total_odd) as min_total_odd,
    avg(t.total_odd) as avg_total_odd,
    (max(t.total_odd) * p_stake_per_ticket) as max_possible_win
  from gr
  join t on t.run_id = gr.run_id
  group by gr.run_id, gr.bookmaker_id;
$$;
