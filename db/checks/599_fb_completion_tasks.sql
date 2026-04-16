-- 599_fb_completion_tasks.sql
-- Účel:
-- pracovní seznam úkolů pro dotažení FB do finální podoby
-- dokumentační / kontrolní skript

select
    sport_code,
    entity,
    layer_type,
    current_status,
    production_readiness,
    provider_primary,
    provider_fallback,
    key_gap,
    next_step,
    evidence_note
from ops.sport_completion_audit
where sport_code = 'FB'
order by priority_rank, entity;