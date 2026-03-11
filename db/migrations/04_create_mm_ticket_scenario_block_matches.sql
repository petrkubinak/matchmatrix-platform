-- =====================================================
-- MatchMatrix
-- Tabulka: mm_ticket_scenario_block_matches
--
-- Účel:
--   Propojuje blok scénáře s konkrétními zápasy.
--
-- Příklad:
--   scénář 17
--
--   blok A
--     match 101
--     match 102
--
--   blok B
--     match 205
--     match 206
--
--   blok C
--     match 310
--     match 311
--
-- =====================================================

create table if not exists public.mm_ticket_scenario_block_matches (

    id bigserial primary key,

    -- vazba na blok
    block_id bigint not null
        references public.mm_ticket_scenario_blocks(id)
        on delete cascade,

    -- vazba na zápas
    match_id bigint not null
        references public.matches(id)
        on delete cascade,

    -- pořadí zápasu v bloku
    match_index integer not null,

    -- odds podle outcome bloku
    odds numeric(12,4) null,

    -- model probability
    model_probability numeric(12,6) null,

    -- edge
    edge numeric(12,6) null,

    -- EV
    ev numeric(12,6) null,

    created_at timestamptz not null default now()
);

-- =====================================================
-- Indexy
-- =====================================================

create index if not exists ix_mm_block_matches_block
    on public.mm_ticket_scenario_block_matches(block_id);

create index if not exists ix_mm_block_matches_match
    on public.mm_ticket_scenario_block_matches(match_id);

-- zabrání duplicitě zápasu v bloku
create unique index if not exists ux_mm_block_match_unique
    on public.mm_ticket_scenario_block_matches(block_id, match_id);