create table if not exists public.generated_ticket_risk (
  run_id bigint not null,
  ticket_id bigint not null,
  rule_code text not null,
  details jsonb null,
  created_at timestamptz not null default now(),
  primary key (run_id, ticket_id, rule_code)
);

