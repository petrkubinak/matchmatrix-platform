alter table public.generated_runs
  add column if not exists max_tickets int,
  add column if not exists min_probability numeric,
  add column if not exists max_combinations bigint;

-- default guardrail (můžeš změnit)
update public.generated_runs
set max_combinations = coalesce(max_combinations, 200000)
where max_combinations is null;
