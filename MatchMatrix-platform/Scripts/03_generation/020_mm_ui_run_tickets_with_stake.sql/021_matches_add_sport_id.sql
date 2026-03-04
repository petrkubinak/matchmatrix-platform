-- Add sport_id directly to matches for faster queries / ML datasets
alter table matches
  add column if not exists sport_id integer;

-- Backfill from leagues
update matches m
set sport_id = l.sport_id
from leagues l
where m.league_id = l.id
  and (m.sport_id is null or m.sport_id <> l.sport_id);

-- Enforce NOT NULL after backfill (safe if all matches have league_id -> leagues)
alter table matches
  alter column sport_id set not null;

-- Optional FK (recommended)
alter table matches
  add constraint if not exists fk_matches_sport
  foreign key (sport_id) references sports(id);