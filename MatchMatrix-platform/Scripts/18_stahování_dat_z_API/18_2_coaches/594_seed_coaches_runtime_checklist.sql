-- 594_seed_coaches_runtime_checklist.sql
-- Účel:
-- připravit malý runtime checklist pro reálné ověření coaches jen tam,
-- kde to teď dává smysl
-- Spouštět v DBeaveru

create table if not exists ops.provider_coaches_runtime_checklist (
    id bigserial primary key,
    provider text not null,
    sport_code text not null,
    endpoint_name text not null,
    priority_rank integer not null,
    check_scope text not null,              -- endpoint_exists / returns_data / usable_mapping
    check_status text not null default 'pending',   -- pending / tested / confirmed / failed
    test_note text null,
    next_step text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint ux_provider_coaches_runtime_checklist unique (provider, sport_code, endpoint_name, check_scope)
);

insert into ops.provider_coaches_runtime_checklist (
    provider,
    sport_code,
    endpoint_name,
    priority_rank,
    check_scope,
    check_status,
    test_note,
    next_step
)
values
('api_football', 'FB', 'coachs', 10, 'endpoint_exists', 'pending',
 'Fotbal coaches mají nejvyšší prioritu reality checku.', 
 'Ověřit reálnou existenci endpointu a usable response.'),
('api_football', 'FB', 'coachs', 10, 'returns_data', 'pending',
 'Prověřit, zda endpoint vrací data pro reálné ligy/týmy.', 
 'Ověřit usable payload.'),
('api_football', 'FB', 'coachs', 10, 'usable_mapping', 'pending',
 'Prověřit mapovatelnost na team/league/provider identity.', 
 'Rozhodnout usable vs partial.'),

('api_hockey', 'HK', 'coachs', 20, 'endpoint_exists', 'pending',
 'Hokej coaches jsou jediný non-football kandidát s tech_ready stopou.', 
 'Ověřit, zda endpoint vůbec existuje.'),
('api_hockey', 'HK', 'coachs', 20, 'returns_data', 'pending',
 'Prověřit, zda vrací reálná data.', 
 'Pokud ne, ukončit větev jako blocked.'),
('api_hockey', 'HK', 'coachs', 20, 'usable_mapping', 'pending',
 'Prověřit mapovatelnost odpovědi.', 
 'Rozhodnout usable vs blocked.')
on conflict (provider, sport_code, endpoint_name, check_scope) do nothing;

select *
from ops.provider_coaches_runtime_checklist
order by priority_rank, provider, check_scope;