-- 618_fix_vb_sport_completion_audit.sql
-- VB final sport completion audit po ověření core pipeline

BEGIN;

INSERT INTO ops.sport_completion_audit
(
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
    priority_rank,
    created_at,
    updated_at
)
VALUES
(
    'VB',
    'core_pipeline',
    'core',
    'DONE',
    'READY',
    'api_volleyball',
    NULL,
    true,
    true,
    true,
    true,
    NULL,
    'VB core pipeline je uzavrena. Dalsi krok pripadne odds / people / downstream entity.',
    'VB leagues/teams/fixtures CONFIRMED; API-Volleyball slozka doplnena; sport_code sjednocen na VB; merge V3 dobehl OK.',
    20,
    now(),
    now()
)
ON CONFLICT (sport_code, entity)
DO UPDATE SET
    layer_type = EXCLUDED.layer_type,
    current_status = EXCLUDED.current_status,
    production_readiness = EXCLUDED.production_readiness,
    provider_primary = EXCLUDED.provider_primary,
    provider_fallback = EXCLUDED.provider_fallback,
    db_layer_ready = EXCLUDED.db_layer_ready,
    planner_ready = EXCLUDED.planner_ready,
    queue_ready = EXCLUDED.queue_ready,
    public_ready = EXCLUDED.public_ready,
    key_gap = EXCLUDED.key_gap,
    next_step = EXCLUDED.next_step,
    evidence_note = EXCLUDED.evidence_note,
    priority_rank = EXCLUDED.priority_rank,
    updated_at = now();

COMMIT;

SELECT
    sport_code,
    entity,
    layer_type,
    current_status,
    production_readiness,
    provider_primary,
    db_layer_ready,
    planner_ready,
    queue_ready,
    public_ready,
    key_gap,
    next_step,
    evidence_note,
    updated_at
FROM ops.sport_completion_audit
WHERE sport_code = 'VB'
ORDER BY entity;