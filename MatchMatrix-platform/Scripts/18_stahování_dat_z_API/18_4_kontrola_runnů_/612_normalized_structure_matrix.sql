-- =====================================================================
-- 612_normalized_structure_matrix.sql
-- MatchMatrix - normalized structure matrix
--
-- Cíl:
--   1) přestat hodnotit sporty jako "skeleton jen proto, že nemají data"
--   2) hodnotit systémovou připravenost napříč sporty stejně
--   3) oddělit core / odds / people provider role
--   4) připravit mapu pro multi-provider build
--
-- DŮLEŽITÉ:
--   Tento skript je lehký, bez heavy runtime coverage subquery.
--   Hodnotí hlavně architekturu a připravenost pipeline/OPS modelu.
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

        -- =====================================================
        -- provider_role
        -- =====================================================
        case
            when x.entity in ('leagues', 'teams', 'fixtures') then 'CORE_PROVIDER'
            when x.entity = 'odds' then 'ODDS_PROVIDER'
            when x.entity in ('players', 'coaches') then 'PEOPLE_PROVIDER'
            else 'UNKNOWN_PROVIDER_ROLE'
        end as provider_role,

        -- =====================================================
        -- structure_status
        -- =====================================================
        case
            when x.enabled = false then 'DISABLED'

            -- football reference core
            when x.sport_code = 'FB'
                 and x.provider = 'football_data'
                 and x.entity in ('leagues', 'teams', 'fixtures')
                then 'REFERENCE_CORE'

            -- football api_football broad operational layer
            when x.sport_code = 'FB'
                 and x.provider = 'api_football'
                 and x.entity in ('leagues', 'teams', 'fixtures', 'odds', 'players')
                then 'STRUCTURE_READY'

            -- hockey core/odds
            when x.sport_code = 'HK'
                 and x.provider = 'api_hockey'
                 and x.entity in ('leagues', 'teams', 'fixtures', 'odds')
                then 'STRUCTURE_READY'

            when x.sport_code = 'HK'
                 and x.provider = 'api_hockey'
                 and x.entity in ('players', 'coaches')
                then 'STRUCTURE_READY'

            -- basketball
            when x.sport_code = 'BK'
                 and x.provider = 'api_sport'
                 and x.entity in ('leagues', 'teams', 'fixtures', 'odds')
                then 'STRUCTURE_READY'

            when x.sport_code = 'BK'
                 and x.provider = 'api_sport'
                 and x.entity in ('players', 'coaches')
                then 'STRUCTURE_READY'

            -- volleyball
            when x.sport_code = 'VB'
                 and x.provider = 'api_volleyball'
                 and x.entity in ('leagues', 'teams', 'fixtures', 'odds')
                then 'STRUCTURE_READY'

            when x.sport_code = 'VB'
                 and x.provider = 'api_volleyball'
                 and x.entity in ('players', 'coaches')
                then 'STRUCTURE_READY'

            -- handball
            when x.sport_code = 'HB'
                 and x.provider = 'api_handball'
                then 'STRUCTURE_READY'

            -- remaining sports with ingest target inventory present
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
                then 'STRUCTURE_PARTIAL'

            else 'STRUCTURE_REVIEW'
        end as structure_status,

        -- =====================================================
        -- provider_status
        -- =====================================================
        case
            when x.enabled = false then 'DISABLED'

            -- football_data only supports core reference scope
            when x.provider = 'football_data'
                 and x.entity in ('leagues', 'teams', 'fixtures')
                then 'ACTIVE_PROVIDER'

            when x.provider = 'football_data'
                 and x.entity in ('odds', 'players', 'coaches')
                then 'ALT_PROVIDER_NEEDED'

            -- api_football players are plan-limited, not structurally missing
            when x.sport_code = 'FB'
                 and x.provider = 'api_football'
                 and x.entity = 'players'
                then 'PROVIDER_LIMITED'

            -- sports where people endpoints are missing / unsuitable
            when x.provider in ('api_hockey', 'api_volleyball', 'api_handball')
                 and x.entity in ('players', 'coaches')
                then 'ALT_PROVIDER_NEEDED'

            -- active providers for main operational layers
            when x.provider in ('api_football', 'api_hockey', 'api_sport', 'api_volleyball')
                 and x.entity in ('leagues', 'teams', 'fixtures', 'odds')
                then 'ACTIVE_PROVIDER'

            -- sports not yet validated deeply
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

            else 'REVIEW_PROVIDER'
        end as provider_status,

        -- =====================================================
        -- build_mode
        -- =====================================================
        case
            when x.enabled = false then 'KEEP_DISABLED'

            when x.provider = 'football_data'
                 and x.entity in ('leagues', 'teams', 'fixtures')
                then 'REFERENCE_CORE'

            when x.provider = 'api_football'
                 and x.entity in ('leagues', 'teams', 'fixtures', 'odds')
                then 'EXPAND_CORE'

            when x.provider = 'api_football'
                 and x.entity = 'players'
                then 'PREPARE_ALT_PROVIDER'

            when x.provider = 'api_hockey'
                 and x.entity in ('leagues', 'teams', 'fixtures', 'odds')
                then 'EXPAND_CORE'

            when x.provider = 'api_hockey'
                 and x.entity in ('players', 'coaches')
                then 'PREPARE_ALT_PROVIDER'

            when x.provider = 'api_sport'
                 and x.sport_code = 'BK'
                 and x.entity in ('leagues', 'teams', 'fixtures', 'odds')
                then 'EXPAND_CORE'

            when x.provider = 'api_sport'
                 and x.sport_code = 'BK'
                 and x.entity in ('players', 'coaches')
                then 'PREPARE_ALT_PROVIDER'

            when x.provider = 'api_volleyball'
                 and x.entity in ('leagues', 'teams', 'fixtures', 'odds')
                then 'EXPAND_CORE'

            when x.provider = 'api_volleyball'
                 and x.entity in ('players', 'coaches')
                then 'PREPARE_ALT_PROVIDER'

            when x.provider = 'api_handball'
                 and x.entity in ('leagues', 'teams', 'fixtures', 'odds')
                then 'EXPAND_CORE'

            when x.provider = 'api_handball'
                 and x.entity in ('players', 'coaches')
                then 'PREPARE_ALT_PROVIDER'

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
                then 'PREPARE_STRUCTURE'

            else 'MANUAL_REVIEW'
        end as build_mode,

        -- =====================================================
        -- next_build_step
        -- =====================================================
        case
            when x.enabled = false then 'DO_NOT_USE'

            when x.provider = 'football_data'
                 and x.entity in ('leagues', 'teams', 'fixtures')
                then 'KEEP_AS_REFERENCE_BASELINE'

            when x.provider = 'api_football'
                 and x.entity in ('leagues', 'teams', 'fixtures')
                then 'ALIGN_TO_REFERENCE_CORE'

            when x.provider = 'api_football'
                 and x.entity = 'odds'
                then 'KEEP_MATCH_LINK_READY'

            when x.provider = 'api_football'
                 and x.entity = 'players'
                then 'DEFINE_ALT_PEOPLE_PROVIDER'

            when x.provider = 'api_hockey'
                 and x.entity in ('leagues', 'teams', 'fixtures')
                then 'NORMALIZE_TO_SHARED_CORE_MODEL'

            when x.provider = 'api_hockey'
                 and x.entity = 'odds'
                then 'PREPARE_SHARED_ODDS_MODEL'

            when x.provider = 'api_hockey'
                 and x.entity in ('players', 'coaches')
                then 'ADD_ALT_PEOPLE_PROVIDER_SLOT'

            when x.provider = 'api_sport'
                 and x.sport_code = 'BK'
                 and x.entity in ('leagues', 'teams', 'fixtures')
                then 'STANDARDIZE_PARSER_AND_STAGING'

            when x.provider = 'api_sport'
                 and x.sport_code = 'BK'
                 and x.entity = 'odds'
                then 'STANDARDIZE_ODDS_LINKING'

            when x.provider = 'api_sport'
                 and x.sport_code = 'BK'
                 and x.entity in ('players', 'coaches')
                then 'ADD_ALT_PEOPLE_PROVIDER_SLOT'

            when x.provider = 'api_volleyball'
                 and x.entity in ('leagues', 'teams', 'fixtures')
                then 'STANDARDIZE_PARSER_AND_STAGING'

            when x.provider = 'api_volleyball'
                 and x.entity = 'odds'
                then 'STANDARDIZE_ODDS_LINKING'

            when x.provider = 'api_volleyball'
                 and x.entity in ('players', 'coaches')
                then 'ADD_ALT_PEOPLE_PROVIDER_SLOT'

            when x.provider = 'api_handball'
                 and x.entity in ('leagues', 'teams', 'fixtures', 'odds')
                then 'PREPARE_SHARED_SPORT_MODEL'

            when x.provider = 'api_handball'
                 and x.entity in ('players', 'coaches')
                then 'ADD_ALT_PEOPLE_PROVIDER_SLOT'

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
                then 'PREPARE_PROVIDER_CONTRACT'

            else 'MANUAL_REVIEW'
        end as next_build_step

    from expanded x
),

finalized as (
    select
        sport_code as sport,
        provider,
        entity,
        provider_role,
        structure_status,
        provider_status,
        build_mode,
        next_build_step,
        ingest_target_id,
        canonical_league_id,
        canonical_league_name,
        canonical_country,
        provider_league_id,
        season,
        tier,
        run_group,
        enabled
    from classified
)

select
    sport,
    provider,
    entity,
    provider_role,
    structure_status,
    provider_status,
    build_mode,
    next_build_step,
    count(*) as rows_count
from finalized
group by
    sport,
    provider,
    entity,
    provider_role,
    structure_status,
    provider_status,
    build_mode,
    next_build_step
order by
    sport,
    provider,
    entity,
    build_mode,
    structure_status;

-- =========================================================
-- 2) Detail
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
        case
            when x.entity in ('leagues', 'teams', 'fixtures') then 'CORE_PROVIDER'
            when x.entity = 'odds' then 'ODDS_PROVIDER'
            when x.entity in ('players', 'coaches') then 'PEOPLE_PROVIDER'
            else 'UNKNOWN_PROVIDER_ROLE'
        end as provider_role,

        case
            when x.enabled = false then 'DISABLED'
            when x.sport_code = 'FB' and x.provider = 'football_data' and x.entity in ('leagues', 'teams', 'fixtures') then 'REFERENCE_CORE'
            when x.sport_code = 'FB' and x.provider = 'api_football' and x.entity in ('leagues', 'teams', 'fixtures', 'odds', 'players') then 'STRUCTURE_READY'
            when x.sport_code = 'HK' and x.provider = 'api_hockey' and x.entity in ('leagues', 'teams', 'fixtures', 'odds') then 'STRUCTURE_READY'
            when x.sport_code = 'HK' and x.provider = 'api_hockey' and x.entity in ('players', 'coaches') then 'STRUCTURE_READY'
            when x.sport_code = 'BK' and x.provider = 'api_sport' and x.entity in ('leagues', 'teams', 'fixtures', 'odds') then 'STRUCTURE_READY'
            when x.sport_code = 'BK' and x.provider = 'api_sport' and x.entity in ('players', 'coaches') then 'STRUCTURE_READY'
            when x.sport_code = 'VB' and x.provider = 'api_volleyball' and x.entity in ('leagues', 'teams', 'fixtures', 'odds') then 'STRUCTURE_READY'
            when x.sport_code = 'VB' and x.provider = 'api_volleyball' and x.entity in ('players', 'coaches') then 'STRUCTURE_READY'
            when x.sport_code = 'HB' and x.provider = 'api_handball' then 'STRUCTURE_READY'
            when x.provider in ('api_american_football','api_baseball','api_cricket','api_darts','api_esports','api_field_hockey','api_mma','api_rugby','api_tennis') then 'STRUCTURE_PARTIAL'
            else 'STRUCTURE_REVIEW'
        end as structure_status,

        case
            when x.enabled = false then 'DISABLED'
            when x.provider = 'football_data' and x.entity in ('leagues', 'teams', 'fixtures') then 'ACTIVE_PROVIDER'
            when x.provider = 'football_data' and x.entity in ('odds', 'players', 'coaches') then 'ALT_PROVIDER_NEEDED'
            when x.sport_code = 'FB' and x.provider = 'api_football' and x.entity = 'players' then 'PROVIDER_LIMITED'
            when x.provider in ('api_hockey', 'api_volleyball', 'api_handball') and x.entity in ('players', 'coaches') then 'ALT_PROVIDER_NEEDED'
            when x.provider in ('api_football', 'api_hockey', 'api_sport', 'api_volleyball') and x.entity in ('leagues', 'teams', 'fixtures', 'odds') then 'ACTIVE_PROVIDER'
            when x.provider in ('api_american_football','api_baseball','api_cricket','api_darts','api_esports','api_field_hockey','api_mma','api_rugby','api_tennis') then 'NOT_VALIDATED'
            else 'REVIEW_PROVIDER'
        end as provider_status,

        case
            when x.enabled = false then 'KEEP_DISABLED'
            when x.provider = 'football_data' and x.entity in ('leagues', 'teams', 'fixtures') then 'REFERENCE_CORE'
            when x.provider = 'api_football' and x.entity in ('leagues', 'teams', 'fixtures', 'odds') then 'EXPAND_CORE'
            when x.provider = 'api_football' and x.entity = 'players' then 'PREPARE_ALT_PROVIDER'
            when x.provider = 'api_hockey' and x.entity in ('leagues', 'teams', 'fixtures', 'odds') then 'EXPAND_CORE'
            when x.provider = 'api_hockey' and x.entity in ('players', 'coaches') then 'PREPARE_ALT_PROVIDER'
            when x.provider = 'api_sport' and x.sport_code = 'BK' and x.entity in ('leagues', 'teams', 'fixtures', 'odds') then 'EXPAND_CORE'
            when x.provider = 'api_sport' and x.sport_code = 'BK' and x.entity in ('players', 'coaches') then 'PREPARE_ALT_PROVIDER'
            when x.provider = 'api_volleyball' and x.entity in ('leagues', 'teams', 'fixtures', 'odds') then 'EXPAND_CORE'
            when x.provider = 'api_volleyball' and x.entity in ('players', 'coaches') then 'PREPARE_ALT_PROVIDER'
            when x.provider = 'api_handball' and x.entity in ('leagues', 'teams', 'fixtures', 'odds') then 'EXPAND_CORE'
            when x.provider = 'api_handball' and x.entity in ('players', 'coaches') then 'PREPARE_ALT_PROVIDER'
            when x.provider in ('api_american_football','api_baseball','api_cricket','api_darts','api_esports','api_field_hockey','api_mma','api_rugby','api_tennis') then 'PREPARE_STRUCTURE'
            else 'MANUAL_REVIEW'
        end as build_mode,

        case
            when x.enabled = false then 'DO_NOT_USE'
            when x.provider = 'football_data' and x.entity in ('leagues', 'teams', 'fixtures') then 'KEEP_AS_REFERENCE_BASELINE'
            when x.provider = 'api_football' and x.entity in ('leagues', 'teams', 'fixtures') then 'ALIGN_TO_REFERENCE_CORE'
            when x.provider = 'api_football' and x.entity = 'odds' then 'KEEP_MATCH_LINK_READY'
            when x.provider = 'api_football' and x.entity = 'players' then 'DEFINE_ALT_PEOPLE_PROVIDER'
            when x.provider = 'api_hockey' and x.entity in ('leagues', 'teams', 'fixtures') then 'NORMALIZE_TO_SHARED_CORE_MODEL'
            when x.provider = 'api_hockey' and x.entity = 'odds' then 'PREPARE_SHARED_ODDS_MODEL'
            when x.provider = 'api_hockey' and x.entity in ('players', 'coaches') then 'ADD_ALT_PEOPLE_PROVIDER_SLOT'
            when x.provider = 'api_sport' and x.sport_code = 'BK' and x.entity in ('leagues', 'teams', 'fixtures') then 'STANDARDIZE_PARSER_AND_STAGING'
            when x.provider = 'api_sport' and x.sport_code = 'BK' and x.entity = 'odds' then 'STANDARDIZE_ODDS_LINKING'
            when x.provider = 'api_sport' and x.sport_code = 'BK' and x.entity in ('players', 'coaches') then 'ADD_ALT_PEOPLE_PROVIDER_SLOT'
            when x.provider = 'api_volleyball' and x.entity in ('leagues', 'teams', 'fixtures') then 'STANDARDIZE_PARSER_AND_STAGING'
            when x.provider = 'api_volleyball' and x.entity = 'odds' then 'STANDARDIZE_ODDS_LINKING'
            when x.provider = 'api_volleyball' and x.entity in ('players', 'coaches') then 'ADD_ALT_PEOPLE_PROVIDER_SLOT'
            when x.provider = 'api_handball' and x.entity in ('leagues', 'teams', 'fixtures', 'odds') then 'PREPARE_SHARED_SPORT_MODEL'
            when x.provider = 'api_handball' and x.entity in ('players', 'coaches') then 'ADD_ALT_PEOPLE_PROVIDER_SLOT'
            when x.provider in ('api_american_football','api_baseball','api_cricket','api_darts','api_esports','api_field_hockey','api_mma','api_rugby','api_tennis') then 'PREPARE_PROVIDER_CONTRACT'
            else 'MANUAL_REVIEW'
        end as next_build_step
    from expanded x
),

finalized as (
    select
        sport_code as sport,
        provider,
        entity,
        provider_role,
        structure_status,
        provider_status,
        build_mode,
        next_build_step,
        ingest_target_id,
        canonical_league_id,
        canonical_league_name,
        canonical_country,
        provider_league_id,
        season,
        tier,
        run_group,
        enabled
    from classified
)

select
    sport,
    provider,
    entity,
    provider_role,
    structure_status,
    provider_status,
    build_mode,
    next_build_step,
    ingest_target_id,
    canonical_league_id,
    canonical_league_name,
    canonical_country,
    provider_league_id,
    season,
    tier,
    run_group,
    enabled
from finalized
order by
    sport,
    provider,
    entity,
    canonical_league_name,
    season;