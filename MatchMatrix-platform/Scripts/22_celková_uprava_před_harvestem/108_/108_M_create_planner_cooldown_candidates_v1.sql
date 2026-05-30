/*
MATCHMATRIX SQL 108_M
Planner Cooldown Candidates V1

CO TO JE:
- View zobrazující targety vhodné pro cooldown/block.

K ČEMU TO JE:
- Scheduler nebude pořád dokola spouštět empty targety.

KDE TO UVIDÍME:
- ops.v_planner_cooldown_candidates_v1
- panel V17.8+

JAK SE TO VYUŽIJE:
- autonomous cooldown
- planner optimization
- retry reduction
- self-healing orchestration
*/

CREATE OR REPLACE VIEW ops.v_planner_cooldown_candidates_v1 AS

SELECT
    league_id,
    season,

    total_runs,
    warning_runs,
    failed_runs,
    empty_runs,
    empty_pct,

    planner_target_state,
    target_rank,

    last_run_at,

    CASE

        WHEN planner_target_state = 'BLOCK_TARGET'
            THEN NOW() + INTERVAL '7 days'

        WHEN planner_target_state = 'COOLDOWN'
            THEN NOW() + INTERVAL '24 hours'

        ELSE NULL

    END AS suggested_retry_after,

    CASE

        WHEN planner_target_state = 'BLOCK_TARGET'
            THEN 'DISABLE_OR_REVIEW'

        WHEN planner_target_state = 'COOLDOWN'
            THEN 'TEMP_COOLDOWN'

        ELSE 'NONE'

    END AS suggested_action

FROM ops.v_planner_target_quality_guard_v1

WHERE planner_target_state IN (
    'COOLDOWN',
    'BLOCK_TARGET'
);