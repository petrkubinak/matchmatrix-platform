create or replace function public.mm_get_max_tickets()
returns integer
language sql
stable
as $$
  select coalesce(
    nullif(
      (select value from public.mm_settings where "key" = 'max_tickets'),
      ''
    )::int,
    5000
  );
$$;
