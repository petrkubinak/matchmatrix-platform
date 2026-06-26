/*
MATCHMATRIX SQL 111_S

AUTONOMOUS OPS BRAIN SUMMARY V1

CO TO JE:
- Souhrnný pohled nad Brain V5.

K ČEMU TO JE:
- Nezobrazovat 50 podobných řádků.
- Zobrazit skupiny akcí.

KDE TO UVIDÍME:
- OPS panel
- Autonomous Brain Dashboard

JAK SE TO VYUŽIJE:
FB fixtures EU_top,EU_exact_v1
→ 47 kandidátů

FB fixtures FB_BOOTSTRAP_V1
→ 3 kandidáti
*/

CREATE OR REPLACE VIEW ops.v_autonomous_ops_brain_summary_v1 AS

SELECT

    provider,
    sport_code,
    entity,
    run_group,

    COUNT(*) AS candidate_count,

    MIN(brain_rank) AS best_rank,

    ROUND(MAX(brain_score),2) AS max_score,
    ROUND(AVG(brain_score),2) AS avg_score,

    MAX(worker_type) AS worker_type,

    CASE
        WHEN BOOL_OR(brain_decision = 'RUN')
            THEN 'RUN'

        WHEN BOOL_OR(brain_decision = 'RUN_WITH_CAUTION')
            THEN 'RUN_WITH_CAUTION'

        WHEN BOOL_OR(brain_decision = 'WAIT_CUSTOM_WORKER')
            THEN 'WAIT_CUSTOM_WORKER'

        WHEN BOOL_OR(brain_decision = 'WAIT_NO_REGISTRY')
            THEN 'WAIT_NO_REGISTRY'

        WHEN BOOL_OR(brain_decision = 'WAIT')
            THEN 'WAIT'

        ELSE 'HOLD'
    END AS summary_decision,

    MAX(recommended_focus) AS recommended_focus

FROM ops.v_autonomous_ops_brain_v5

GROUP BY

    provider,
    sport_code,
    entity,
    run_group

ORDER BY

    best_rank,
    avg_score DESC;