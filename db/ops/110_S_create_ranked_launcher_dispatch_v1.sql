/*
MATCHMATRIX SQL 110_S Create Ranked Launcher Dispatch V1

CO TO JE:
- Dispatch launcheru napojený na AI ranking.

K ČEMU TO JE:
- Launcher už nevezme jen první pending akci.
- Vezme nejlepší kandidát podle AI skóre.
- Zohlední learning historii, prioritu a riziko.

KDE TO UVIDÍME:
- Panel V18+
- SPUSTIT DALŠÍ
- AI OPS
- AUTONOMNÍ LAUNCHER

JAK SE TO VYUŽIJE:
- Ranking vybere nejlepší akci.
- Dispatch doplní worker podle pravidel.
- Python launcher spustí doporučený worker.
*/


CREATE OR REPLACE VIEW ops.v_ranked_launcher_dispatch_v1 AS
SELECT

    r.queue_id,
    r.action_code,

    er.worker_code,
    wr.worker_type,
    wr.worker_path,

    r.provider,
    r.sport_code,
    r.entity,
    r.league_id,
    r.season,
    r.run_group,

    r.priority_score,
    r.ai_confidence_score,
    r.success_rate_pct,
    r.calculated_risk_cz,
    r.ai_recommendation_cz,
    r.final_rank_score,

    r.can_be_next,

    CASE
        WHEN r.can_be_next = true
         AND er.worker_code IS NOT NULL
         AND wr.is_active = true
        THEN true
        ELSE false
    END AS can_dispatch,

    CASE
        WHEN r.can_be_next = false
            THEN r.ranking_reason_cz

        WHEN er.worker_code IS NULL
            THEN 'Chybí execution rule pro danou akci.'

        WHEN wr.worker_code IS NULL
            THEN 'Worker není v registru.'

        WHEN wr.is_active = false
            THEN 'Worker je deaktivovaný.'

        ELSE 'READY_TO_LAUNCH'
    END AS dispatch_state_cz,

    now() AS evaluated_at

FROM ops.v_autonomous_candidate_ranking_v1 r

LEFT JOIN ops.worker_execution_rules er
       ON er.action_code = r.action_code
      AND er.is_active = true

LEFT JOIN ops.worker_capability_registry wr
       ON wr.worker_code = er.worker_code

WHERE r.can_be_next = true;



CREATE OR REPLACE VIEW ops.v_ranked_launcher_dispatch_next_v1 AS
SELECT *
FROM ops.v_ranked_launcher_dispatch_v1
WHERE can_dispatch = true
ORDER BY
    final_rank_score DESC,
    priority_score DESC,
    queue_id ASC
LIMIT 1;



CREATE OR REPLACE VIEW ops.v_ranked_launcher_dispatch_panel_v1 AS
SELECT

    queue_id                    AS "Queue ID",
    action_code                 AS "Akce",

    worker_code                 AS "Worker",
    worker_type                 AS "Typ workeru",
    worker_path                 AS "Cesta",

    provider                    AS "Provider",
    sport_code                  AS "Sport",
    entity                      AS "Entita",
    league_id                   AS "Liga",
    season                      AS "Sezóna",
    run_group                   AS "Run group",

    priority_score              AS "Priorita",
    ai_confidence_score         AS "AI důvěra",
    success_rate_pct            AS "Úspěšnost %",
    calculated_risk_cz          AS "Riziko",
    ai_recommendation_cz        AS "AI doporučení",
    final_rank_score            AS "Finální skóre",

    can_dispatch                AS "Může spustit",
    dispatch_state_cz           AS "Stav",

    evaluated_at                AS "Vyhodnoceno"

FROM ops.v_ranked_launcher_dispatch_v1
ORDER BY
    can_dispatch DESC,
    final_rank_score DESC,
    priority_score DESC;



CREATE OR REPLACE VIEW ops.v_ranked_launcher_dispatch_summary_v1 AS
SELECT

    COUNT(*) AS ranked_candidates,

    COUNT(*) FILTER (
        WHERE can_dispatch = true
    ) AS dispatch_ready,

    COUNT(*) FILTER (
        WHERE can_dispatch = false
    ) AS dispatch_blocked,

    MAX(final_rank_score) FILTER (
        WHERE can_dispatch = true
    ) AS best_score,

    now() AS generated_at

FROM ops.v_ranked_launcher_dispatch_v1;