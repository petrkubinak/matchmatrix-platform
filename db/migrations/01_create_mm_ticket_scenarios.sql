-- =====================================================
-- MatchMatrix
-- Tabulka: mm_ticket_scenarios
--
-- Účel:
--   Centrální hlavička pro historii tiketových scénářů.
--   Uloží:
--   - jaký režim byl použit (classic / blocks / scenario)
--   - kolik bloků a zápasů bylo použito
--   - kolik variant vzniklo
--   - kolik variant bylo skutečně vsazeno
--   - souhrnné pravděpodobnosti / kurzy / výsledky
--
-- Poznámka:
--   Detail variant a detail zápasů budeme ukládat
--   do navazujících tabulek v dalších krocích.
-- =====================================================

create table if not exists public.mm_ticket_scenarios (
    id bigserial primary key,

    -- Vazba na existující runtime engine
    generated_run_id bigint null references public.generated_runs(id) on delete set null,

    -- Režim produktu
    scenario_mode text not null,
    constraint chk_mm_ticket_scenarios_mode
        check (scenario_mode in ('classic', 'blocks', 'scenario')),

    -- Volitelný název scénáře / setu
    scenario_name text null,

    -- Struktura tiketu
    blocks_count integer not null default 0,
    matches_count integer not null default 0,
    variants_generated integer not null default 0,
    variants_selected integer not null default 0,

    -- Uživatelské rozhodnutí
    user_selected_manually boolean not null default true,
    auto_suggestion_used boolean not null default false,

    -- Souhrnná matematika
    estimated_hit_probability numeric(12,6) null,
    estimated_total_ev numeric(12,6) null,
    avg_ticket_odd numeric(12,6) null,
    max_ticket_odd numeric(12,6) null,
    min_ticket_odd numeric(12,6) null,

    -- Finální stav po vyhodnocení
    settlement_status text not null default 'pending',
    constraint chk_mm_ticket_scenarios_settlement_status
        check (settlement_status in ('pending', 'partial', 'settled', 'cancelled')),

    tickets_won_count integer not null default 0,
    tickets_lost_count integer not null default 0,
    tickets_void_count integer not null default 0,

    -- Finance
    total_stake numeric(12,2) null,
    total_return numeric(12,2) null,
    total_profit numeric(12,2) null,
    roi_percent numeric(12,4) null,

    -- Metadata / audit
    source_note text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- =====================================================
-- Indexy
-- =====================================================

create index if not exists ix_mm_ticket_scenarios_generated_run_id
    on public.mm_ticket_scenarios(generated_run_id);

create index if not exists ix_mm_ticket_scenarios_mode
    on public.mm_ticket_scenarios(scenario_mode);

create index if not exists ix_mm_ticket_scenarios_settlement_status
    on public.mm_ticket_scenarios(settlement_status);

create index if not exists ix_mm_ticket_scenarios_created_at
    on public.mm_ticket_scenarios(created_at desc);

-- =====================================================
-- Trigger updated_at
-- =====================================================

drop trigger if exists trg_mm_ticket_scenarios_set_updated_at
    on public.mm_ticket_scenarios;

create trigger trg_mm_ticket_scenarios_set_updated_at
before update on public.mm_ticket_scenarios
for each row
execute function public.set_updated_at();