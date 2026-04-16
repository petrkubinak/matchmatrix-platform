-- 589_create_ops_provider_people_audit.sql
-- Účel:
-- vytvořit auditní tabulku pro ověření provider reality pro entity
-- players / coaches napříč sporty
-- Spouštět v DBeaveru

create schema if not exists ops;

create table if not exists ops.provider_people_audit (
    id bigserial primary key,

    -- základní identita
    provider               text not null,
    sport_code             text not null,
    entity                 text not null check (entity in ('players', 'coaches')),

    -- architektonický záměr
    provider_role          text null,   -- primary / fallback / candidate / planned
    source_category        text null,   -- api / scraper / manual / unknown

    -- technická realita
    endpoint_name          text null,
    endpoint_exists        boolean not null default false,
    endpoint_tested        boolean not null default false,
    endpoint_returns_data  boolean not null default false,
    usable_for_league      boolean not null default false,
    usable_for_team        boolean not null default false,
    usable_for_season      boolean not null default false,

    -- runtime/quality verdict
    technical_status       text null,   -- tech_ready / runtime_tested / blocked / planned / unknown
    data_quality_status    text null,   -- usable / partial / poor / empty / unknown
    final_verdict          text null,   -- USABLE / PARTIAL_ONLY / BLOCKED / WAIT_PROVIDER / NOT_RELEVANT

    -- projektový kontext
    requires_pro           boolean not null default false,
    alternative_provider_needed boolean not null default false,

    -- poznámky
    evidence_note          text null,
    next_step              text null,
    priority_rank          integer null,

    created_at             timestamptz not null default now(),
    updated_at             timestamptz not null default now(),

    constraint ux_provider_people_audit unique (provider, sport_code, entity)
);

-- updated_at trigger helper
create or replace function ops.set_updated_at_provider_people_audit()
returns trigger
language plpgsql
as $$
begin
    new.updated_at := now();
    return new;
end;
$$;

drop trigger if exists trg_set_updated_at_provider_people_audit on ops.provider_people_audit;

create trigger trg_set_updated_at_provider_people_audit
before update on ops.provider_people_audit
for each row
execute function ops.set_updated_at_provider_people_audit();

-- seed - první pracovní sada podle dosavadního projektu
insert into ops.provider_people_audit (
    provider,
    sport_code,
    entity,
    provider_role,
    source_category,
    endpoint_name,
    endpoint_exists,
    endpoint_tested,
    endpoint_returns_data,
    usable_for_league,
    usable_for_team,
    usable_for_season,
    technical_status,
    data_quality_status,
    final_verdict,
    requires_pro,
    alternative_provider_needed,
    evidence_note,
    next_step,
    priority_rank
)
values
-- FB / api_football
('api_football', 'FB', 'players',  'primary',  'api', 'players', true,  true,  true,  true,  true,  true,  'runtime_tested', 'partial', 'PARTIAL_ONLY', true,  false,
 'Fotbal players větev technicky existuje, ale je závislá na PRO/budget režimu.', 
 'Později potvrdit přesný finální harvest model po ligách a sezonách.', 10),

('api_football', 'FB', 'coaches',  'primary',  'api', 'coachs',  true,  false, false, false, false, false, 'planned', 'unknown', 'WAIT_PROVIDER', true, false,
 'Fotbal coaches jsou v architektuře vedené jako planned; nutno ověřit runtime použitelnost.', 
 'Uděláme samostatný football coaches reality check.', 11),

-- HK / api_hockey
('api_hockey',   'HK', 'players',  'primary',  'api', 'players', false, true,  false, false, false, false, 'blocked', 'empty', 'BLOCKED', false, true,
 'U hokeje jsou players v projektu vyhodnocené jako blocked/problematic.', 
 'Hledat alternativního providera pro players mimo API-Sports.', 20),

('api_hockey',   'HK', 'coaches',  'candidate','api', 'coachs',  false, false, false, false, false, false, 'tech_ready', 'unknown', 'WAIT_PROVIDER', false, true,
 'Coaches nejsou zatím potvrzené jako reálně použitelné.', 
 'Ověřit endpoint existenci a kvalitu odpovědi; pokud ne, hledat jiného providera.', 21),

-- BK / api_sport
('api_sport',    'BK', 'players',  'candidate','api', 'players', false, true,  false, false, false, false, 'planned', 'empty', 'BLOCKED', false, true,
 'Basket players u multisport větve nejsou zatím potvrzené jako použitelné.', 
 'Hledat alternativního providera.', 30),

('api_sport',    'BK', 'coaches',  'candidate','api', 'coachs',  false, false, false, false, false, false, 'planned', 'unknown', 'WAIT_PROVIDER', false, true,
 'Basket coaches zatím nejsou potvrzené.', 
 'Provést coach reality audit a případně hledat jiného providera.', 31),

-- VB / api_volleyball
('api_volleyball','VB','players',  'candidate','api', 'players', false, true,  false, false, false, false, 'planned', 'empty', 'BLOCKED', false, true,
 'Volleyball players zatím nejsou potvrzené jako použitelné.', 
 'Hledat alternativního providera.', 40),

('api_volleyball','VB','coaches',  'candidate','api', 'coachs',  false, false, false, false, false, false, 'planned', 'unknown', 'WAIT_PROVIDER', false, true,
 'Volleyball coaches zatím nejsou potvrzené.', 
 'Provést coach reality audit a případně hledat jiného providera.', 41),

-- HB / api_handball
('api_handball', 'HB', 'players',  'candidate','api', 'players', false, false, false, false, false, false, 'planned', 'unknown', 'WAIT_PROVIDER', false, true,
 'Handball players zatím nejsou potvrzené.', 
 'Provést people audit provider reality.', 50),

('api_handball', 'HB', 'coaches',  'candidate','api', 'coachs',  false, false, false, false, false, false, 'planned', 'unknown', 'WAIT_PROVIDER', false, true,
 'Handball coaches zatím nejsou potvrzené.', 
 'Provést people audit provider reality.', 51)
on conflict (provider, sport_code, entity) do update
set
    provider_role = excluded.provider_role,
    source_category = excluded.source_category,
    endpoint_name = excluded.endpoint_name,
    endpoint_exists = excluded.endpoint_exists,
    endpoint_tested = excluded.endpoint_tested,
    endpoint_returns_data = excluded.endpoint_returns_data,
    usable_for_league = excluded.usable_for_league,
    usable_for_team = excluded.usable_for_team,
    usable_for_season = excluded.usable_for_season,
    technical_status = excluded.technical_status,
    data_quality_status = excluded.data_quality_status,
    final_verdict = excluded.final_verdict,
    requires_pro = excluded.requires_pro,
    alternative_provider_needed = excluded.alternative_provider_needed,
    evidence_note = excluded.evidence_note,
    next_step = excluded.next_step,
    priority_rank = excluded.priority_rank,
    updated_at = now();

-- kontrolní výpis
select
    provider,
    sport_code,
    entity,
    endpoint_name,
    endpoint_exists,
    endpoint_tested,
    endpoint_returns_data,
    technical_status,
    data_quality_status,
    final_verdict,
    alternative_provider_needed,
    next_step
from ops.provider_people_audit
order by sport_code, provider, entity;