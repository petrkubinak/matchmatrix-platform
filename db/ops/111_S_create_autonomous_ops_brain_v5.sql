/*
MATCHMATRIX SQL 111_S
AUTONOMOUS OPS BRAIN V5

CO TO JE:
- Brain V5 napojený na provider_worker_registry.

K ČEMU TO JE:
- Brain už neposílá do RUN kombinace, které Dispatcher neumí spustit.
- CUSTOM_WORKER jde do WAIT_CUSTOM_WORKER.
- NOT_IMPLEMENTED jde do HOLD.
- UNIFIED_INGEST může zůstat RUN.

KDE TO UVIDÍME:
- ops.v_autonomous_ops_brain_v5

JAK SE TO VYUŽIJE:
- Dispatch builder bude brát RUN jen z V5.
*/

CREATE OR REPLACE VIEW ops.v_autonomous_ops_brain_v5 AS
WITH base AS (
    SELECT
        b.*,
        COALESCE(r.worker_type, 'NO_REGISTRY') AS worker_type,
        COALESCE(r.is_supported, false) AS worker_supported,
        COALESCE(r.is_active, false) AS worker_active,
        COALESCE(r.notes, '') AS worker_registry_note
    FROM ops.v_autonomous_ops_brain_v4 b
    LEFT JOIN ops.provider_worker_registry r
        ON r.provider = b.provider
       AND r.sport_code = b.sport_code
       AND r.entity = b.entity
       AND r.is_active = true
)
SELECT
    brain_rank,
    provider,
    sport_code,
    sport_name,
    entity,
    league_id,
    season,
    run_group,

    total_pct,
    sport_readiness,
    recommended_focus,

    ai_decision,
    ai_risk_level,
    autonomous_safe,

    empty_runs,
    empty_pct,
    grouped_count,

    focus_alignment_score,
    is_not_implemented,

    worker_type,
    worker_supported,
    worker_active,
    worker_registry_note,

    brain_score,

    CASE
        WHEN worker_type = 'NOT_IMPLEMENTED'
            THEN 'HOLD'

        WHEN worker_type = 'CUSTOM_WORKER'
            THEN 'WAIT_CUSTOM_WORKER'

        WHEN worker_type = 'NO_REGISTRY'
            THEN 'WAIT_NO_REGISTRY'

        WHEN worker_supported = false OR worker_active = false
            THEN 'HOLD'

        ELSE brain_decision
    END AS brain_decision,

    CASE
        WHEN worker_type = 'NOT_IMPLEMENTED'
            THEN 'Registry říká: kombinace není implementovaná.'

        WHEN worker_type = 'CUSTOM_WORKER'
            THEN 'Registry říká: kombinace potřebuje specializovaný custom worker.'

        WHEN worker_type = 'NO_REGISTRY'
            THEN 'Kombinace provider/sport/entity zatím není v provider_worker_registry.'

        WHEN worker_supported = false OR worker_active = false
            THEN 'Worker je v registry vypnutý nebo nepodporovaný.'

        ELSE brain_decision_reason
    END AS brain_decision_reason,

    ai_reason,
    generated_at

FROM base;