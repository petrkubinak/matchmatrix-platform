UPDATE ops.sport_completion_audit
SET
    current_status = 'DONE',
    production_readiness = 'READY',
    db_layer_ready = true,
    planner_ready = true,
    queue_ready = true,
    public_ready = true,
    key_gap = NULL,
    next_step = 'AFB core pipeline je uzavrena. Dalsi krok pripadne odds / people / downstream entity.',
    evidence_note = 'AFB FULL CONFIRMED: leagues + teams + fixtures; stg_provider_teams=34, stg_provider_fixtures=335, public.matches=335, team_provider_map=34, real merge OK.',
    updated_at = NOW()
WHERE sport_code = 'AFB'
  AND layer_type = 'core_pipeline'
RETURNING sport_code, layer_type, current_status, production_readiness, evidence_note;