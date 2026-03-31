-- =========================================================
-- MatchMatrix - DEBUG Blok A
-- Soubor: C:\MatchMatrix-platform\db\debug\debug_ticket_block_A_source.sql
-- Spouštět v DBeaveru
--
-- Cíl:
-- 1) ukázat, co je skutečně uložené v template_block_matches pro blok A
-- 2) ukázat, co vrací runtime pro konkrétní run
-- 3) ukázat detail pro ticket 1 / blok A
--
-- PŘED SPUŠTĚNÍM:
-- uprav si hodnoty v sekci PARAMS
-- =========================================================

-- ===== PARAMS =====
-- dosaď si svůj template_id a run_id
-- block_index = 1 znamená Blok A
with params as (
    select
        1::bigint  as template_id,   -- TODO: dosaď svůj template_id
        69::bigint as run_id,        -- TODO: dosaď svůj run_id
        1::int     as ticket_index,  -- první kombinace
        1::int     as block_index    -- Blok A
)

-- =========================================================
-- 1) Co je skutečně v template_block_matches pro Blok A
-- =========================================================
select
    'STEP_1_TEMPLATE_BLOCK_MATCHES' as step,
    tbm.template_id,
    tbm.block_index,
    tbm.match_id,
    tbm.market_id,
    m.kickoff,
    ht.name as home_team,
    at.name as away_team
from public.template_block_matches tbm
join params p
  on p.template_id = tbm.template_id
 and p.block_index = tbm.block_index
join public.matches m
  on m.id = tbm.match_id
join public.teams ht
  on ht.id = m.home_team_id
join public.teams at
  on at.id = m.away_team_id
order by m.kickoff, tbm.match_id;

-- =========================================================
-- 2) Kolik zápasů má každý blok v template
-- =========================================================
with params as (
    select
        1::bigint as template_id
)
select
    'STEP_2_BLOCK_COUNTS' as step,
    tbm.template_id,
    tbm.block_index,
    count(*) as matches_in_block
from public.template_block_matches tbm
join params p
  on p.template_id = tbm.template_id
group by tbm.template_id, tbm.block_index
order by tbm.block_index;

-- =========================================================
-- 3) Co vrací runtime pro celý run
-- =========================================================
with params as (
    select
        69::bigint as run_id
)
select
    'STEP_3_UI_RUN_TICKETS' as step,
    t.run_id,
    t.ticket_index,
    t.bookmaker_id,
    t.total_odd,
    t.items
from public.mm_ui_run_tickets((select run_id from params)) t
order by t.ticket_index;

-- =========================================================
-- 4) Rozbalení items pro ticket 1
-- =========================================================
with params as (
    select
        69::bigint as run_id,
        1::int     as ticket_index
),
tickets as (
    select *
    from public.mm_ui_run_tickets((select run_id from params))
    where ticket_index = (select ticket_index from params)
)
select
    'STEP_4_ITEMS_EXPANDED' as step,
    t.run_id,
    t.ticket_index,
    (x.item->>'block_index')::int as block_index,
    (x.item->>'match_id')::bigint as match_id,
    (x.item->>'market_outcome_id')::bigint as market_outcome_id,
    (x.item->>'odd')::numeric as odd_value
from tickets t
cross join lateral jsonb_array_elements(t.items) as x(item)
order by block_index, match_id, market_outcome_id;

-- =========================================================
-- 5) Jen Blok A pro ticket 1
-- =========================================================
with params as (
    select
        69::bigint as run_id,
        1::int     as ticket_index,
        1::int     as block_index
),
tickets as (
    select *
    from public.mm_ui_run_tickets((select run_id from params))
    where ticket_index = (select ticket_index from params)
)
select
    'STEP_5_BLOCK_A_ONLY' as step,
    t.run_id,
    t.ticket_index,
    (x.item->>'block_index')::int as block_index,
    (x.item->>'match_id')::bigint as match_id,
    (x.item->>'market_outcome_id')::bigint as market_outcome_id,
    (x.item->>'odd')::numeric as odd_value
from tickets t
cross join lateral jsonb_array_elements(t.items) as x(item)
where (x.item->>'block_index')::int = (select block_index from params)
order by match_id, market_outcome_id;

-- =========================================================
-- 6) Napojení Bloku A na názvy zápasů
-- =========================================================
with params as (
    select
        69::bigint as run_id,
        1::int     as ticket_index,
        1::int     as block_index
),
tickets as (
    select *
    from public.mm_ui_run_tickets((select run_id from params))
    where ticket_index = (select ticket_index from params)
),
items_expanded as (
    select
        (x.item->>'block_index')::int as block_index,
        (x.item->>'match_id')::bigint as match_id,
        (x.item->>'market_outcome_id')::bigint as market_outcome_id,
        (x.item->>'odd')::numeric as odd_value
    from tickets t
    cross join lateral jsonb_array_elements(t.items) as x(item)
    where (x.item->>'block_index')::int = (select block_index from params)
)
select
    'STEP_6_BLOCK_A_WITH_MATCH_NAMES' as step,
    i.block_index,
    i.match_id,
    ht.name as home_team,
    at.name as away_team,
    i.market_outcome_id,
    mo.code as outcome_code,
    i.odd_value
from items_expanded i
join public.matches m
  on m.id = i.match_id
join public.teams ht
  on ht.id = m.home_team_id
join public.teams at
  on at.id = m.away_team_id
left join public.market_outcomes mo
  on mo.id = i.market_outcome_id
order by i.match_id, mo.code;