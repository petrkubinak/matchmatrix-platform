-- 597_seed_sport_completion_audit.sql
-- Seed reálného completion stavu sportů na základě auditu

insert into ops.sport_completion_audit (
    sport_code,
    entity,
    layer_type,
    current_status,
    production_readiness,
    provider_primary,
    provider_fallback,
    db_layer_ready,
    planner_ready,
    queue_ready,
    public_ready,
    key_gap,
    next_step,
    evidence_note,
    priority_rank
)

-- =========================
-- FOOTBALL (FB)
-- =========================

-- FB fixtures (CORE HOTOVO)
select
    'FB',
    'fixtures',
    'core',
    'DONE',
    'READY',
    'api_football',
    'football_data',
    true,
    true,
    true,
    true,
    null,
    null,
    'Fixtures plně funkční, merge + downstream OK',
    1

union all

-- FB odds (PRODUCTION OK)
select
    'FB',
    'odds',
    'extension',
    'DONE',
    'READY',
    'theodds',
    null,
    true,
    true,
    true,
    true,
    'Matching není 100% (NO_MATCH_ID)',
    'Pokračovat v linker zlepšení',
    'Odds ingest běží, attach funguje s fallback logikou',
    2

union all

-- FB players (PARTIAL)
select
    'FB',
    'players',
    'people',
    'PARTIAL',
    'NEAR_READY',
    'api_football',
    null,
    true,
    false,
    false,
    false,
    'Není plné coverage + složitý harvest',
    'Definovat finální harvest model (liga/sezona)',
    'Endpoint funguje, ale coverage omezená',
    10

union all

-- FB coaches (NOVĚ potvrzeno)
select
    'FB',
    'coachs',
    'people',
    'PARTIAL',
    'NEAR_READY',
    'api_football',
    null,
    false,
    false,
    false,
    false,
    'Chybí mapování coach → team',
    'Doplnit mapping vrstvu',
    'Endpoint existuje + vrací data, mapping FAIL',
    11

-- =========================
-- HOCKEY (HK)
-- =========================

union all

-- HK fixtures (CORE OK)
select
    'HK',
    'fixtures',
    'core',
    'DONE',
    'READY',
    'api_hockey',
    null,
    true,
    true,
    true,
    true,
    null,
    null,
    'Leagues/teams/fixtures funkční',
    20

union all

-- HK players (BLOCKED)
select
    'HK',
    'players',
    'people',
    'BLOCKED',
    'NOT_READY',
    'api_hockey',
    null,
    false,
    false,
    false,
    false,
    'Endpoint neexistuje',
    'Najít jiného providera',
    'API-Sports players neexistuje pro hockey',
    21

union all

-- HK coaches (UNKNOWN)
select
    'HK',
    'coachs',
    'people',
    'WAIT_PROVIDER',
    'NOT_READY',
    'api_hockey',
    null,
    false,
    false,
    false,
    false,
    'Neověřený endpoint',
    'Uděláme reality check',
    'Tech_ready stopa, ale bez potvrzení',
    22

-- =========================
-- BASKETBALL (BK)
-- =========================

union all

-- BK core (částečně OK)
select
    'BK',
    'fixtures',
    'core',
    'VALIDATE',
    'NEAR_READY',
    'api_sport',
    'api_basketball',
    true,
    true,
    true,
    false,
    'Menší coverage + test režim',
    'Doběhnout validation run',
    'Základ funguje, ale není plně stabilní',
    30

union all

-- BK players (BLOCKED)
select
    'BK',
    'players',
    'people',
    'BLOCKED',
    'NOT_READY',
    'api_sport',
    null,
    false,
    false,
    false,
    false,
    'Vrací 0 dat',
    'Najít jiného providera',
    'API endpoint existuje, ale prázdný',
    31

union all

-- BK coaches (UNKNOWN)
select
    'BK',
    'coaches',
    'people',
    'WAIT_PROVIDER',
    'NOT_READY',
    'api_sport',
    null,
    false,
    false,
    false,
    false,
    'Neověřený endpoint',
    'Reality check',
    'Zatím bez důkazu použitelnosti',
    32

-- =========================
-- VOLLEYBALL (VB)
-- =========================

union all

-- VB fixtures (DONE)
select
    'VB',
    'fixtures',
    'core',
    'DONE',
    'READY',
    'api_volleyball',
    null,
    true,
    true,
    true,
    true,
    null,
    null,
    'Fixtures fungují',
    40

union all

-- VB players (BLOCKED)
select
    'VB',
    'players',
    'people',
    'BLOCKED',
    'NOT_READY',
    'api_volleyball',
    null,
    false,
    false,
    false,
    false,
    'Bez dat',
    'Najít provider',
    'Players endpoint neexistuje',
    41

union all

-- VB coaches (UNKNOWN)
select
    'VB',
    'coachs',
    'people',
    'WAIT_PROVIDER',
    'NOT_READY',
    'api_volleyball',
    null,
    false,
    false,
    false,
    false,
    'Neověřený endpoint',
    'Reality check',
    'Zatím bez dat',
    42;