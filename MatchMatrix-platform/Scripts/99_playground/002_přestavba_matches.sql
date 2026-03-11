-- Simple rebuild (safe & deterministic). You can optimize later.
-- Assumes matches.sport_id exists.

insert into match_features (match_id,
  home_last5_points, away_last5_points,
  home_last5_gf, home_last5_ga,
  away_last5_gf, away_last5_ga,
  home_rest_days, away_rest_days,
  h2h_last5_goal_diff,
  updated_at
)
select
  m.id as match_id,

  -- HOME last 5 points
  (
    select coalesce(sum(
      case
        when x.home_team_id = m.home_team_id and x.home_score > x.away_score then 3
        when x.away_team_id = m.home_team_id and x.away_score > x.home_score then 3
        when x.home_score = x.away_score then 1
        else 0
      end
    ),0)
    from (
      select *
      from matches
      where status='FINISHED'
        and kickoff < m.kickoff
        and (home_team_id = m.home_team_id or away_team_id = m.home_team_id)
        and sport_id = m.sport_id
      order by kickoff desc
      limit 5
    ) x
  ) as home_last5_points,

  -- AWAY last 5 points
  (
    select coalesce(sum(
      case
        when x.home_team_id = m.away_team_id and x.home_score > x.away_score then 3
        when x.away_team_id = m.away_team_id and x.away_score > x.home_score then 3
        when x.home_score = x.away_score then 1
        else 0
      end
    ),0)
    from (
      select *
      from matches
      where status='FINISHED'
        and kickoff < m.kickoff
        and (home_team_id = m.away_team_id or away_team_id = m.away_team_id)
        and sport_id = m.sport_id
      order by kickoff desc
      limit 5
    ) x
  ) as away_last5_points,

  -- HOME last 5 goals for/against (avg per match)
  (
    select coalesce(avg(
      case when x.home_team_id = m.home_team_id then x.home_score else x.away_score end
    )::numeric,0)
    from (
      select *
      from matches
      where status='FINISHED'
        and kickoff < m.kickoff
        and (home_team_id = m.home_team_id or away_team_id = m.home_team_id)
        and sport_id = m.sport_id
      order by kickoff desc
      limit 5
    ) x
  ) as home_last5_gf,
  (
    select coalesce(avg(
      case when x.home_team_id = m.home_team_id then x.away_score else x.home_score end
    )::numeric,0)
    from (
      select *
      from matches
      where status='FINISHED'
        and kickoff < m.kickoff
        and (home_team_id = m.home_team_id or away_team_id = m.home_team_id)
        and sport_id = m.sport_id
      order by kickoff desc
      limit 5
    ) x
  ) as home_last5_ga,

  -- AWAY last 5 goals for/against
  (
    select coalesce(avg(
      case when x.home_team_id = m.away_team_id then x.home_score else x.away_score end
    )::numeric,0)
    from (
      select *
      from matches
      where status='FINISHED'
        and kickoff < m.kickoff
        and (home_team_id = m.away_team_id or away_team_id = m.away_team_id)
        and sport_id = m.sport_id
      order by kickoff desc
      limit 5
    ) x
  ) as away_last5_gf,
  (
    select coalesce(avg(
      case when x.home_team_id = m.away_team_id then x.away_score else x.home_score end
    )::numeric,0)
    from (
      select *
      from matches
      where status='FINISHED'
        and kickoff < m.kickoff
        and (home_team_id = m.away_team_id or away_team_id = m.away_team_id)
        and sport_id = m.sport_id
      order by kickoff desc
      limit 5
    ) x
  ) as away_last5_ga,

  -- rest days (days since last match)
  (
    select coalesce(extract(day from (m.kickoff - max(x.kickoff)))::int, null)
    from matches x
    where x.status='FINISHED'
      and x.kickoff < m.kickoff
      and (x.home_team_id = m.home_team_id or x.away_team_id = m.home_team_id)
      and x.sport_id = m.sport_id
  ) as home_rest_days,

  (
    select coalesce(extract(day from (m.kickoff - max(x.kickoff)))::int, null)
    from matches x
    where x.status='FINISHED'
      and x.kickoff < m.kickoff
      and (x.home_team_id = m.away_team_id or x.away_team_id = m.away_team_id)
      and x.sport_id = m.sport_id
  ) as away_rest_days,

  -- h2h last 5 goal diff (home - away from perspective of home_team in upcoming match)
  (
    select coalesce(sum(
      case
        when x.home_team_id = m.home_team_id and x.away_team_id = m.away_team_id then (x.home_score - x.away_score)
        when x.home_team_id = m.away_team_id and x.away_team_id = m.home_team_id then (x.away_score - x.home_score)
        else 0
      end
    ),0)
    from (
      select *
      from matches
      where status='FINISHED'
        and kickoff < m.kickoff
        and sport_id = m.sport_id
        and (
          (home_team_id = m.home_team_id and away_team_id = m.away_team_id)
          or
          (home_team_id = m.away_team_id and away_team_id = m.home_team_id)
        )
      order by kickoff desc
      limit 5
    ) x
  ) as h2h_last5_goal_diff,

  now() as updated_at

from matches m
where m.kickoff is not null
on conflict (match_id) do update set
  home_last5_points = excluded.home_last5_points,
  away_last5_points = excluded.away_last5_points,
  home_last5_gf = excluded.home_last5_gf,
  home_last5_ga = excluded.home_last5_ga,
  away_last5_gf = excluded.away_last5_gf,
  away_last5_ga = excluded.away_last5_ga,
  home_rest_days = excluded.home_rest_days,
  away_rest_days = excluded.away_rest_days,
  h2h_last5_goal_diff = excluded.h2h_last5_goal_diff,
  updated_at = now();
