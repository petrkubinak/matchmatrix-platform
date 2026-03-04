alter table matches
  add column if not exists updated_at timestamptz not null default now();

create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_matches_updated_at on matches;

create trigger trg_matches_updated_at
before update on matches
for each row
execute function set_updated_at();
