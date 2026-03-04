-- 03_generation/002_mm_update_run_probability.sql

create or replace function mm_update_run_probability(p_run_id bigint)
returns void
language sql
as $$
  update generated_runs gr
     set run_probability = coalesce((
       select sum(gt.probability)
       from generated_tickets gt
       where gt.run_id = p_run_id
     ), 0)
   where gr.id = p_run_id;
$$;
