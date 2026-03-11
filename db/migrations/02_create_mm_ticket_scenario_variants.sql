-- =====================================================
-- MatchMatrix
-- Tabulka: mm_ticket_scenario_variants
--
-- Účel:
--   Ukládá jednotlivé varianty tiketů v rámci scénáře.
--
-- Příklad:
--   scénář má 3 bloky
--   → vznikne 27 variant
--
--   1-1-1
--   1-1-X
--   1-1-2
--   ...
--   2-2-2
--
-- Každá varianta má:
--   - vlastní kurz
--   - vlastní pravděpodobnost
--   - vlastní EV
--   - vlastní stake
-- =====================================================

create table if not exists public.mm_ticket_scenario_variants (

    id bigserial primary key,

    -- vazba na scénář
    scenario_id bigint not null
        references public.mm_ticket_scenarios(id)
        on delete cascade,

    -- pořadí varianty
    variant_index integer not null,

    -- struktura varianty (např. 1-X-2)
    variant_code text not null,

    -- počet bloků
    blocks_count integer not null,

    -- matematika varianty
    estimated_probability numeric(12,6) null,
    estimated_ev numeric(12,6) null,

    -- kurz celé varianty
    combined_odds numeric(12,4) null,

    -- stake
    stake numeric(12,2) null,

    -- výsledek
    settlement_status text not null default 'pending',
    constraint chk_mm_ticket_variant_settlement
        check (settlement_status in ('pending','won','lost','void')),

    payout numeric(12,2) null,
    profit numeric(12,2) null,

    -- metadata
    was_selected boolean not null default true,

    created_at timestamptz not null default now()
);

-- =====================================================
-- Indexy
-- =====================================================

create index if not exists ix_mm_ticket_variant_scenario
    on public.mm_ticket_scenario_variants(scenario_id);

create index if not exists ix_mm_ticket_variant_status
    on public.mm_ticket_scenario_variants(settlement_status);

create index if not exists ix_mm_ticket_variant_code
    on public.mm_ticket_scenario_variants(variant_code);