alter table public.generated_tickets
add column if not exists is_blocked boolean not null default false;
