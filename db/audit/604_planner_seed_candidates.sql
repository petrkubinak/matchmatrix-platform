-- =====================================================================
-- 604_planner_seed_candidates_LITE.sql
-- LEHKÁ VERZE (rychlá)
-- NEpočítá coverage znovu
-- Používá jen ingest_targets + jednoduchou klasifikaci
-- =====================================================================

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
),

entity_matrix as (
    select 'leagues' as entity
    union all select 'teams'
    union all select 'fixtures'
    union all select 'odds'
    union all select 'players'
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
        *,
        case
            -- WAVE 1 = football core
            when sport_code = 'FB'
                 and provider in ('api_football', 'football_data')
                 and entity in ('leagues','teams','fixtures')
                 and enabled = true
                then 'WAVE_1'

            -- WAIT = players football
            when sport_code = 'FB'
                 and provider = 'api_football'
                 and entity = 'players'
                then 'WAIT'

            -- WAVE 2 = expand sporty
            when provider in ('api_hockey','api_sport','api_volleyball')
                 and entity in ('leagues','teams','fixtures','odds')
                 and enabled = true
                then 'WAVE_2'

            else 'SKIP'
        end as wave
    from expanded
),

planner_seed as (
    select
        wave,
        sport_code as sport,
        provider,
        entity,
        canonical_league_id,
        canonical_league_name,
        canonical_country,
        provider_league_id,
        season,
        tier,
        run_group,

        case
            when wave = 'WAVE_1' and entity = 'leagues'  then 100
            when wave = 'WAVE_1' and entity = 'teams'    then 110
            when wave = 'WAVE_1' and entity = 'fixtures' then 120

            when wave = 'WAVE_2' then 200

            else 999
        end as planner_priority,

        case
            when wave in ('WAVE_1','WAVE_2') then 'PLANNER_INCLUDE'
            when wave = 'WAIT' then 'PLANNER_HOLD'
            else 'PLANNER_SKIP'
        end as planner_decision

    from classified
)

-- =========================================================
-- 1) RYCHLÝ PŘEHLED
-- =========================================================
select
    wave,
    provider,
    entity,
    count(*) as rows_count
from planner_seed
where wave in ('WAVE_1','WAVE_2','WAIT')
group by wave, provider, entity
order by
    case wave
        when 'WAVE_1' then 1
        when 'WAVE_2' then 2
        when 'WAIT' then 3
        else 99
    end,
    provider,
    entity;