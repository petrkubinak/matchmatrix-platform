create table if not exists public.generated_ticket_blocks (
  run_id bigint not null references public.generated_runs(id) on delete cascade,
  ticket_index int not null,
  block_index int not null,
  market_outcome_id bigint not null,
  primary key (run_id, ticket_index, block_index)
);

create table if not exists public.generated_ticket_fixed (
  run_id bigint not null references public.generated_runs(id) on delete cascade,
  match_id int not null references public.matches(id),
  market_outcome_id bigint not null,
  primary key (run_id, match_id, market_outcome_id)
);

create index if not exists ix_gtb_run_ticket
  on public.generated_ticket_blocks(run_id, ticket_index);

create index if not exists ix_gtf_run
  on public.generated_ticket_fixed(run_id);
