/*
MATCHMATRIX SQL 106_F V1

Soubor:
C:\MatchMatrix-platform\sql\106_F_create_v_automation_execution_queue_v2.sql

Co to je:
Nová automation execution queue nad ops.v_provider_routing_master_v2.

K čemu to je:
Připraví čistý queue pohled pro Control Panel V16+:
- co lze spustit
- co je blokované
- co je failover-ready
- jaký worker použít
- jaký run_group použít
- proč je něco blokované

Výsledek:
ops.v_automation_execution_queue_v2
*/

CREATE OR REPLACE VIEW ops.v_automation_execution_queue_v2 AS

SELECT
    sport_code,
    sport_name,
    entity,

    primary_provider,
    fallback_provider,
    candidate_provider,

    routing_rank,

    provider_route_state,
    provider_gap,

    automation_ready,
    execution_state,
    execution_reason,

    routing_candidate,

    coverage_status,
    runtime_state,
    sport_completion_status,
    production_readiness,

    free_plan_supported,
    paid_plan_supported,
    people_requires_pro,

    source_endpoint,
    target_table,
    worker_script,

    last_run_group AS run_group,
    last_run_at,

    limitations,
    key_gap,
    runtime_reason,
    db_evidence_summary,
    next_action,

    provider_priority,
    fetch_priority,
    merge_priority,
    priority_rank

FROM ops.v_provider_routing_master_v2
ORDER BY
    sport_code,
    entity,
    routing_rank;