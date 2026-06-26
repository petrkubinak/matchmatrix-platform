/*
MATCHMATRIX SQL 110_Q Create AI Self Improvement Engine V1

CO TO JE:
- První samoučící vrstva OPS.

K ČEMU TO JE:
- AI využije historii úspěšnosti.
- Riziko už nebude statické.
- Doporučení bude vycházet z reálných výsledků.

KDE TO UVIDÍME:
- Panel V18+
- AI OPS
- SPUSTIT DALŠÍ
- AUTONOMNÍ FRONTA

JAK SE TO VYUŽIJE:
- Kandidát
- Historie
- Úspěšnost
- Výpočet doporučení
- Výběr další akce
*/


CREATE OR REPLACE VIEW ops.v_ai_self_improvement_engine_v1 AS
SELECT

    l.provider,
    l.sport_code,
    l.entity,
    l.repair_action,

    l.total_attempts,
    l.success_count,
    l.failed_count,
    l.success_rate_pct,

    CASE

        WHEN l.success_rate_pct >= 90
            THEN 100

        WHEN l.success_rate_pct >= 80
            THEN 90

        WHEN l.success_rate_pct >= 70
            THEN 80

        WHEN l.success_rate_pct >= 60
            THEN 70

        WHEN l.success_rate_pct >= 50
            THEN 60

        ELSE 25

    END AS confidence_score,

    CASE

        WHEN l.success_rate_pct >= 80
            THEN 'NÍZKÉ'

        WHEN l.success_rate_pct >= 50
            THEN 'STŘEDNÍ'

        ELSE 'VYSOKÉ'

    END AS calculated_risk_cz,

    CASE

        WHEN l.success_rate_pct >= 80
            THEN 'AUTOMATICKY SPUSTIT'

        WHEN l.success_rate_pct >= 50
            THEN 'SPUSTIT OPATRNĚ'

        ELSE 'RUČNÍ KONTROLA'

    END AS recommendation_cz,

    l.last_attempt_at

FROM ops.v_learning_summary_v1 l;



CREATE OR REPLACE VIEW ops.v_ai_self_improvement_panel_v1 AS
SELECT

    provider                AS "Provider",
    sport_code              AS "Sport",
    entity                  AS "Entita",

    repair_action           AS "Akce",

    total_attempts          AS "Pokusů",
    success_count           AS "Úspěch",
    failed_count            AS "Neúspěch",

    success_rate_pct        AS "Úspěšnost %",

    confidence_score        AS "AI důvěra",

    calculated_risk_cz      AS "Riziko",

    recommendation_cz       AS "Doporučení",

    last_attempt_at         AS "Poslední pokus"

FROM ops.v_ai_self_improvement_engine_v1
ORDER BY
    confidence_score DESC,
    success_rate_pct DESC;