-- =====================================================================
-- 610_provider_sport_entity_matrix.sql
-- MatchMatrix - provider × sport × entity matrix
--
-- Cíl:
--   1) sjednotit realitu napříč sporty a providery
--   2) oddělit tech/data/provider-limit stav
--   3) určit recommended_mode a next_build_step
--
-- Lehká verze:
--   - bez heavy coverage subquery
--   - staví hlavně nad ops.ingest_targets
--   - vhodná pro rychlý management přehled
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
        it.max_requests_per_run,
        it.notes,
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

        -- =========================================================
        -- 1) TECH STATUS
        -- =========================================================
        case
            when x.enabled = false then 'DISABLED'

            when x.sport_code = 'FB'
                 and x.provider = 'football_data'
                 and x.entity in ('leagues','teams','fixtures')
                then 'TECH_READY'

            when x.sport_code = 'FB'
                 and x.provider = 'api_football'
                 and x.entity in ('leagues','teams','fixtures','players','odds')
                then 'TECH_READY'

            when x.sport_code = 'HK'
                 and x.provider = 'api_hockey'
                 and x.entity in ('leagues','teams','fixtures','odds')
                then 'TECH_READY'

            when x.sport_code = 'BK'
                 and x.provider = 'api_sport'
                 and x.entity in ('leagues','teams','fixtures','odds')
                then 'PARTIAL'

            when x.sport_code = 'VB'
                 and x.provider = 'api_volleyball'
                 and x.entity in ('leagues','teams','fixtures','odds')
                then 'PARTIAL'

            when x.provider in (
                    'api_american_football',
                    'api_baseball',
                    'api_cricket',
                    'api_darts',
                    'api_esports',
                    'api_field_hockey',
                    'api_mma',
                    'api_rugby',
                    'api_tennis'
                 )
                then 'SKELETON'

            else 'REVIEW'
        end as tech_status,

        -- =========================================================
        -- 2) DATA STATUS
        -- =========================================================
        case
            when x.enabled = false then 'DISABLED'

            when x.sport_code = 'FB'
                 and x.provider = 'football_data'
                 and x.run_group = 'FB_FD_CORE'
                 and x.entity in ('leagues','teams','fixtures')
                then 'CORE_DATASET'

            when x.sport_code = 'FB'
                 and x.provider = 'api_football'
                 and x.entity in ('leagues','teams','fixtures')
                then 'BROAD_TARGET_SET'

            when x.sport_code = 'FB'
                 and x.provider = 'api_football'
                 and x.entity = 'players'
                then 'LIMITED_DATASET'

            when x.sport_code = 'HK'
                 and x.provider = 'api_hockey'
                 and x.entity in ('leagues','teams','fixtures')
                then 'PARTIAL_DATASET'

            when x.sport_code = 'HK'
                 and x.provider = 'api_hockey'
                 and x.entity in ('players','coaches')
                then 'NO_DATASET'

            when x.sport_code = 'BK'
                 and x.provider = 'api_sport'
                 and x.entity in ('leagues','teams','fixtures','odds')
                then 'PARTIAL_DATASET'

            when x.sport_code = 'VB'
                 and x.provider = 'api_volleyball'
                 and x.entity in ('leagues','teams','fixtures','odds')
                then 'MINIMAL_DATASET'

            when x.entity in ('players','coaches')
                then 'NO_DATASET'

            else 'SKELETON_DATASET'
        end as data_status,

        -- =========================================================
        -- 3) PROVIDER LIMIT STATUS
        -- =========================================================
        case
            when x.enabled = false then 'DISABLED'

            when x.sport_code = 'FB'
                 and x.provider = 'api_football'
                 and x.entity = 'players'
                then 'PLAN_LIMITED'

            when x.provider in ('api_hockey','api_volleyball','api_handball')
                 and x.entity in ('players','coaches')
                then 'PROVIDER_BLOCKED'

            when x.provider = 'football_data'
                 and x.entity not in ('leagues','teams','fixtures')
                then 'NOT_SUPPORTED'

            when x.provider in (
                    'api_american_football',
                    'api_baseball',
                    'api_cricket',
                    'api_darts',
                    'api_esports',
                    'api_field_hockey',
                    'api_mma',
                    'api_rugby',
                    'api_tennis'
                 )
                then 'NOT_VALIDATED'

            else 'OK_OR_UNKNOWN'
        end as provider_limit_status

    from expanded x
),

finalized as (
    select
        c.*,

        -- =========================================================
        -- 4) RECOMMENDED MODE
        -- =========================================================
        case
            when c.tech_status = 'DISABLED'
                then 'KEEP_DISABLED'

            when c.provider = 'football_data'
                 and c.run_group = 'FB_FD_CORE'
                 and c.entity in ('leagues','teams','fixtures')
                then 'CORE_ACTIVE'

            when c.sport_code = 'FB'
                 and c.provider = 'api_football'
                 and c.entity in ('leagues','teams','fixtures','odds')
                then 'EXPAND_WHEN_READY'

            when c.sport_code = 'FB'
                 and c.provider = 'api_football'
                 and c.entity = 'players'
                then 'WAIT_PROVIDER_PLAN'

            when c.provider_limit_status = 'PROVIDER_BLOCKED'
                then 'BLOCKED'

            when c.tech_status = 'PARTIAL'
                then 'PREPARE_ONLY'

            when c.tech_status = 'SKELETON'
                then 'SKELETON_ONLY'

            else 'REVIEW'
        end as recommended_mode,

        -- =========================================================
        -- 5) NEXT BUILD STEP
        -- =========================================================
        case
            when c.tech_status = 'DISABLED'
                then 'DO_NOT_USE'

            when c.provider = 'football_data'
                 and c.run_group = 'FB_FD_CORE'
                 and c.entity = 'leagues'
                then 'USE_AS_REFERENCE_CORE'

            when c.provider = 'football_data'
                 and c.run_group = 'FB_FD_CORE'
                 and c.entity = 'teams'
                then 'USE_AS_REFERENCE_CORE'

            when c.provider = 'football_data'
                 and c.run_group = 'FB_FD_CORE'
                 and c.entity = 'fixtures'
                then 'USE_AS_REFERENCE_CORE'

            when c.sport_code = 'FB'
                 and c.provider = 'api_football'
                 and c.entity in ('leagues','teams','fixtures')
                then 'ALIGN_WITH_PLANNER_MODEL'

            when c.sport_code = 'FB'
                 and c.provider = 'api_football'
                 and c.entity = 'odds'
                then 'LINK_TO_MATCH_CORE'

            when c.sport_code = 'FB'
                 and c.provider = 'api_football'
                 and c.entity = 'players'
                then 'WAIT_OR_ADD_ALT_PROVIDER'

            when c.sport_code = 'HK'
                 and c.provider = 'api_hockey'
                 and c.entity in ('leagues','teams','fixtures')
                then 'NORMALIZE_TO_CORE_MODEL'

            when c.sport_code = 'HK'
                 and c.provider = 'api_hockey'
                 and c.entity = 'odds'
                then 'PREPARE_MATCH_LINKING'

            when c.sport_code = 'HK'
                 and c.entity in ('players','coaches')
                then 'MARK_PROVIDER_BLOCKED'

            when c.sport_code = 'BK'
                 and c.provider = 'api_sport'
                 and c.entity in ('leagues','teams','fixtures','odds')
                then 'STANDARDIZE_AND_VALIDATE'

            when c.sport_code = 'VB'
                 and c.provider = 'api_volleyball'
                 and c.entity in ('leagues','teams','fixtures','odds')
                then 'KEEP_AS_MINIMAL_PREP'

            when c.provider in (
                    'api_american_football',
                    'api_baseball',
                    'api_cricket',
                    'api_darts',
                    'api_esports',
                    'api_field_hockey',
                    'api_mma',
                    'api_rugby',
                    'api_tennis'
                 )
                then 'LEAVE_AS_SKELETON'

            else 'MANUAL_REVIEW'
        end as next_build_step

    from classified c
)

-- =========================================================
-- 1) Agregace: SPORT × PROVIDER × ENTITY
-- =========================================================
select
    sport_code as sport,
    provider,
    entity,
    tech_status,
    data_status,
    provider_limit_status,
    recommended_mode,
    next_build_step,
    count(*) as rows_count
from finalized
group by
    sport_code,
    provider,
    entity,
    tech_status,
    data_status,
    provider_limit_status,
    recommended_mode,
    next_build_step
order by
    sport_code,
    provider,
    entity,
    recommended_mode,
    tech_status;

-- =========================================================
-- 2) Detail
-- =========================================================
select
    sport_code as sport,
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
    enabled,
    tech_status,
    data_status,
    provider_limit_status,
    recommended_mode,
    next_build_step
from finalized
order by
    sport_code,
    provider,
    entity,
    canonical_league_name,
    season;