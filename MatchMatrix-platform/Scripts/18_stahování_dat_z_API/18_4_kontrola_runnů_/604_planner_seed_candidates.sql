-- =====================================================================
-- 604_planner_seed_candidates.sql
-- MatchMatrix - planner seed candidates
-- Cíl:
--   1) vytvořit čistý seed kandidátů pro planner
--   2) oddělit WAVE_1, WAVE_2, WAIT
--   3) připravit podklad pro budoucí insert do ops.ingest_planner / job queue
-- =====================================================================

with target_base as (
    select
        it.id                                   as ingest_target_id,
        it.sport_code,
        it.provider,
        it.canonical_league_id,
        it.provider_league_id,
        coalesce(nullif(it.season, ''), 'ALL')  as season,
        it.enabled,
        it.tier,
        it.run_group,
        it.max_requests_per_run,
        it.notes,
        l.name                                  as canonical_league_name,
        l.country                               as canonical_country,
        l.sport_id,
        s.code                                  as canonical_sport_code,
        s.name                                  as canonical_sport_name
    from ops.ingest_targets it
    left join public.leagues l
        on l.id = it.canonical_league_id
    left join public.sports s
        on s.id = l.sport_id
),

entity_matrix as (
    select 'leagues'  as entity
    union all select 'teams'
    union all select 'fixtures'
    union all select 'odds'
    union all select 'players'
    union all select 'coaches'
),

expanded as (
    select
        tb.*,
        em.entity
    from target_base tb
    cross join entity_matrix em
),

coverage as (
    select
        e.*,

        exists (
            select 1
            from public.league_provider_map lpm
            where lpm.league_id = e.canonical_league_id
              and lpm.provider = e.provider
              and lpm.provider_league_id = e.provider_league_id
        ) as has_league_provider_map,

        (
            select count(*)
            from public.matches m
            where m.league_id = e.canonical_league_id
              and m.ext_source = e.provider
              and (
                    e.season = 'ALL'
                    or coalesce(m.season, '') = e.season
                  )
        ) as fixtures_count,

        (
            select count(distinct lt.team_id)
            from public.league_teams lt
            where lt.league_id = e.canonical_league_id
              and (
                    e.season = 'ALL'
                    or coalesce(lt.season, '') = e.season
                    or lt.season is null
                  )
        ) as league_teams_count,

        (
            select count(*)
            from public.odds o
            join public.matches m
              on m.id = o.match_id
            where m.league_id = e.canonical_league_id
              and (
                    e.season = 'ALL'
                    or coalesce(m.season, '') = e.season
                  )
        ) as odds_count,

        (
            select count(distinct p.id)
            from public.players p
            where p.team_id in (
                select distinct lt.team_id
                from public.league_teams lt
                where lt.league_id = e.canonical_league_id
                  and (
                        e.season = 'ALL'
                        or coalesce(lt.season, '') = e.season
                        or lt.season is null
                      )
            )
        ) as players_count,

        (
            select count(distinct tc.coach_id)
            from public.team_coaches tc
            where tc.team_id in (
                select distinct lt.team_id
                from public.league_teams lt
                where lt.league_id = e.canonical_league_id
                  and (
                        e.season = 'ALL'
                        or coalesce(lt.season, '') = e.season
                        or lt.season is null
                      )
            )
        ) as coaches_count,

        (
            select max(jr.finished_at)
            from ops.job_runs jr
            where jr.params ->> 'provider' = e.provider
              and (
                    jr.params ->> 'provider_league_id' = e.provider_league_id
                    or jr.params ->> 'league_id' = e.provider_league_id
                  )
              and jr.status = 'success'
        ) as last_job_success_at,

        (
            select count(*)
            from ops.job_runs jr
            where jr.params ->> 'provider' = e.provider
              and (
                    jr.params ->> 'provider_league_id' = e.provider_league_id
                    or jr.params ->> 'league_id' = e.provider_league_id
                  )
        ) as total_job_runs,

        (
            select count(*)
            from ops.job_runs jr
            where jr.params ->> 'provider' = e.provider
              and (
                    jr.params ->> 'provider_league_id' = e.provider_league_id
                    or jr.params ->> 'league_id' = e.provider_league_id
                  )
              and jr.status = 'success'
        ) as success_job_runs
    from expanded e
),

base_eval as (
    select
        c.*,
        case c.entity
            when 'leagues'  then c.has_league_provider_map
            when 'teams'    then c.league_teams_count > 0
            when 'fixtures' then c.fixtures_count > 0
            when 'odds'     then c.odds_count > 0
            when 'players'  then c.players_count > 0
            when 'coaches'  then c.coaches_count > 0
            else false
        end as entity_has_data
    from coverage c
),

classified as (
    select
        b.*,
        case
            when b.enabled = false then 'DISABLED'
            when b.entity in ('players', 'coaches')
                 and b.provider in ('api_hockey', 'api_volleyball', 'api_handball')
                then 'BLOCKED'
            when b.sport_code = 'FB'
                 and b.provider = 'api_football'
                 and b.entity = 'players'
                 and b.entity_has_data = true
                then 'LIMITED_BY_PROVIDER'
            when b.entity = 'odds'
                 and b.entity_has_data = true
                 and b.success_job_runs > 0
                then 'EXPAND_READY'
            when b.entity in ('leagues', 'teams', 'fixtures')
                 and b.entity_has_data = true
                 and b.success_job_runs > 0
                 and b.provider in ('api_football', 'api_hockey')
                then 'CORE_READY'
            when b.entity_has_data = true
                 and coalesce(b.success_job_runs, 0) = 0
                then 'DATA_PRESENT_NOT_ORCHESTRATED'
            when coalesce(b.total_job_runs, 0) > 0
                 and not b.entity_has_data
                then 'EXPAND_READY'
            when b.has_league_provider_map = true
                 or b.enabled = true
                then 'SKELETON_ONLY'
            else 'BLOCKED'
        end as final_status
    from base_eval b
),

actions as (
    select
        c.*,
        case
            when c.final_status = 'DISABLED' then 'KEEP_DISABLED'
            when c.final_status = 'CORE_READY'
                 and c.entity in ('leagues', 'teams', 'fixtures')
                then 'INCLUDE_WAVE_1'
            when c.final_status = 'EXPAND_READY'
                 and c.entity = 'odds'
                then 'INCLUDE_WAVE_2'
            when c.final_status = 'EXPAND_READY'
                 and c.entity in ('leagues', 'teams', 'fixtures')
                then 'INCLUDE_WAVE_2'
            when c.final_status = 'LIMITED_BY_PROVIDER'
                then 'WAIT_FOR_PRO'
            when c.final_status = 'DATA_PRESENT_NOT_ORCHESTRATED'
                then 'FIX_PIPELINE'
            when c.final_status = 'SKELETON_ONLY'
                then 'SKIP_FOR_NOW'
            when c.final_status = 'BLOCKED'
                then 'SKIP_FOR_NOW'
            else 'SKIP_FOR_NOW'
        end as next_action
    from classified c
),

wave_classified as (
    select
        a.*,
        case
            when a.sport_code = 'FB'
                 and a.provider in ('api_football', 'football_data')
                 and a.entity in ('leagues', 'teams', 'fixtures')
                 and a.final_status in ('CORE_READY', 'DATA_PRESENT_NOT_ORCHESTRATED')
                then 'WAVE_1'
            when a.final_status = 'EXPAND_READY'
                 and a.next_action = 'INCLUDE_WAVE_2'
                then 'WAVE_2'
            when a.next_action = 'WAIT_FOR_PRO'
                then 'WAIT'
            else 'SKIP'
        end as wave
    from actions a
),

planner_seed as (
    select
        wave,
        sport_code                           as sport,
        provider,
        entity,
        canonical_league_id,
        canonical_league_name,
        canonical_country,
        provider_league_id,
        season,
        tier,
        run_group,
        final_status,
        next_action,
        fixtures_count,
        league_teams_count,
        odds_count,
        players_count,
        coaches_count,
        total_job_runs,
        success_job_runs,
        last_job_success_at,

        case
            when wave = 'WAVE_1' and provider = 'api_football' and entity = 'leagues'  then 110
            when wave = 'WAVE_1' and provider = 'api_football' and entity = 'teams'    then 120
            when wave = 'WAVE_1' and provider = 'api_football' and entity = 'fixtures' then 130

            when wave = 'WAVE_1' and provider = 'football_data' and entity = 'leagues'  then 210
            when wave = 'WAVE_1' and provider = 'football_data' and entity = 'teams'    then 220
            when wave = 'WAVE_1' and provider = 'football_data' and entity = 'fixtures' then 230

            when wave = 'WAVE_2' and provider = 'api_football' and entity = 'odds' then 310

            when wave = 'WAVE_2' and provider = 'api_hockey' and entity = 'leagues'  then 410
            when wave = 'WAVE_2' and provider = 'api_hockey' and entity = 'fixtures' then 420
            when wave = 'WAVE_2' and provider = 'api_hockey' and entity = 'odds'     then 430

            when wave = 'WAVE_2' and provider = 'api_sport' and entity = 'leagues'  then 510
            when wave = 'WAVE_2' and provider = 'api_sport' and entity = 'teams'    then 520
            when wave = 'WAVE_2' and provider = 'api_sport' and entity = 'fixtures' then 530
            when wave = 'WAVE_2' and provider = 'api_sport' and entity = 'odds'     then 540

            when wave = 'WAVE_2' and provider = 'api_volleyball' and entity = 'leagues'  then 610
            when wave = 'WAVE_2' and provider = 'api_volleyball' and entity = 'teams'    then 620
            when wave = 'WAVE_2' and provider = 'api_volleyball' and entity = 'fixtures' then 630
            when wave = 'WAVE_2' and provider = 'api_volleyball' and entity = 'odds'     then 640

            else 999
        end as planner_priority,

        case
            when wave = 'WAVE_1' then 'PLANNER_INCLUDE'
            when wave = 'WAVE_2' then 'PLANNER_INCLUDE'
            when wave = 'WAIT'   then 'PLANNER_HOLD'
            else 'PLANNER_SKIP'
        end as planner_decision

    from wave_classified
)

-- =========================================================
-- 1) Hlavní seed kandidáti pro planner
-- =========================================================
select
    wave,
    planner_decision,
    planner_priority,
    sport,
    provider,
    entity,
    canonical_league_id,
    canonical_league_name,
    canonical_country,
    provider_league_id,
    season,
    tier,
    run_group,
    final_status,
    next_action,
    fixtures_count,
    league_teams_count,
    odds_count,
    players_count,
    coaches_count,
    total_job_runs,
    success_job_runs,
    last_job_success_at
from planner_seed
where wave in ('WAVE_1', 'WAVE_2', 'WAIT')
order by
    case wave
        when 'WAVE_1' then 1
        when 'WAVE_2' then 2
        when 'WAIT'   then 3
        else 99
    end,
    planner_priority,
    canonical_league_name,
    season;

-- =========================================================
-- 2) Agregace pro kontrolu seed objemu
-- =========================================================
select
    wave,
    provider,
    entity,
    count(*) as rows_count,
    min(planner_priority) as min_priority,
    max(planner_priority) as max_priority
from planner_seed
where wave in ('WAVE_1', 'WAVE_2', 'WAIT')
group by wave, provider, entity
order by
    case wave
        when 'WAVE_1' then 1
        when 'WAVE_2' then 2
        when 'WAIT'   then 3
        else 99
    end,
    provider,
    entity;