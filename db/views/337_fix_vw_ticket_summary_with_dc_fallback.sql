-- =====================================================================================
-- SOUBOR: 337_fix_vw_ticket_summary_with_dc_fallback.sql
-- KAM ULOŽIT: C:\MatchMatrix-platform\db\views\337_fix_vw_ticket_summary_with_dc_fallback.sql
-- ÚČEL:
--   Oprava public.vw_ticket_summary:
--   - pro fyzicky dostupné odds použije uložený kurz
--   - pro DC (1X / 12 / X2), když free účet nemá uložený kurz, dopočítá fallback
--     z posledních 1 / X / 2 kurzů stejně jako Ticket Studio UI
-- =====================================================================================

create or replace view public.vw_ticket_summary as
with item_base as (
    select
        vtsd.run_id,
        vtsd.ticket_index,
        vtsd.match_id,
        vtsd.market_outcome_id,
        vtsd.picked_outcome_code,
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

direct_item_odds as (
    select
        ib.run_id,
        ib.ticket_index,
        ib.match_id,
        ib.market_outcome_id,
        ib.picked_outcome_code,
        ib.item_result_status,
        gr.bookmaker_id,
        lo.odd_value as direct_odd_value
    from item_base ib
    join public.generated_runs gr
      on gr.id = ib.run_id
    left join latest_odds lo
      on lo.match_id = ib.match_id
     and lo.market_outcome_id = ib.market_outcome_id
     and lo.bookmaker_id = gr.bookmaker_id
),

h2h_latest as (
    select
        o.match_id,
        o.bookmaker_id,
        max(case when mo.code = '1' then o.odd_value end) as odd_1,
        max(case when mo.code = 'X' then o.odd_value end) as odd_x,
        max(case when mo.code = '2' then o.odd_value end) as odd_2
    from latest_odds o
    join public.market_outcomes mo
      on mo.id = o.market_outcome_id
    join public.markets mk
      on mk.id = mo.market_id
    where lower(mk.code) in ('h2h', '1x2')
      and mo.code in ('1', 'X', '2')
    group by o.match_id, o.bookmaker_id
),

item_odds as (
    select
        dio.run_id,
        dio.ticket_index,
        dio.match_id,
        dio.market_outcome_id,
        dio.picked_outcome_code,
        dio.item_result_status,
        dio.bookmaker_id,
        coalesce(
            dio.direct_odd_value,
            case
                when dio.picked_outcome_code = '1X'
                     and h.odd_1 is not null and h.odd_x is not null and h.odd_2 is not null
                then
                    (
                        ((1.0 / h.odd_1) + (1.0 / h.odd_x) + (1.0 / h.odd_2))
                        /
                        ((1.0 / h.odd_1) + (1.0 / h.odd_x))
                    )::numeric

                when dio.picked_outcome_code = '12'
                     and h.odd_1 is not null and h.odd_x is not null and h.odd_2 is not null
                then
                    (
                        ((1.0 / h.odd_1) + (1.0 / h.odd_x) + (1.0 / h.odd_2))
                        /
                        ((1.0 / h.odd_1) + (1.0 / h.odd_2))
                    )::numeric

                when dio.picked_outcome_code = 'X2'
                     and h.odd_1 is not null and h.odd_x is not null and h.odd_2 is not null
                then
                    (
                        ((1.0 / h.odd_1) + (1.0 / h.odd_x) + (1.0 / h.odd_2))
                        /
                        ((1.0 / h.odd_x) + (1.0 / h.odd_2))
                    )::numeric

                else null::numeric
            end
        ) as odd_value
    from direct_item_odds dio
    left join h2h_latest h
      on h.match_id = dio.match_id
     and h.bookmaker_id = dio.bookmaker_id
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