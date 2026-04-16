-- 596_create_ops_sport_completion_audit.sql
-- Účel:
-- finální auditní tabulka dokončenosti sportů
-- Spouštět v DBeaveru

create table if not exists ops.sport_completion_audit (
    id bigserial primary key,
    sport_code text not null,
    entity text not null,

    layer_type text not null,              -- core / extension / downstream / people
    current_status text not null,          -- DONE / PARTIAL / VALIDATE / REVIEW / BLOCKED / WAIT_PROVIDER
    production_readiness text not null,    -- READY / NEAR_READY / NOT_READY

    provider_primary text null,
    provider_fallback text null,

    db_layer_ready boolean not null default false,
    planner_ready boolean not null default false,
    queue_ready boolean not null default false,
    public_ready boolean not null default false,

    key_gap text null,
    next_step text null,
    evidence_note text null,

    priority_rank integer null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

    constraint ux_sport_completion_audit unique (sport_code, entity)
);

create or replace function ops.set_updated_at_sport_completion_audit()
returns trigger
language plpgsql
as $$
begin
    new.updated_at := now();
    return new;
end;
$$;

drop trigger if exists trg_set_updated_at_sport_completion_audit on ops.sport_completion_audit;

create trigger trg_set_updated_at_sport_completion_audit
before update on ops.sport_completion_audit
for each row
execute function ops.set_updated_at_sport_completion_audit();

select *
from ops.sport_completion_audit
order by sport_code, entity;