-- 736_insert_public_matches_rgb_core.sql

insert into public.matches (
    league_id,
    home_team_id,
    away_team_id,
    kickoff,
    ext_source,
    ext_match_id,
    status,
    home_score,
    away_score,
    season,
    sport_id,
    updated_at
)
select
    l.id as league_id,
    th.team_id as home_team_id,
    ta.team_id as away_team_id,
    f.fixture_date as kickoff,
    'api_rugby' as ext_source,
    f.external_fixture_id as ext_match_id,
    case
        when upper(coalesce(f.status_text, '')) in ('FINISHED', 'FINISH', 'FT', 'FULL TIME') then 'FINISHED'
        when upper(coalesce(f.status_text, '')) in ('LIVE', 'IN PLAY', '1H', '2H') then 'LIVE'
        when upper(coalesce(f.status_text, '')) in ('POSTPONED', 'PST') then 'POSTPONED'
        when upper(coalesce(f.status_text, '')) in ('CANCELLED', 'CANCELED', 'CAN') then 'CANCELLED'
        else 'SCHEDULED'
    end as status,
    nullif(f.home_score, '')::int as home_score,
    nullif(f.away_score, '')::int as away_score,
    f.season::int as season,
    s.id as sport_id,
    now() as updated_at
from staging.stg_provider_fixtures f
join public.leagues l
  on l.ext_source = 'api_rugby'
 and l.ext_league_id = f.external_league_id
join public.team_provider_map th
  on th.provider = 'api_rugby'
 and th.provider_team_id = f.home_team_external_id
join public.team_provider_map ta
  on ta.provider = 'api_rugby'
 and ta.provider_team_id = f.away_team_external_id
join public.sports s
  on lower(s.code) = lower('RGB')
where f.provider = 'api_rugby'
  and not exists (
      select 1
      from public.matches m
      where m.ext_source = 'api_rugby'
        and m.ext_match_id = f.external_fixture_id
  );