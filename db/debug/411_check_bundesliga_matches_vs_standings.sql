-- ============================================================
-- MATCHMATRIX DEBUG
-- Bundesliga: public.matches vs public.league_standings
-- ============================================================

with bundesliga as (
    select id, name
    from public.leagues
    where name = 'Bundesliga'
    limit 1
),
matches_agg as (
    select
        m.season,
        count(*) as matches_total,
        count(*) filter (where m.status = 'FINISHED') as matches_finished,
        count(*) filter (where m.status = 'SCHEDULED') as matches_scheduled,
        count(*) filter (where m.status = 'POSTPONED') as matches_postponed,
        min(m.kickoff) as first_kickoff,
        max(m.kickoff) as last_kickoff
    from public.matches m
    join bundesliga b
      on b.id = m.league_id
    where m.ext_source = 'football_data'
    group by m.season
),
standings_agg as (
    select
        ls.season,
        count(*) as teams_cnt,
        min(ls.played) as min_played,
        max(ls.played) as max_played,
        sum(ls.played) as sum_played_all_teams
    from public.league_standings ls
    join bundesliga b
      on b.id = ls.league_id
    group by ls.season
)
select
    coalesce(m.season, s.season) as season,
    m.matches_total,
    m.matches_finished,
    m.matches_scheduled,
    m.matches_postponed,
    m.first_kickoff,
    m.last_kickoff,
    s.teams_cnt,
    s.min_played,
    s.max_played,
    s.sum_played_all_teams,
    case
        when s.teams_cnt is not null and s.max_played is not null
        then (s.teams_cnt * s.max_played) / 2
        else null
    end as implied_matches_from_standings
from matches_agg m
full outer join standings_agg s
  on s.season = m.season
order by season desc nulls last;