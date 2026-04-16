-- =====================================================================
-- 601_reuse_audit_ops_core_status.sql
-- Reuse audit nad existujicim OPS core
-- Cíl:
--   1) nevymýšlet nové master tabulky
--   2) vytáhnout SPORT × ENTITY × STATUS ze stávající reality
--   3) připravit základ pro harvest klasifikaci
-- Spouštět v DBeaveru nad DB matchmatrix
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

-- entity seznam pro audit:
-- zatím stavíme nad tím, co je dnes v projektu realisticky řiditelné
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

        -- existence league map pro provider
        exists (
            select 1
            from public.league_provider_map lpm
            where lpm.league_id = e.canonical_league_id
              and lpm.provider = e.provider
              and lpm.provider_league_id = e.provider_league_id
        ) as has_league_provider_map,

        -- fixtures coverage
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

        -- teams coverage přes league_teams
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

        -- odds coverage přes match_id v lize
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

        -- players coverage: hráči navázaní na týmy v lize
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

        -- coaches coverage: trenéři navázaní na týmy v lize
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

        -- poslední runy pro provider+league
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

classified as (
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
        end as has_data,

        case
            when c.enabled = false then 'disabled'

            when c.entity = 'leagues' and c.has_league_provider_map and c.success_job_runs > 0
                then 'production_ready'

            when c.entity = 'teams' and c.league_teams_count > 0 and c.success_job_runs > 0
                then 'production_ready'

            when c.entity = 'fixtures' and c.fixtures_count > 0 and c.success_job_runs > 0
                then 'production_ready'

            when c.entity = 'odds' and c.odds_count > 0 and c.success_job_runs > 0
                then 'production_ready'

            when c.entity = 'players' and c.players_count > 0 and c.success_job_runs > 0
                then 'runtime_tested'

            when c.entity = 'coaches' and c.coaches_count > 0 and c.success_job_runs > 0
                then 'runtime_tested'

            when c.success_job_runs > 0
                then 'runtime_tested'

            when c.total_job_runs > 0
                then 'tech_ready'

            when c.enabled = true
                then 'planned'

            else 'blocked'
        end as status_bucket,

        case
            when c.enabled = false then 'Target disabled in ops.ingest_targets'

            when c.entity = 'leagues' and c.has_league_provider_map and c.success_job_runs > 0
                then 'League mapping exists + successful run history'

            when c.entity = 'teams' and c.league_teams_count > 0 and c.success_job_runs > 0
                then 'League teams already populated + successful run history'

            when c.entity = 'fixtures' and c.fixtures_count > 0 and c.success_job_runs > 0
                then 'Matches exist + successful run history'

            when c.entity = 'odds' and c.odds_count > 0 and c.success_job_runs > 0
                then 'Odds exist + successful run history'

            when c.entity = 'players' and c.players_count > 0 and c.success_job_runs > 0
                then 'Players exist, pipeline appears runtime-tested'

            when c.entity = 'coaches' and c.coaches_count > 0 and c.success_job_runs > 0
                then 'Coaches exist, pipeline appears runtime-tested'

            when c.success_job_runs > 0
                then 'Successful run exists, but coverage is still weak/unclear'

            when c.total_job_runs > 0
                then 'Runs exist, but no successful result recorded'

            when c.enabled = true
                then 'Enabled target, but no proven runtime evidence yet'

            else 'No evidence in OPS core'
        end as status_reason
    from coverage c
)

select
    canonical_sport_code                              as sport,
    provider,
    entity,
    status_bucket                                     as status,
    count(*)                                          as rows_count,
    count(*) filter (where enabled)                   as enabled_rows,
    count(*) filter (where has_data)                  as rows_with_data,
    sum(fixtures_count)                               as fixtures_count,
    sum(league_teams_count)                           as teams_count,
    sum(odds_count)                                   as odds_count,
    sum(players_count)                                as players_count,
    sum(coaches_count)                                as coaches_count,
    max(last_job_started_at)                          as last_job_started_at,
    max(last_job_success_at)                          as last_job_success_at
from classified
group by
    canonical_sport_code,
    provider,
    entity,
    status_bucket
order by
    canonical_sport_code,
    provider,
    entity,
    case status_bucket
        when 'production_ready' then 1
        when 'runtime_tested'   then 2
        when 'tech_ready'       then 3
        when 'planned'          then 4
        when 'blocked'          then 5
        when 'disabled'         then 6
        else 99
    end;

-- =====================================================================
-- DETAIL: konkrétní targety / ligy
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
        l.name                                  as canonical_league_name,
        l.country                               as canonical_country,
        s.code                                  as canonical_sport_code
    from ops.ingest_targets it
    left join public.leagues l
        on l.id = it.canonical_league_id
    left join public.sports s
        on s.id = l.sport_id
),
entity_matrix as (
    select 'leagues' as entity
    union all select 'teams'
    union all select 'fixtures'
    union all select 'odds'
    union all select 'players'
    union all select 'coaches'
),
expanded as (
    select tb.*, em.entity
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
              and (e.season = 'ALL' or coalesce(m.season, '') = e.season)
        ) as fixtures_count,
        (
            select count(distinct lt.team_id)
            from public.league_teams lt
            where lt.league_id = e.canonical_league_id
              and (e.season = 'ALL' or coalesce(lt.season, '') = e.season or lt.season is null)
        ) as league_teams_count,
        (
            select count(*)
            from public.odds o
            join public.matches m
              on m.id = o.match_id
            where m.league_id = e.canonical_league_id
              and (e.season = 'ALL' or coalesce(m.season, '') = e.season)
        ) as odds_count,
        (
            select count(distinct p.id)
            from public.players p
            where p.team_id in (
                select distinct lt.team_id
                from public.league_teams lt
                where lt.league_id = e.canonical_league_id
                  and (e.season = 'ALL' or coalesce(lt.season, '') = e.season or lt.season is null)
            )
        ) as players_count,
        (
            select count(distinct tc.coach_id)
            from public.team_coaches tc
            where tc.team_id in (
                select distinct lt.team_id
                from public.league_teams lt
                where lt.league_id = e.canonical_league_id
                  and (e.season = 'ALL' or coalesce(lt.season, '') = e.season or lt.season is null)
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
)
select
    canonical_sport_code                            as sport,
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
    case
        when enabled = false then 'disabled'
        when entity = 'leagues'  and has_league_provider_map and success_job_runs > 0 then 'production_ready'
        when entity = 'teams'    and league_teams_count > 0   and success_job_runs > 0 then 'production_ready'
        when entity = 'fixtures' and fixtures_count > 0       and success_job_runs > 0 then 'production_ready'
        when entity = 'odds'     and odds_count > 0           and success_job_runs > 0 then 'production_ready'
        when entity = 'players'  and players_count > 0        and success_job_runs > 0 then 'runtime_tested'
        when entity = 'coaches'  and coaches_count > 0        and success_job_runs > 0 then 'runtime_tested'
        when success_job_runs > 0 then 'runtime_tested'
        when total_job_runs > 0 then 'tech_ready'
        when enabled = true then 'planned'
        else 'blocked'
    end as status
from coverage
order by sport, provider, entity, tier, canonical_league_name, season;