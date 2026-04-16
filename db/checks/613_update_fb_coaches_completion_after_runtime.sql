-- 613_update_fb_coaches_completion_after_runtime.sql
-- Účel:
-- promítnout nově funkční FB coaches runtime do completion auditu
-- Spouštět v DBeaveru

update ops.sport_completion_audit
set
    current_status = 'DONE',
    production_readiness = 'READY',
    db_layer_ready = true,
    planner_ready = false,
    queue_ready = false,
    public_ready = true,
    key_gap = 'Chybi career enrichment: start_date, end_date, league_id, season a presnejsi current logic.',
    next_step = 'Rozsirit staging a merge o plne career start/end mapovani a pripadne league context.',
    evidence_note = 'FB coaches ingest do staging funguje, public.coaches a coach_provider_map jsou naplnene a team_coach_history obsahuje career vazby pres vice tymu.'
where sport_code = 'FB'
  and entity = 'coachs';

select
    sport_code,
    entity,
    current_status,
    production_readiness,
    db_layer_ready,
    planner_ready,
    queue_ready,
    public_ready,
    key_gap,
    next_step,
    evidence_note
from ops.sport_completion_audit
where sport_code = 'FB'
  and entity = 'coachs';