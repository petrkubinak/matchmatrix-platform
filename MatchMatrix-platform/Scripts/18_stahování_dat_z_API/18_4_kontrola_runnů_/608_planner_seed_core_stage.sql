-- =====================================================================
-- 608_planner_seed_core_stage.sql
-- Vytvoří dočasnou staging tabulku s prvním CORE planner seedem
-- scope = football_data core only
-- Bezpečné: nic nezapisuje do neznámé ops planner tabulky
-- =====================================================================

drop table if exists temp_planner_seed_core;

create temp table temp_planner_seed_core as
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
      and it.provider = 'football_data'
      and it.run_group = 'FB_FD_CORE'
),
seed_rows as (
    select
        'WAVE_1_CORE'::text as wave,
        'PLANNER_INCLUDE'::text as planner_decision,
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
            when x.entity = 'leagues'  then 200
            when x.entity = 'teams'    then 210
            when x.entity = 'fixtures' then 220
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
    row_number() over (
        order by planner_priority, canonical_league_name, season
    ) as seed_id,
    wave,
    planner_decision,
    sport,
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
    planner_priority,
    now() as staged_at
from seed_rows
order by planner_priority, canonical_league_name, season;

-- =========================================================
-- 1) kontrola objemu
-- =========================================================
select
    wave,
    planner_decision,
    provider,
    entity,
    count(*) as rows_count,
    min(planner_priority) as min_priority,
    max(planner_priority) as max_priority
from temp_planner_seed_core
group by wave, planner_decision, provider, entity
order by provider, entity;

-- =========================================================
-- 2) detail
-- =========================================================
select
    seed_id,
    wave,
    planner_decision,
    sport,
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
    planner_priority,
    staged_at
from temp_planner_seed_core
order by seed_id;