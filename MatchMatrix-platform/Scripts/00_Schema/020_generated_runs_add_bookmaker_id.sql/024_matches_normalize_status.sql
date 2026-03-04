-- 1) Pokud je skóre vyplněné → musí být FINISHED
update matches
set status = 'FINISHED'
where status is null
  and home_score is not null
  and away_score is not null;

-- 2) Pokud skóre není → je to SCHEDULED
update matches
set status = 'SCHEDULED'
where status is null;

-- 3) Nastavit NOT NULL constraint
alter table matches
  alter column status set not null;

-- 4) Check constraint pro bezpečnost (Postgres nemá IF NOT EXISTS pro constraint)
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'matches_status_chk'
  ) then
    alter table matches
      add constraint matches_status_chk
      check (status in ('SCHEDULED','LIVE','FINISHED','CANCELLED','POSTPONED'));
  end if;
end $$;
