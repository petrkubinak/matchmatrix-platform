-- =====================================================
-- MatchMatrix
-- Tabulka: mm_ticket_scenario_blocks
--
-- Účel:
--   Ukládá jednotlivé bloky v rámci scénáře.
--
-- Příklad:
--   scénář má 3 bloky
--
--   blok A → 2 zápasy
--   blok B → 2 zápasy
--   blok C → 2 zápasy
--
-- Každý blok má:
--   - typ outcome (1/X/2)
--   - počet zápasů
--   - kombinovaný kurz
--   - synchronizační důvod
--
-- Na blok pak navazuje tabulka zápasů v bloku.
-- =====================================================

create table if not exists public.mm_ticket_scenario_blocks (

    id bigserial primary key,

    -- vazba na scénář
    scenario_id bigint not null
        references public.mm_ticket_scenarios(id)
        on delete cascade,

    -- pořadí bloku
    block_index integer not null,

    -- outcome bloku
    block_outcome text not null,
    constraint chk_mm_ticket_block_outcome
        check (block_outcome in ('1','X','2')),

    -- kolik zápasů je v bloku
    matches_count integer not null,

    -- kombinovaný kurz bloku
    combined_odds numeric(12,4) null,

    -- pravděpodobnost bloku
    estimated_probability numeric(12,6) null,

    -- synchronizační skóre
    sync_score numeric(12,6) null,

    -- důvod synchronizace
    sync_reason_code text null,

    -- metadata
    created_at timestamptz not null default now()
);

-- =====================================================
-- Indexy
-- =====================================================

create index if not exists ix_mm_ticket_blocks_scenario
    on public.mm_ticket_scenario_blocks(scenario_id);

create index if not exists ix_mm_ticket_blocks_outcome
    on public.mm_ticket_scenario_blocks(block_outcome);