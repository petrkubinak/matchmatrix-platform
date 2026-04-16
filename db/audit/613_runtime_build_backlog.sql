-- =====================================================================
-- 613_runtime_build_backlog.sql
-- Cíl:
--   odlišit DB-ready vrstvy od skutečně postavitelných runtime vrstev
-- =====================================================================

with base as (
    select
        it.id as ingest_target_id,
        it.sport_code as sport,
        it.provider,
        it.canonical_league_id,
        l.name as canonical_league_name,
        l.country as canonical_country,
        it.provider_league_id,
        coalesce(nullif(it.season, ''), 'ALL') as season,
        it.tier,
        it.run_group,
        it.enabled
    from ops.ingest_targets it
    left join public.leagues l
        on l.id = it.canonical_league_id
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
    select
        b.*,
        e.entity
    from base b
    cross join entity_matrix e
),

classified as (
    select
        x.*,

        case
            when x.enabled = false then 'DISABLED'

            when x.sport = 'FB'
                 and x.provider = 'football_data'
                 and x.entity in ('leagues','teams','fixtures')
                then 'DB_READY_REFERENCE'

            when x.sport = 'FB'
                 and x.provider = 'api_football'
                 and x.entity in ('leagues','teams','fixtures','odds','players')
                then 'DB_READY_EXPAND'

            when x.sport in ('HK','BK','VB','HB')
                 and x.entity in ('leagues','teams','fixtures','odds','players','coaches')
                then 'DB_READY_ONLY'

            else 'DB_PARTIAL'
        end as db_runtime_status,

        case
            when x.enabled = false then 'DO_NOT_BUILD'

            when x.sport = 'FB'
                 and x.provider = 'football_data'
                 and x.entity in ('leagues','teams','fixtures')
                then 'KEEP_RUNTIME_AS_REFERENCE'

            when x.sport = 'FB'
                 and x.provider = 'api_football'
                 and x.entity in ('leagues','teams','fixtures','odds','players')
                then 'CHECK_EXISTING_RUNTIME'

            when x.sport in ('HK','BK','VB','HB')
                 and x.entity in ('leagues','teams','fixtures','odds')
                then 'BUILD_WORKER_AND_INGEST'

            when x.sport in ('HK','BK','VB','HB')
                 and x.entity in ('players','coaches')
                then 'BUILD_ALT_PROVIDER_SLOT'

            else 'MANUAL_REVIEW'
        end as next_runtime_action

    from expanded x
)

select
    sport,
    provider,
    entity,
    db_runtime_status,
    next_runtime_action,
    count(*) as rows_count
from classified
group by
    sport,
    provider,
    entity,
    db_runtime_status,
    next_runtime_action
order by
    sport,
    provider,
    entity,
    db_runtime_status;