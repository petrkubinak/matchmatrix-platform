-- Manchester United
insert into team_aliases (team_id, source, alias)
select id, 'football_data_uk', 'Man United'
from teams
where lower(name) like '%manchester united%'
on conflict do nothing;

-- Manchester City
insert into team_aliases (team_id, source, alias)
select id, 'football_data_uk', 'Man City'
from teams
where lower(name) like '%manchester city%'
on conflict do nothing;

-- West Ham
insert into team_aliases (team_id, source, alias)
select id, 'football_data_uk', 'West Ham'
from teams
where lower(name) like '%west ham%'
on conflict do nothing;

-- Wolves
insert into team_aliases (team_id, source, alias)
select id, 'football_data_uk', 'Wolves'
from teams
where lower(name) like '%wolverhampton%'
on conflict do nothing;

-- Nottingham Forest
insert into team_aliases (team_id, source, alias)
select id, 'football_data_uk', 'Nott''m Forest'
from teams
where lower(name) like '%nottingham%'
on conflict do nothing;

-- Tottenham
insert into team_aliases (team_id, source, alias)
select id, 'football_data_uk', 'Tottenham'
from teams
where lower(name) like '%tottenham%'
on conflict do nothing;
