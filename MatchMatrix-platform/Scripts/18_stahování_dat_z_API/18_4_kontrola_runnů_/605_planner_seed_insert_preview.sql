-- =====================================================================
-- 605_planner_seed_insert_preview.sql
-- Preview kandidátů pro první planner seed
-- Jen WAVE_1 CORE
-- OPRAVA: CTE se opakuje pro každou query zvlášť
-- =====================================================================

-- =========================================================
-- 1) Agregace
-- =========================================================
with base as (
    select
        it.id as ingest_target_id,
        it.sport_code,
        it.provider,
        it.canonical_league_id,
        it.provider_league_id,
        coalesce(nullif(it.season, ''), 'ALL') as season,
        it.enabled,
        it.tier,
        it.run_group,
        l.name as canonical_league_name,
        l.country as canonical_country
    from ops.ingest_targets it
    left join public.leagues l
        on l.id = it.canonical_league_id
    where it.enabled = true
      and it.sport_code = 'FB'
      and it.provider in ('api_football', 'football_data')
),
seed_rows as (
    select
        'WAVE_1' as wave,
        b.sport_code as sport,
        b.provider,
        x.entity,
        b.ingest_target_id,
        b.canonical_league_id,
        b.canonical_league_name,
        b.canonical_country,
        b.provider_league_id,
        b.season,
        b.tier,
        b.run_group,
        case
            when b.provider = 'api_football' and x.entity = 'leagues'  then 100
            when b.provider = 'api_football' and x.entity = 'teams'    then 110
            when b.provider = 'api_football' and x.entity = 'fixtures' then 120
            when b.provider = 'football_data' and x.entity = 'leagues'  then 200
            when b.provider = 'football_data' and x.entity = 'teams'    then 210
            when b.provider = 'football_data' and x.entity = 'fixtures' then 220
            else 999
        end as planner_priority
    from base b
    cross join (
        select 'leagues' as entity
        union all select 'teams'
        union all select 'fixtures'
    ) x
)
select
    wave,
    provider,
    entity,
    count(*) as rows_count,
    min(planner_priority) as min_priority,
    max(planner_priority) as max_priority
from seed_rows
group by wave, provider, entity
order by provider, entity;

-- =========================================================
-- 2) Detail preview
-- =========================================================
with base as (
    select
        it.id as ingest_target_id,
        it.sport_code,
        it.provider,
        it.canonical_league_id,
        it.provider_league_id,
        coalesce(nullif(it.season, ''), 'ALL') as season,
        it.enabled,
        it.tier,
        it.run_group,
        l.name as canonical_league_name,
        l.country as canonical_country
    from ops.ingest_targets it
    left join public.leagues l
        on l.id = it.canonical_league_id
    where it.enabled = true
      and it.sport_code = 'FB'
      and it.provider in ('api_football', 'football_data')
),
seed_rows as (
    select
        'WAVE_1' as wave,
        b.sport_code as sport,
        b.provider,
        x.entity,
        b.ingest_target_id,
        b.canonical_league_id,
        b.canonical_league_name,
        b.canonical_country,
        b.provider_league_id,
        b.season,
        b.tier,
        b.run_group,
        case
            when b.provider = 'api_football' and x.entity = 'leagues'  then 100
            when b.provider = 'api_football' and x.entity = 'teams'    then 110
            when b.provider = 'api_football' and x.entity = 'fixtures' then 120
            when b.provider = 'football_data' and x.entity = 'leagues'  then 200
            when b.provider = 'football_data' and x.entity = 'teams'    then 210
            when b.provider = 'football_data' and x.entity = 'fixtures' then 220
            else 999
        end as planner_priority
    from base b
    cross join (
        select 'leagues' as entity
        union all select 'teams'
        union all select 'fixtures'
    ) x
)
select
    wave,
    provider,
    entity,
    ingest_target_id,
    canonical_league_id,
    canonical_league_name,
    canonical_country,
    provider_league_id,
    season,
    tier,
    run_group,
    planner_priority
from seed_rows
order by planner_priority, canonical_league_name, season;