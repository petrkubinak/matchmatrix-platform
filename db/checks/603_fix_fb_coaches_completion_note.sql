-- 603_fix_fb_coaches_completion_note.sql
-- Účel:
-- opravit completion audit pro FB coaches podle skutečné reality
-- Spouštět v DBeaveru

update ops.sport_completion_audit
set
    current_status = 'PARTIAL',
    production_readiness = 'NEAR_READY',
    key_gap = 'Chybí aktivní ingest/staging flow pro coaches; mapping až druhý krok',
    next_step = 'Připravit a spustit coaches ingest do staging.stg_provider_coaches, potom řešit mapping do public.',
    evidence_note = 'Endpoint existuje a vrací data, ale FB coaches nejsou v planner queue ani ve stagingu; provider coverage je stále WAIT_PLAN.'
where sport_code = 'FB'
  and entity = 'coachs';

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
  and entity = 'coachs';