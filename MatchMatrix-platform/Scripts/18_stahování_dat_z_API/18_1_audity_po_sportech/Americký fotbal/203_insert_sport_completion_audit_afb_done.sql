INSERT INTO ops.sport_completion_audit (
    sport_code,
    entity,
    layer_type,
    current_status,
    production_readiness,
    db_layer_ready,
    planner_ready,
    queue_ready,
    public_ready,
    key_gap,
    next_step,
    evidence_note,
    priority_rank,
    created_at,
    updated_at
)
VALUES (
    'AFB',
    'core',
    'core_pipeline',
    'DONE',
    'READY',
    true,
    true,
    true,
    true,
    NULL,
    'AFB core pipeline je uzavrena. Dalsi krok pripadne odds / people / downstream entity.',
    'AFB FULL CONFIRMED: leagues + teams + fixtures; stg_provider_teams=34, stg_provider_fixtures=335, public.matches=335, team_provider_map=34, real merge OK.',
    1,
    NOW(),
    NOW()
)
RETURNING sport_code, layer_type, current_status, production_readiness;