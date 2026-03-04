do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'matches_score_status_chk'
  ) then
    alter table matches
      add constraint matches_score_status_chk
      check (
        (status <> 'FINISHED' and home_score is null and away_score is null)
        or
        (status = 'FINISHED' and home_score is not null and away_score is not null)
      );
  end if;
end $$;
