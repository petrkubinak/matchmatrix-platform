/*
MATCHMATRIX SQL 110_P Create Learning Summary Views V1

CO TO JE:
- Souhrn učící vrstvy.

K ČEMU TO JE:
- AI OPS vidí, co funguje.
- Panel vidí úspěšnost oprav.
- Základ pro doporučování dalších akcí.

KDE TO UVIDÍME:
- Panel V18+
- AI OPS
- Learning Dashboard

JAK SE TO VYUŽIJE:
- Vyhodnocení CONFIRMED_OK vs FAILED_AGAIN.
- Prioritizace budoucích oprav.
*/


CREATE OR REPLACE VIEW ops.v_learning_summary_v1 AS
SELECT

    provider,
    sport_code,
    entity,
    repair_action,

    COUNT(*) AS total_attempts,

    COUNT(*) FILTER (
        WHERE outcome_code = 'CONFIRMED_OK'
    ) AS success_count,

    COUNT(*) FILTER (
        WHERE outcome_code = 'FAILED_AGAIN'
    ) AS failed_count,

    ROUND(
        (
            COUNT(*) FILTER (
                WHERE outcome_code = 'CONFIRMED_OK'
            )::numeric
            /
            NULLIF(COUNT(*),0)
        ) * 100,
        2
    ) AS success_rate_pct,

    MAX(created_at) AS last_attempt_at

FROM ops.repair_outcome_learning
GROUP BY

    provider,
    sport_code,
    entity,
    repair_action;



CREATE OR REPLACE VIEW ops.v_learning_recommendations_v1 AS
SELECT

    provider,
    sport_code,
    entity,
    repair_action,

    total_attempts,
    success_count,
    failed_count,
    success_rate_pct,

    CASE

        WHEN success_rate_pct >= 80
            THEN 'DOPORUČENO K AUTOMATICKÉMU SPUŠTĚNÍ'

        WHEN success_rate_pct >= 50
            THEN 'SPUSTIT OPATRNĚ'

        WHEN success_rate_pct IS NULL
            THEN 'NEDOSTATEK DAT'

        ELSE 'RUČNÍ OVĚŘENÍ'

    END AS recommendation_cz,

    last_attempt_at

FROM ops.v_learning_summary_v1;



CREATE OR REPLACE VIEW ops.v_learning_panel_v1 AS
SELECT

    provider                        AS "Provider",
    sport_code                      AS "Sport",
    entity                          AS "Entita",
    repair_action                   AS "Akce",

    total_attempts                  AS "Pokusů",
    success_count                   AS "Úspěch",
    failed_count                    AS "Neúspěch",

    success_rate_pct                AS "Úspěšnost %",

    recommendation_cz              AS "Doporučení",

    last_attempt_at                 AS "Poslední pokus"

FROM ops.v_learning_recommendations_v1
ORDER BY
    success_rate_pct DESC NULLS LAST,
    last_attempt_at DESC;