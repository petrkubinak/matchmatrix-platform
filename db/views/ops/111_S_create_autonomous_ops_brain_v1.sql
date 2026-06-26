/*
MATCHMATRIX SQL 111_S
CREATE AUTONOMOUS OPS BRAIN V1

CO TO JE:
- První sjednocující view pro Autonomous OPS Brain.
- Kombinuje Sport Completion, AI doporučení a autonomní frontu.

K ČEMU TO JE:
- Aby systém nevybíral jen podle priority fronty.
- Brain začne vyhodnocovat:
  sport,
  vrstvu,
  riziko,
  budget,
  doporučený focus,
  AI safe flag.

KDE TO UVIDÍME:
- V DBeaveru jako ops.v_autonomous_ops_brain_v1.
- Později v panelu a v launcheru 111_S.

JAK SE TO VYUŽIJE:
- 111_S bude vybírat nejlepší další akci:
  RUN / WAIT / HOLD / SKIP.
*/

CREATE OR REPLACE VIEW ops.v_autonomous_ops_brain_v1 AS
WITH queue_base AS (
    SELECT
        q.id AS queue_id,
        q.action_type,
        q.provider,
        q.sport_code,
        q.entity,
        q.league_id,
        q.season,
        q.run_group,
        q.priority_score,
        q.risk_level,
        q.action_reason,
        q.execution_status,
        q.execution_result,
        q.created_at
    FROM ops.v_autonomous_execution_queue_v1 q
    WHERE COALESCE(q.execution_status, 'pending') IN ('pending', 'PENDING', 'ready', 'READY')
),
ai_match AS (
    SELECT
        a.provider,
        a.sport_code,
        a.entity,
        a.league_id,
        a.season,
        a.run_group,
        MIN(a.recommendation_rank) AS recommendation_rank,
        MAX(a.empty_runs) AS empty_runs,
        MAX(a.empty_pct) AS empty_pct,
        MAX(a.ai_decision) AS ai_decision,
        MAX(a.ai_risk_level) AS ai_risk_level,
        MAX(a.ai_reason) AS ai_reason,
        BOOL_OR(a.autonomous_safe) AS autonomous_safe
    FROM ops.v_panel_ai_recommendations_v1 a
    GROUP BY
        a.provider,
        a.sport_code,
        a.entity,
        a.league_id,
        a.season,
        a.run_group
),
brain AS (
    SELECT
        q.queue_id,
        q.action_type,
        q.provider,
        q.sport_code,
        COALESCE(s.sport_name, q.sport_code) AS sport_name,
        q.entity,
        q.league_id,
        q.season,
        q.run_group,

        COALESCE(s.core_pct, 0) AS core_pct,
        COALESCE(s.people_pct, 0) AS people_pct,
        COALESCE(s.media_pct, 0) AS media_pct,
        COALESCE(s.odds_pct, 0) AS odds_pct,
        COALESCE(s.total_pct, 0) AS total_pct,
        COALESCE(s.sport_readiness, 'UNKNOWN') AS sport_readiness,
        COALESCE(s.recommended_focus, 'UNKNOWN') AS recommended_focus,

        COALESCE(q.priority_score, 0) AS queue_priority_score,
        COALESCE(a.recommendation_rank, 999) AS recommendation_rank,
        COALESCE(a.empty_runs, 0) AS empty_runs,
        COALESCE(a.empty_pct, 0) AS empty_pct,
        COALESCE(a.ai_decision, 'UNKNOWN') AS ai_decision,
        COALESCE(a.ai_risk_level, q.risk_level, 'UNKNOWN') AS ai_risk_level,
        COALESCE(a.ai_reason, q.action_reason, '') AS brain_reason,
        COALESCE(a.autonomous_safe, false) AS autonomous_safe,

        COALESCE(s.requests_remaining, 0) AS requests_remaining,
        COALESCE(s.budget_status, 'UNKNOWN') AS budget_status,

        q.created_at
    FROM queue_base q
    LEFT JOIN ai_match a
        ON a.provider = q.provider
       AND a.sport_code = q.sport_code
       AND a.entity = q.entity
       AND COALESCE(a.league_id, '') = COALESCE(q.league_id, '')
       AND COALESCE(a.season, '') = COALESCE(q.season, '')
       AND COALESCE(a.run_group, '') = COALESCE(q.run_group, '')
    LEFT JOIN ops.v_sport_completion_dashboard_v2 s
        ON s.sport_code = q.sport_code
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            CASE
                WHEN autonomous_safe = true THEN 0
                ELSE 1
            END,
            CASE
                WHEN recommended_focus = 'CORE_HARVEST' AND empty_runs >= 3 THEN 1
                ELSE 0
            END,
            total_pct ASC,
            queue_priority_score DESC,
            recommendation_rank ASC,
            queue_id ASC
    ) AS brain_rank,

    queue_id,
    action_type,
    provider,
    sport_code,
    sport_name,
    entity,
    league_id,
    season,
    run_group,

    core_pct,
    people_pct,
    media_pct,
    odds_pct,
    total_pct,
    sport_readiness,
    recommended_focus,

    queue_priority_score,
    recommendation_rank,
    empty_runs,
    empty_pct,
    ai_decision,
    ai_risk_level,
    autonomous_safe,
    requests_remaining,
    budget_status,

    CASE
        WHEN budget_status IN ('BLOCKED', 'LIMIT_REACHED') THEN 'WAIT'
        WHEN empty_runs >= 3 AND recommended_focus = 'CORE_HARVEST' THEN 'HOLD'
        WHEN autonomous_safe = true THEN 'RUN'
        WHEN ai_risk_level ILIKE '%HIGH%' THEN 'WAIT'
        ELSE 'RUN_WITH_CAUTION'
    END AS brain_decision,

    CASE
        WHEN budget_status IN ('BLOCKED', 'LIMIT_REACHED')
            THEN 'Denní API budget je vyčerpaný nebo blokovaný.'
        WHEN empty_runs >= 3 AND recommended_focus = 'CORE_HARVEST'
            THEN 'Opakované CORE běhy nepřinášejí nová data, akci držíme stranou.'
        WHEN autonomous_safe = true
            THEN 'Akce je označená jako autonomně bezpečná.'
        WHEN ai_risk_level ILIKE '%HIGH%'
            THEN 'AI riziko je vysoké, akci nespouštět automaticky.'
        ELSE 'Akce je možná, ale vyžaduje opatrné spuštění.'
    END AS brain_decision_reason,

    brain_reason,
    created_at
FROM brain
ORDER BY
    brain_rank;