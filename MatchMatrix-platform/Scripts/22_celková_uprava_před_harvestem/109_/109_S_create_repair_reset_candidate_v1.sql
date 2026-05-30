/*
MATCHMATRIX SQL 109_S Create Repair Reset Candidate V1

CO TO JE:
- Bezpečný podklad pro reset opravené blokované položky.

K ČEMU TO JE:
- Panel ukáže, kterou položku lze po ruční kontrole vrátit do fronty.
- Zatím nic automaticky nemaže ani neresetuje.

KDE TO UVIDÍME:
- Panel V18
- AI OPS
- OPRAVY / BLOKOVANÉ

JAK SE TO VYUŽIJE:
- Admin ověří providera/ligu/scope.
- Potom panel nabídne řízený reset attempts.
*/


CREATE OR REPLACE VIEW ops.v_repair_reset_candidates_v1 AS
SELECT
    repair_rank,
    provider,
    sport_code,
    entity,
    league_id,
    season,
    run_group,

    ai_decision,
    ai_risk_level,
    repair_action,
    repair_detail,
    repair_priority,

    false AS reset_allowed_without_review,

    'ČEKÁ NA RUČNÍ OVĚŘENÍ'::text AS reset_state,

    (
        'Po ověření změnit attempts na 0, status ponechat nebo vrátit na pending, next_run nastavit na now().'
    ) AS reset_instruction,

    generated_at

FROM ops.v_blocked_items_repair_queue_v1
WHERE repair_priority IN ('HIGH', 'MEDIUM');


CREATE OR REPLACE VIEW ops.v_repair_reset_candidate_next_v1 AS
SELECT *
FROM ops.v_repair_reset_candidates_v1
ORDER BY
    CASE
        WHEN repair_priority = 'HIGH' THEN 1
        WHEN repair_priority = 'MEDIUM' THEN 2
        ELSE 3
    END,
    repair_rank
LIMIT 1;


CREATE OR REPLACE VIEW ops.v_repair_reset_summary_v1 AS
SELECT
    COUNT(*) AS reset_candidate_total,

    COUNT(*) FILTER (
        WHERE repair_priority = 'HIGH'
    ) AS high_priority_total,

    COUNT(*) FILTER (
        WHERE repair_priority = 'MEDIUM'
    ) AS medium_priority_total,

    COUNT(*) FILTER (
        WHERE reset_allowed_without_review = false
    ) AS manual_review_required,

    now() AS generated_at

FROM ops.v_repair_reset_candidates_v1;