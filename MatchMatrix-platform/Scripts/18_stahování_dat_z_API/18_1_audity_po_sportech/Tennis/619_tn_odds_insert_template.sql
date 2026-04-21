-- 619_tn_odds_insert_template.sql
-- Účel:
-- Testovací šablona pro TN odds insert do public.odds
-- Mapování:
-- match_winner HOME = 10
-- match_winner AWAY = 11

-- --------------------------------------------------
-- 1) Najdi testovací TN match
-- --------------------------------------------------
select
    id as match_id,
    ext_match_id,
    ext_source,
    sport_id,
    status
from public.matches
where ext_source = 'api_tennis'
order by id desc
limit 20;

-- --------------------------------------------------
-- 2) Ověř bookmaker_id
-- --------------------------------------------------
select
    id as bookmaker_id,
    name
from public.bookmakers
where name in ('Tipsport', 'Fortuna', 'Pinnacle', 'Bet365', 'Betfair')
order by name;

-- --------------------------------------------------
-- 3) TEST INSERT
-- Nahraď:
--   362385 = skutečné match_id
--   2      = bookmaker_id (např. Tipsport)
-- --------------------------------------------------

insert into public.odds
    (match_id, bookmaker_id, market_outcome_id, odd_value, collected_at)
values
    (362385, 2, 10, 1.85, now()), -- HOME / player1
    (362385, 2, 11, 1.95, now()); -- AWAY / player2

-- --------------------------------------------------
-- 4) KONTROLA
-- --------------------------------------------------
select
    o.id,
    o.match_id,
    b.name as bookmaker,
    o.market_outcome_id,
    mo.code as outcome_code,
    mo.label as outcome_label,
    o.odd_value,
    o.collected_at
from public.odds o
join public.bookmakers b
    on b.id = o.bookmaker_id
join public.market_outcomes mo
    on mo.id = o.market_outcome_id
where o.match_id = 362385
order by o.id desc;