alter table public.generated_runs
add column if not exists bookmaker_id int references public.bookmakers(id);
