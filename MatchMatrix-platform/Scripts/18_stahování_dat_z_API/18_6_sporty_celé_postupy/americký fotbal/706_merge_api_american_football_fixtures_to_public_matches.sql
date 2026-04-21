-- 706_merge_api_american_football_fixtures_to_public_matches.sql
-- AFB fixtures -> public.matches
-- Spoustet v DBeaveru

begin;

with src as (
    select
        s.provider_game_id,
        s.provider_league_id,
        s.provider_league_name,
        s.game_date,
        s.game_status_short,
        s.game_status_long,
        s.home_team_id,
        s.home_team_name,
        s.away_team_id,
        s.away_team_name,
        s.home_score,
        s.away_score,
        hmap.team_id as home_canonical_team_id,
        amap.team_id as away_canonical_team_id,
        l.id as canonical_league_id,
        sp.id as sport_id,
        case
            when upper(coalesce(s.game_status_short, '')) in ('FT', 'AOT', 'POST') then 'FINISHED'
            when upper(coalesce(s.game_status_short, '')) in ('NS', 'TBD') then 'SCHEDULED'
            when upper(coalesce(s.game_status_short, '')) in ('CANC') then 'CANCELLED'
            else 'SCHEDULED'
        end as canonical_status
    from staging.stg_api_american_football_fixtures s
    join public.team_provider_map hmap
      on hmap.provider = 'api_american_football'
     and hmap.provider_team_id = s.home_team_id
    join public.team_provider_map amap
      on amap.provider = 'api_american_football'
     and amap.provider_team_id = s.away_team_id
    join public.sports sp
      on sp.code = 'AFB'
    left join public.leagues l
      on l.sport_id = sp.id
     and l.ext_source = 'api_american_football'
     and l.ext_league_id = s.provider_league_id
),
ins as (
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
        sport_id
    )
    select
        src.canonical_league_id,
        src.home_canonical_team_id,
        src.away_canonical_team_id,
        src.game_date,
        'api_american_football',
        src.provider_game_id,
        src.canonical_status,
        case when src.canonical_status = 'FINISHED' then src.home_score else null end,
        case when src.canonical_status = 'FINISHED' then src.away_score else null end,
        '2024',
        src.sport_id
    from src
    left join public.matches m
      on m.ext_source = 'api_american_football'
     and m.ext_match_id = src.provider_game_id
    where m.id is null
      and src.home_canonical_team_id is not null
      and src.away_canonical_team_id is not null
      and src.game_date is not null
      and src.home_canonical_team_id <> src.away_canonical_team_id
    returning id
)
select count(*) as inserted_matches
from ins;

commit;

-- Kontroly
select
    count(*) as public_matches_count
from public.matches
where ext_source = 'api_american_football';

select
    status,
    count(*) as cnt
from public.matches
where ext_source = 'api_american_football'
group by status
order by status;

select
    m.id,
    m.ext_match_id,
    m.kickoff,
    m.status,
    ht.name as home_team,
    at.name as away_team,
    m.home_score,
    m.away_score
from public.matches m
join public.teams ht on ht.id = m.home_team_id
join public.teams at on at.id = m.away_team_id
where m.ext_source = 'api_american_football'
order by m.kickoff
limit 30;