/*
MATCHMATRIX SQL 111_R
AUDIT SPORT COMPLETION FORMULA V1

CO TO JE:
- Audit zdrojových řádků pro výpočet sport completion dashboardu.

K ČEMU TO JE:
- Zjistíme, proč má football CORE pouze 25 %, ale zároveň SPORT_READY.

KDE TO UVIDÍME:
- Výsledek v DBeaveru.

JAK SE TO VYUŽIJE:
- Podle výsledku opravíme view ops.v_sport_completion_dashboard_v1
  nebo vytvoříme přesnější V2 view pro panel V17.11.04.
*/

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
    priority_rank,
    updated_at
FROM ops.sport_completion_audit
WHERE sport_code IN ('football', 'FB')
ORDER BY
    layer_type,
    entity,
    priority_rank;