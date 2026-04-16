-- =====================================================================
-- 603_wave_planner_input.sql
-- MatchMatrix - WAVE planner input
-- =====================================================================

with base as (

    -- SEM vlož jako subquery celý SELECT z 602 (actions CTE nebo finální select)
    select *
    from (
        -- !!! TADY vlož SELECT z části "actions" nebo detail query !!!
    ) t

),

wave_classified as (
    select
        *,
        case
            -- 🔥 WAVE 1 = CORE FOOTBALL
            when sport = 'FB'
                 and provider in ('api_football', 'football_data')
                 and entity in ('leagues','teams','fixtures')
                 and final_status in ('CORE_READY','DATA_PRESENT_NOT_ORCHESTRATED')
                then 'WAVE_1'

            -- 🟡 WAVE 2 = EXPAND
            when final_status = 'EXPAND_READY'
                then 'WAVE_2'

            -- ⏳ WAIT
            when next_action = 'WAIT_FOR_PRO'
                then 'WAIT'

            -- ❌ SKIP
            else 'SKIP'
        end as wave

    from base
)

select
    wave,
    sport,
    provider,
    entity,
    canonical_league_id,
    canonical_league_name,
    season,
    final_status,
    next_action,
    fixtures_count,
    league_teams_count,
    odds_count,
    players_count,
    last_job_success_at
from wave_classified
where wave in ('WAVE_1','WAVE_2')
order by
    case wave
        when 'WAVE_1' then 1
        when 'WAVE_2' then 2
    end,
    sport,
    provider,
    entity,
    canonical_league_name;