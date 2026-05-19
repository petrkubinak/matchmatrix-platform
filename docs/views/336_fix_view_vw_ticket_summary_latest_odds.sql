-- =====================================================================================
-- SOUBOR: 336_fix_view_vw_ticket_summary_latest_odds.sql
-- KAM ULOŽIT: C:\MatchMatrix-platform\db\views\336_fix_view_vw_ticket_summary_latest_odds.sql
-- ÚČEL:
--   Oprava view public.vw_ticket_summary:
--   - total_odd bude počítán ze stejné odds logiky jako UI
--   - použije se latest odds per (match_id, market_outcome_id, bookmaker_id)
-- =====================================================================================

create or replace view public.vw_ticket_summary as
with item_base as (
    select
        vtsd.run_id,
        vtsd.ticket_index,
        vtsd.match_id,
        vtsd.market_outcome_id,
        vtsd.item_result_status
    from public.vw_ticket_settlement_detail vtsd
),

latest_odds as (
    select distinct on (o.match_id, o.market_outcome_id, o.bookmaker_id)
        o.match_id,
        o.market_outcome_id,
        o.bookmaker_id,
        o.odd_value,
        o.collected_at
    from public.odds o
    where o.odd_value is not null
      and o.odd_value > 0
    order by
        o.match_id,
        o.market_outcome_id,
        o.bookmaker_id,
        o.collected_at desc nulls last,
        o.odd_value desc
),

item_odds as (
    select
        ib.run_id,
        ib.ticket_index,
        ib.match_id,
        ib.market_outcome_id,
        ib.item_result_status,
        gr.bookmaker_id,
        lo.odd_value
    from item_base ib
    join public.generated_runs gr
      on gr.id = ib.run_id
    left join latest_odds lo
      on lo.match_id = ib.match_id
     and lo.market_outcome_id = ib.market_outcome_id
     and lo.bookmaker_id = gr.bookmaker_id
),

agg as (
    select
        io.run_id,
        io.ticket_index,
        count(*)::integer as matches_count,
        count(*) filter (where io.item_result_status = 'hit')::integer as hits_count,
        count(*) filter (where io.item_result_status = 'miss')::integer as miss_count,
        count(*) filter (where io.item_result_status = 'void')::integer as void_count,
        count(*) filter (where io.item_result_status = 'pending')::integer as pending_count,
        case
            when count(*) filter (where io.odd_value is null) > 0 then null::numeric
            else round(exp(sum(ln(io.odd_value))), 4)
        end as total_odd
    from item_odds io
    group by io.run_id, io.ticket_index
)

select
    run_id,
    ticket_index,
    matches_count,
    hits_count,
    miss_count,
    void_count,
    pending_count,
    total_odd,
    case
        when pending_count > 0 then 'pending'
        when miss_count > 0 then 'miss'
        when hits_count > 0 and void_count > 0 then 'partial'
        when hits_count = matches_count then 'hit'
        when void_count = matches_count then 'void'
        else 'pending'
    end as ticket_result_status
from agg
order by run_id, ticket_index;