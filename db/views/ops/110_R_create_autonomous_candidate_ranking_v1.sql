/*
MATCHMATRIX SQL 110_R Create Autonomous Candidate Ranking V1

CO TO JE:
- Ranking autonomních kandidátů podle AI učení.

K ČEMU TO JE:
- Seřadí kandidáty podle bezpečnosti a priority.
- Zohlední historickou úspěšnost.
- Panel uvidí, co má smysl spustit jako první.

KDE TO UVIDÍME:
- Panel V18+
- AI OPS
- SPUSTIT DALŠÍ
- Autonomní fronta

JAK SE TO VYUŽIJE:
- AI najde kandidáty.
- Ranking dopočítá pořadí.
- Launcher vezme nejlepší bezpečný řádek.
*/


CREATE OR REPLACE VIEW ops.v_autonomous_candidate_ranking_v1 AS
SELECT

    q.id AS queue_id,

    q.action_type AS action_code,
    q.provider,
    q.sport_code,
    q.entity,
    q.provider_league_id AS league_id,
    q.season,
    q.run_group,

    q.priority_score,

    COALESCE(ai.confidence_score, 50) AS ai_confidence_score,
    COALESCE(ai.success_rate_pct, 0) AS success_rate_pct,
    COALESCE(ai.calculated_risk_cz, q.risk_level, 'NEZNÁMÉ') AS calculated_risk_cz,
    COALESCE(ai.recommendation_cz, 'NEDOSTATEK DAT') AS ai_recommendation_cz,

    (
        COALESCE(q.priority_score, 0)
        + COALESCE(ai.confidence_score, 50)
        - CASE
            WHEN COALESCE(ai.calculated_risk_cz, q.risk_level) = 'VYSOKÉ' THEN 50
            WHEN COALESCE(ai.calculated_risk_cz, q.risk_level) = 'STŘEDNÍ' THEN 20
            ELSE 0
          END
    ) AS final_rank_score,

    CASE
        WHEN COALESCE(ai.calculated_risk_cz, q.risk_level) = 'VYSOKÉ'
            THEN false
        WHEN q.execution_status <> 'PENDING'
            THEN false
        ELSE true
    END AS can_be_next,

    CASE
        WHEN q.execution_status <> 'PENDING'
            THEN 'NENÍ VE STAVU PENDING'

        WHEN COALESCE(ai.calculated_risk_cz, q.risk_level) = 'VYSOKÉ'
            THEN 'RIZIKO JE VYSOKÉ - RUČNÍ KONTROLA'

        WHEN ai.confidence_score IS NULL
            THEN 'NEDOSTATEK HISTORIE - OPATRNÉ SPUŠTĚNÍ'

        ELSE 'KANDIDÁT JE VHODNÝ KE SPUŠTĚNÍ'
    END AS ranking_reason_cz,

    q.created_at,
    now() AS evaluated_at

FROM ops.autonomous_execution_queue q

LEFT JOIN ops.v_ai_self_improvement_engine_v1 ai
       ON ai.provider = q.provider
      AND ai.sport_code = q.sport_code
      AND ai.entity = q.entity
      AND ai.repair_action = q.action_type

WHERE q.execution_status = 'PENDING';



CREATE OR REPLACE VIEW ops.v_autonomous_candidate_ranking_panel_v1 AS
SELECT

    queue_id                 AS "Queue ID",
    action_code              AS "Akce",
    provider                 AS "Provider",
    sport_code               AS "Sport",
    entity                   AS "Entita",
    league_id                AS "Liga",
    season                   AS "Sezóna",
    run_group                AS "Run group",

    priority_score           AS "Priorita",
    ai_confidence_score      AS "AI důvěra",
    success_rate_pct         AS "Úspěšnost %",
    calculated_risk_cz       AS "Riziko",
    ai_recommendation_cz     AS "AI doporučení",
    final_rank_score         AS "Finální skóre",

    can_be_next              AS "Může být další",
    ranking_reason_cz        AS "Důvod",

    created_at               AS "Vytvořeno",
    evaluated_at             AS "Vyhodnoceno"

FROM ops.v_autonomous_candidate_ranking_v1
ORDER BY
    can_be_next DESC,
    final_rank_score DESC,
    created_at ASC;



CREATE OR REPLACE VIEW ops.v_autonomous_next_ranked_candidate_v1 AS
SELECT *
FROM ops.v_autonomous_candidate_ranking_v1
WHERE can_be_next = true
ORDER BY
    final_rank_score DESC,
    created_at ASC
LIMIT 1;



CREATE OR REPLACE VIEW ops.v_autonomous_candidate_ranking_summary_v1 AS
SELECT
    COUNT(*) AS pending_candidates,

    COUNT(*) FILTER (
        WHERE can_be_next = true
    ) AS runnable_candidates,

    COUNT(*) FILTER (
        WHERE can_be_next = false
    ) AS blocked_candidates,

    MAX(final_rank_score) FILTER (
        WHERE can_be_next = true
    ) AS best_rank_score,

    now() AS generated_at

FROM ops.v_autonomous_candidate_ranking_v1;