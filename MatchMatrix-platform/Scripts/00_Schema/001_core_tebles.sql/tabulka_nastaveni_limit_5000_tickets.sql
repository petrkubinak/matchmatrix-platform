create table if not exists mm_settings (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);

-- default limit (uprav si číslo dle potřeby)
insert into mm_settings(key, value)
values ('max_tickets', '5000')
on conflict (key) do nothing;
