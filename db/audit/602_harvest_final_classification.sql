-- =====================================================================
-- 602_harvest_final_classification.sql
-- MatchMatrix - final harvest classification layer
--
-- Cíl:
--   1) převést hrubý reuse audit na finální harvest status
--   2) dostat SPORT × PROVIDER × ENTITY × FINAL_STATUS × NEXT_ACTION
--   3) připravit podklad pro WAVE 1 / WAVE 2 orchestration
--
-- Poznámka:
--   Navazuje na logiku 601 auditu, ale běží samostatně.
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
            select max(jr.started_at)
            from ops.job_runs jr
            where jr.params ->> 'provider' = e.provider
              and (
                    jr.params ->> 'provider_league_id' = e.provider_league_id
                    or jr.params ->> 'league_id' = e.provider_league_id
                  )
        ) as last_job_started_at,

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
        end as entity_has_data,

        case
            when c.entity = 'leagues'  then 1
            when c.entity = 'teams'    then c.league_teams_count
            when c.entity = 'fixtures' then c.fixtures_count
            when c.entity = 'odds'     then c.odds_count
            when c.entity = 'players'  then c.players_count
            when c.entity = 'coaches'  then c.coaches_count
            else 0
        end as entity_data_score

    from coverage c
),

classified as (
    select
        b.*,

        case
            -- 0) disabled
            when b.enabled = false then 'DISABLED'

            -- 1) provider hard limits / known blocked people domains
            when b.entity in ('players', 'coaches')
                 and b.provider in ('api_hockey', 'api_volleyball', 'api_handball')
                then 'BLOCKED'

            -- 2) football players -> funguje, ale provider limit
            when b.sport_code = 'FB'
                 and b.provider = 'api_football'
                 and b.entity = 'players'
                 and b.entity_has_data = true
                then 'LIMITED_BY_PROVIDER'

            -- 3) football odds / provider with real odds data
            when b.entity = 'odds'
                 and b.entity_has_data = true
                 and b.success_job_runs > 0
                then 'EXPAND_READY'

            -- 4) silné core ready
            when b.entity in ('leagues', 'teams', 'fixtures')
                 and b.entity_has_data = true
                 and b.success_job_runs > 0
                 and b.provider in ('api_football', 'api_hockey')
                then 'CORE_READY'

            -- 5) data existují, ale orchestrace/runtime důkaz chybí
            when b.entity_has_data = true
                 and coalesce(b.success_job_runs, 0) = 0
                then 'DATA_PRESENT_NOT_ORCHESTRATED'

            -- 6) pipeline byla sahnutá / testovaná
            when coalesce(b.total_job_runs, 0) > 0
                 and not b.entity_has_data
                then 'EXPAND_READY'

            -- 7) target skeleton only
            when b.has_league_provider_map = true
                 or b.enabled = true
                then 'SKELETON_ONLY'

            -- 8) fallback
            else 'BLOCKED'
        end as final_status

    from base_eval b
),

actions as (
    select
        c.*,

        case
            when c.final_status = 'DISABLED'
                then 'KEEP_DISABLED'

            when c.final_status = 'CORE_READY'
                 and c.entity in ('leagues', 'teams', 'fixtures')
                then 'INCLUDE_WAVE_1'

            when c.final_status = 'EXPAND_READY'
                 and c.entity in ('odds')
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
        end as next_action,

        case
            when c.final_status = 'DISABLED'
                then 'Target is explicitly disabled'

            when c.final_status = 'CORE_READY'
                then 'Core entity has data and successful runtime evidence'

            when c.final_status = 'EXPAND_READY'
                then 'Entity or pipeline shows partial readiness, suitable for next wave'

            when c.final_status = 'LIMITED_BY_PROVIDER'
                then 'Pipeline works, but provider plan/coverage is the limiting factor'

            when c.final_status = 'DATA_PRESENT_NOT_ORCHESTRATED'
                then 'Data exists, but OPS/job evidence is not sufficient yet'

            when c.final_status = 'SKELETON_ONLY'
                then 'Target inventory exists, but not enough runtime/data evidence'

            when c.final_status = 'BLOCKED'
                then 'Provider/entity combination is currently blocked or not viable'

            else 'Unclassified'
        end as final_reason

    from classified c
)

-- =====================================================================
-- 1) Hlavní harvest matrix - agregace
-- =====================================================================
select
    sport_code                                   as sport,
    provider,
    entity,
    final_status,
    next_action,
    count(*)                                     as rows_count,
    count(*) filter (where enabled)              as enabled_rows,
    count(*) filter (where entity_has_data)      as rows_with_data,
    sum(fixtures_count)                          as fixtures_count,
    sum(league_teams_count)                      as teams_count,
    sum(odds_count)                              as odds_count,
    sum(players_count)                           as players_count,
    sum(coaches_count)                           as coaches_count,
    max(last_job_started_at)                     as last_job_started_at,
    max(last_job_success_at)                     as last_job_success_at
from actions
group by
    sport_code,
    provider,
    entity,
    final_status,
    next_action
order by
    sport_code,
    provider,
    entity,
    case final_status
        when 'CORE_READY' then 1
        when 'EXPAND_READY' then 2
        when 'LIMITED_BY_PROVIDER' then 3
        when 'DATA_PRESENT_NOT_ORCHESTRATED' then 4
        when 'SKELETON_ONLY' then 5
        when 'BLOCKED' then 6
        when 'DISABLED' then 7
        else 99
    end;

-- =====================================================================
-- 2) Detailní harvest matrix - konkrétní ligy
-- =====================================================================
select
    sport_code                                   as sport,
    provider,
    entity,
    canonical_league_id,
    canonical_league_name,
    canonical_country,
    season,
    enabled,
    tier,
    run_group,
    has_league_provider_map,
    league_teams_count,
    fixtures_count,
    odds_count,
    players_count,
    coaches_count,
    total_job_runs,
    success_job_runs,
    last_job_success_at,
    final_status,
    next_action,
    final_reason
from actions
order by
    sport_code,
    provider,
    entity,
    case final_status
        when 'CORE_READY' then 1
        when 'EXPAND_READY' then 2
        when 'LIMITED_BY_PROVIDER' then 3
        when 'DATA_PRESENT_NOT_ORCHESTRATED' then 4
        when 'SKELETON_ONLY' then 5
        when 'BLOCKED' then 6
        when 'DISABLED' then 7
        else 99
    end,
    tier,
    canonical_league_name,
    season;

-- =====================================================================
-- 3) Jen WAVE kandidáti
-- =====================================================================
select
    sport_code                                   as sport,
    provider,
    entity,
    final_status,
    next_action,
    canonical_league_id,
    canonical_league_name,
    canonical_country,
    season,
    tier,
    run_group,
    fixtures_count,
    league_teams_count,
    odds_count,
    players_count,
    coaches_count,
    last_job_success_at
from actions
where next_action in ('INCLUDE_WAVE_1', 'INCLUDE_WAVE_2')
order by
    case next_action
        when 'INCLUDE_WAVE_1' then 1
        when 'INCLUDE_WAVE_2' then 2
        else 99
    end,
    sport_code,
    provider,
    entity,
    tier,
    canonical_league_name;

-- =====================================================================
-- 4) Jen WAIT / FIX / SKIP backlog
-- =====================================================================
select
    sport_code                                   as sport,
    provider,
    entity,
    final_status,
    next_action,
    canonical_league_id,
    canonical_league_name,
    canonical_country,
    season,
    tier,
    run_group,
    fixtures_count,
    league_teams_count,
    odds_count,
    players_count,
    coaches_count,
    total_job_runs,
    success_job_runs,
    last_job_success_at,
    final_reason
from actions
where next_action in ('WAIT_FOR_PRO', 'FIX_PIPELINE', 'SKIP_FOR_NOW', 'KEEP_DISABLED')
order by
    next_action,
    sport_code,
    provider,
    entity,
    tier,
    canonical_league_name;