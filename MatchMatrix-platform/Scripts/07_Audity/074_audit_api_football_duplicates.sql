-- 70_Audity/74_audit_api_football_duplicates.sql

-- leagues dup
select ext_league_id, count(*)
from public.leagues
where ext_source='api_football'
group by ext_league_id
having count(*) > 1;

-- teams dup
select ext_team_id, count(*)
from public.teams
where ext_source='api_football'
group by ext_team_id
having count(*) > 1;

-- league_teams dup (pokud nemáte unique constraint)
select league_id, team_id, season, count(*)
from public.league_teams
group by league_id, team_id, season
having count(*) > 1;