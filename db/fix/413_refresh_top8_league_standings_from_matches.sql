-- ============================================================
-- MATCHMATRIX
-- REFRESH league_standings z public.matches pro TOP 8 football_data lig
-- ============================================================
-- TOP 8:
-- Premier League, La Liga, Bundesliga, Serie A,
-- Ligue 1, Primeira Liga, Eredivisie, Championship
--
-- Zdroj:
--   public.matches (ext_source = 'football_data', status = 'FINISHED')
--
-- Cíl:
--   public.league_standings
--
-- Poznámka:
--   script smaže standings pro TOP8 + zadanou sezonu
--   a znovu je přepočítá z reálně dohraných zápasů.
-- ============================================================

begin;

-- ------------------------------------------------------------
-- 0) Parametr sezony
-- ------------------------------------------------------------
-- Uprav zde sezonu podle potřeby.
-- Pro aktuální běh necháváme 2025.
with params as (
    select '2025'::text as target_season
),

-- ------------------------------------------------------------
-- 1) TOP 8 ligy
-- ------------------------------------------------------------
top8 as (
    select l.id, l.name
    from public.leagues l
    where l.name in (
        'Premier League',
        'Primera Division',
        'Bundesliga',
        'Serie A',
        'Ligue 1',
        'Primeira Liga',
        'Eredivisie',
        'Championship'
    )
),

-- ------------------------------------------------------------
-- 2) Finished matches pro target season
-- ------------------------------------------------------------
finished_matches as (
    select
        m.id,
        m.league_id,
        m.home_team_id,
        m.away_team_id,
        m.home_score,
        m.away_score,
        m.kickoff,
        m.season
    from public.matches m
    join top8 t
      on t.id = m.league_id
    join params p
      on p.target_season = m.season
    where m.ext_source = 'football_data'
      and m.status = 'FINISHED'
      and m.home_score is not null
      and m.away_score is not null
),

-- ------------------------------------------------------------
-- 3) Team-side rows (home/away rozpad)
-- ------------------------------------------------------------
team_side as (
    select
        fm.league_id,
        fm.season,
        fm.kickoff,
        fm.home_team_id as team_id,
        true as is_home,
        fm.home_score as gf,
        fm.away_score as ga,
        case
            when fm.home_score > fm.away_score then 3
            when fm.home_score = fm.away_score then 1
            else 0
        end as pts,
        case when fm.home_score > fm.away_score then 1 else 0 end as win,
        case when fm.home_score = fm.away_score then 1 else 0 end as draw,
        case when fm.home_score < fm.away_score then 1 else 0 end as loss,
        case
            when fm.home_score > fm.away_score then 'W'
            when fm.home_score = fm.away_score then 'D'
            else 'L'
        end as form_char
    from finished_matches fm

    union all

    select
        fm.league_id,
        fm.season,
        fm.kickoff,
        fm.away_team_id as team_id,
        false as is_home,
        fm.away_score as gf,
        fm.home_score as ga,
        case
            when fm.away_score > fm.home_score then 3
            when fm.away_score = fm.home_score then 1
            else 0
        end as pts,
        case when fm.away_score > fm.home_score then 1 else 0 end as win,
        case when fm.away_score = fm.home_score then 1 else 0 end as draw,
        case when fm.away_score < fm.home_score then 1 else 0 end as loss,
        case
            when fm.away_score > fm.home_score then 'W'
            when fm.away_score = fm.home_score then 'D'
            else 'L'
        end as form_char
    from finished_matches fm
),

-- ------------------------------------------------------------
-- 4) Base aggregates
-- ------------------------------------------------------------
base_agg as (
    select
        ts.league_id,
        ts.team_id,
        ts.season,

        count(*) as played,
        sum(ts.win) as wins,
        sum(ts.draw) as draws,
        sum(ts.loss) as losses,
        sum(ts.gf) as goals_for,
        sum(ts.ga) as goals_against,
        sum(ts.gf) - sum(ts.ga) as goal_diff,
        sum(ts.pts) as points,

        count(*) filter (where ts.is_home) as home_played,
        sum(ts.win)  filter (where ts.is_home) as home_wins,
        sum(ts.draw) filter (where ts.is_home) as home_draws,
        sum(ts.loss) filter (where ts.is_home) as home_losses,
        sum(ts.gf)   filter (where ts.is_home) as home_goals_for,
        sum(ts.ga)   filter (where ts.is_home) as home_goals_against,
        (sum(ts.gf) filter (where ts.is_home)) - (sum(ts.ga) filter (where ts.is_home)) as home_goal_diff,
        sum(ts.pts)  filter (where ts.is_home) as home_points,

        count(*) filter (where not ts.is_home) as away_played,
        sum(ts.win)  filter (where not ts.is_home) as away_wins,
        sum(ts.draw) filter (where not ts.is_home) as away_draws,
        sum(ts.loss) filter (where not ts.is_home) as away_losses,
        sum(ts.gf)   filter (where not ts.is_home) as away_goals_for,
        sum(ts.ga)   filter (where not ts.is_home) as away_goals_against,
        (sum(ts.gf) filter (where not ts.is_home)) - (sum(ts.ga) filter (where not ts.is_home)) as away_goal_diff,
        sum(ts.pts)  filter (where not ts.is_home) as away_points
    from team_side ts
    group by ts.league_id, ts.team_id, ts.season
),

-- ------------------------------------------------------------
-- 5) Form 5 / 10 / 15 přes window
-- ------------------------------------------------------------
form_ranked as (
    select
        ts.*,
        row_number() over (
            partition by ts.league_id, ts.team_id, ts.season
            order by ts.kickoff desc, ts.team_id
        ) as rn
    from team_side ts
),

form_agg as (
    select
        fr.league_id,
        fr.team_id,
        fr.season,

        string_agg(fr.form_char, '' order by fr.rn) filter (where fr.rn <= 5)  as form_last_5,
        string_agg(fr.form_char, '' order by fr.rn) filter (where fr.rn <= 10) as form_last_10,
        string_agg(fr.form_char, '' order by fr.rn) filter (where fr.rn <= 15) as form_last_15,

        sum(fr.pts) filter (where fr.rn <= 5)  as points_last_5,
        sum(fr.pts) filter (where fr.rn <= 10) as points_last_10,
        sum(fr.pts) filter (where fr.rn <= 15) as points_last_15
    from form_ranked fr
    group by fr.league_id, fr.team_id, fr.season
),

-- ------------------------------------------------------------
-- 6) Final standings + position
-- ------------------------------------------------------------
final_rows as (
    select
        b.league_id,
        b.team_id,
        b.season,

        row_number() over (
            partition by b.league_id, b.season
            order by
                b.points desc,
                b.goal_diff desc,
                b.goals_for desc,
                b.team_id
        ) as position,

        b.played,
        b.wins,
        b.draws,
        b.losses,
        b.goals_for,
        b.goals_against,
        b.goal_diff,
        b.points,

        b.home_played,
        b.home_wins,
        b.home_draws,
        b.home_losses,
        b.home_goals_for,
        b.home_goals_against,
        b.home_goal_diff,
        b.home_points,

        b.away_played,
        b.away_wins,
        b.away_draws,
        b.away_losses,
        b.away_goals_for,
        b.away_goals_against,
        b.away_goal_diff,
        b.away_points,

        coalesce(f.form_last_5, '') as form_last_5,
        coalesce(f.form_last_10, '') as form_last_10,
        coalesce(f.form_last_15, '') as form_last_15,
        coalesce(f.points_last_5, 0) as points_last_5,
        coalesce(f.points_last_10, 0) as points_last_10,
        coalesce(f.points_last_15, 0) as points_last_15
    from base_agg b
    left join form_agg f
      on f.league_id = b.league_id
     and f.team_id = b.team_id
     and f.season = b.season
)

-- ------------------------------------------------------------
-- 7) Delete old rows
-- ------------------------------------------------------------
delete from public.league_standings ls
using top8 t, params p
where ls.league_id = t.id
  and ls.season = p.target_season;

-- ------------------------------------------------------------
-- 8) Insert refreshed rows
-- ------------------------------------------------------------
with params as (
    select '2025'::text as target_season
),
top8 as (
    select l.id, l.name
    from public.leagues l
    where l.name in (
        'Premier League',
        'Primera Division',
        'Bundesliga',
        'Serie A',
        'Ligue 1',
        'Primeira Liga',
        'Eredivisie',
        'Championship'
    )
),
finished_matches as (
    select
        m.id,
        m.league_id,
        m.home_team_id,
        m.away_team_id,
        m.home_score,
        m.away_score,
        m.kickoff,
        m.season
    from public.matches m
    join top8 t
      on t.id = m.league_id
    join params p
      on p.target_season = m.season
    where m.ext_source = 'football_data'
      and m.status = 'FINISHED'
      and m.home_score is not null
      and m.away_score is not null
),
team_side as (
    select
        fm.league_id,
        fm.season,
        fm.kickoff,
        fm.home_team_id as team_id,
        true as is_home,
        fm.home_score as gf,
        fm.away_score as ga,
        case
            when fm.home_score > fm.away_score then 3
            when fm.home_score = fm.away_score then 1
            else 0
        end as pts,
        case when fm.home_score > fm.away_score then 1 else 0 end as win,
        case when fm.home_score = fm.away_score then 1 else 0 end as draw,
        case when fm.home_score < fm.away_score then 1 else 0 end as loss,
        case
            when fm.home_score > fm.away_score then 'W'
            when fm.home_score = fm.away_score then 'D'
            else 'L'
        end as form_char
    from finished_matches fm

    union all

    select
        fm.league_id,
        fm.season,
        fm.kickoff,
        fm.away_team_id as team_id,
        false as is_home,
        fm.away_score as gf,
        fm.home_score as ga,
        case
            when fm.away_score > fm.home_score then 3
            when fm.away_score = fm.home_score then 1
            else 0
        end as pts,
        case when fm.away_score > fm.home_score then 1 else 0 end as win,
        case when fm.away_score = fm.home_score then 1 else 0 end as draw,
        case when fm.away_score < fm.home_score then 1 else 0 end as loss,
        case
            when fm.away_score > fm.home_score then 'W'
            when fm.away_score = fm.home_score then 'D'
            else 'L'
        end as form_char
    from finished_matches fm
),
base_agg as (
    select
        ts.league_id,
        ts.team_id,
        ts.season,

        count(*) as played,
        sum(ts.win) as wins,
        sum(ts.draw) as draws,
        sum(ts.loss) as losses,
        sum(ts.gf) as goals_for,
        sum(ts.ga) as goals_against,
        sum(ts.gf) - sum(ts.ga) as goal_diff,
        sum(ts.pts) as points,

        count(*) filter (where ts.is_home) as home_played,
        sum(ts.win)  filter (where ts.is_home) as home_wins,
        sum(ts.draw) filter (where ts.is_home) as home_draws,
        sum(ts.loss) filter (where ts.is_home) as home_losses,
        sum(ts.gf)   filter (where ts.is_home) as home_goals_for,
        sum(ts.ga)   filter (where ts.is_home) as home_goals_against,
        (sum(ts.gf) filter (where ts.is_home)) - (sum(ts.ga) filter (where ts.is_home)) as home_goal_diff,
        sum(ts.pts)  filter (where ts.is_home) as home_points,

        count(*) filter (where not ts.is_home) as away_played,
        sum(ts.win)  filter (where not ts.is_home) as away_wins,
        sum(ts.draw) filter (where not ts.is_home) as away_draws,
        sum(ts.loss) filter (where not ts.is_home) as away_losses,
        sum(ts.gf)   filter (where not ts.is_home) as away_goals_for,
        sum(ts.ga)   filter (where not ts.is_home) as away_goals_against,
        (sum(ts.gf) filter (where not ts.is_home)) - (sum(ts.ga) filter (where not ts.is_home)) as away_goal_diff,
        sum(ts.pts)  filter (where not ts.is_home) as away_points
    from team_side ts
    group by ts.league_id, ts.team_id, ts.season
),
form_ranked as (
    select
        ts.*,
        row_number() over (
            partition by ts.league_id, ts.team_id, ts.season
            order by ts.kickoff desc, ts.team_id
        ) as rn
    from team_side ts
),
form_agg as (
    select
        fr.league_id,
        fr.team_id,
        fr.season,

        string_agg(fr.form_char, '' order by fr.rn) filter (where fr.rn <= 5)  as form_last_5,
        string_agg(fr.form_char, '' order by fr.rn) filter (where fr.rn <= 10) as form_last_10,
        string_agg(fr.form_char, '' order by fr.rn) filter (where fr.rn <= 15) as form_last_15,

        sum(fr.pts) filter (where fr.rn <= 5)  as points_last_5,
        sum(fr.pts) filter (where fr.rn <= 10) as points_last_10,
        sum(fr.pts) filter (where fr.rn <= 15) as points_last_15
    from form_ranked fr
    group by fr.league_id, fr.team_id, fr.season
),
final_rows as (
    select
        b.league_id,
        b.team_id,
        b.season,

        row_number() over (
            partition by b.league_id, b.season
            order by
                b.points desc,
                b.goal_diff desc,
                b.goals_for desc,
                b.team_id
        ) as position,

        b.played,
        b.wins,
        b.draws,
        b.losses,
        b.goals_for,
        b.goals_against,
        b.goal_diff,
        b.points,

        b.home_played,
        b.home_wins,
        b.home_draws,
        b.home_losses,
        b.home_goals_for,
        b.home_goals_against,
        b.home_goal_diff,
        b.home_points,

        b.away_played,
        b.away_wins,
        b.away_draws,
        b.away_losses,
        b.away_goals_for,
        b.away_goals_against,
        b.away_goal_diff,
        b.away_points,

        coalesce(f.form_last_5, '') as form_last_5,
        coalesce(f.form_last_10, '') as form_last_10,
        coalesce(f.form_last_15, '') as form_last_15,
        coalesce(f.points_last_5, 0) as points_last_5,
        coalesce(f.points_last_10, 0) as points_last_10,
        coalesce(f.points_last_15, 0) as points_last_15
    from base_agg b
    left join form_agg f
      on f.league_id = b.league_id
     and f.team_id = b.team_id
     and f.season = b.season
)
insert into public.league_standings (
    league_id,
    team_id,
    season,
    position,
    played,
    wins,
    draws,
    losses,
    goals_for,
    goals_against,
    goal_diff,
    points,
    home_played,
    home_wins,
    home_draws,
    home_losses,
    home_goals_for,
    home_goals_against,
    home_goal_diff,
    home_points,
    away_played,
    away_wins,
    away_draws,
    away_losses,
    away_goals_for,
    away_goals_against,
    away_goal_diff,
    away_points,
    form_last_5,
    form_last_10,
    form_last_15,
    points_last_5,
    points_last_10,
    points_last_15
)
select
    league_id,
    team_id,
    season,
    position,
    played,
    wins,
    draws,
    losses,
    goals_for,
    goals_against,
    goal_diff,
    points,
    home_played,
    home_wins,
    home_draws,
    home_losses,
    home_goals_for,
    home_goals_against,
    home_goal_diff,
    home_points,
    away_played,
    away_wins,
    away_draws,
    away_losses,
    away_goals_for,
    away_goals_against,
    away_goal_diff,
    away_points,
    form_last_5,
    form_last_10,
    form_last_15,
    points_last_5,
    points_last_10,
    points_last_15
from final_rows;

commit;

-- ============================================================
-- KONTROLA
-- ============================================================
select
    l.name,
    ls.season,
    count(*) as teams_cnt,
    min(ls.played) as min_played,
    max(ls.played) as max_played
from public.league_standings ls
join public.leagues l
  on l.id = ls.league_id
where l.name in (
    'Premier League',
    'Primera Division',
    'Bundesliga',
    'Serie A',
    'Ligue 1',
    'Primeira Liga',
    'Eredivisie',
    'Championship'
)
  and ls.season = '2025'
group by l.name, ls.season
order by l.name;