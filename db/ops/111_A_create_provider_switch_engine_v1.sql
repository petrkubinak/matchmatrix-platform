/*
MATCHMATRIX SQL 111_A Create Provider Switch Engine V1

CO TO JE:
- První AI vrstva pro změnu providera.

K ČEMU TO JE:
- Pokud provider dlouhodobě selhává,
  systém to pozná.
- Navrhne alternativního providera.
- Později umožní automatické smoke testy.

KDE TO UVIDÍME:
- Panel V18+
- AI OPS
- Provider Health
- Autonomous Recommendations

JAK SE TO VYUŽIJE:
- FAILED_AGAIN
- Historie selhání
- Provider score
- Návrh alternativy
*/


CREATE TABLE IF NOT EXISTS ops.provider_switch_recommendations
(
    id bigserial PRIMARY KEY,

    provider text NOT NULL,
    sport_code text NOT NULL,
    entity text NOT NULL,

    current_success_rate numeric(10,2),

    recommendation_type text NOT NULL,

    recommendation_cz text,

    recommended_provider text,

    confidence_score integer,

    created_at timestamptz NOT NULL DEFAULT now(),

    is_processed boolean NOT NULL DEFAULT false
);



CREATE OR REPLACE VIEW ops.v_provider_failure_summary_v1 AS
SELECT

    provider,
    sport_code,
    entity,

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
                WHERE outcome_code='CONFIRMED_OK'
            )::numeric
            /
            NULLIF(COUNT(*),0)
        ) * 100,
        2
    ) AS success_rate_pct,

    MAX(created_at) AS last_attempt

FROM ops.repair_outcome_learning
GROUP BY
    provider,
    sport_code,
    entity;



CREATE OR REPLACE VIEW ops.v_provider_switch_candidates_v1 AS
SELECT

    provider,
    sport_code,
    entity,

    total_attempts,
    success_count,
    failed_count,
    success_rate_pct,

    CASE

        WHEN success_rate_pct < 25
             AND total_attempts >= 5
        THEN 'SWITCH_PROVIDER'

        WHEN success_rate_pct < 50
             AND total_attempts >= 3
        THEN 'INVESTIGATE_PROVIDER'

        ELSE 'KEEP_PROVIDER'

    END AS recommendation_type,

    CASE

        WHEN success_rate_pct < 25
             AND total_attempts >= 5
        THEN 'Provider dlouhodobě selhává. Doporučeno hledat alternativu.'

        WHEN success_rate_pct < 50
             AND total_attempts >= 3
        THEN 'Provider vykazuje problémy. Doporučeno ověření endpointů a coverage.'

        ELSE 'Provider funguje v přijatelné kvalitě.'

    END AS recommendation_cz,

    CASE

        WHEN success_rate_pct >= 80
            THEN 100

        WHEN success_rate_pct >= 60
            THEN 80

        WHEN success_rate_pct >= 40
            THEN 60

        ELSE 30

    END AS confidence_score

FROM ops.v_provider_failure_summary_v1;



CREATE OR REPLACE VIEW ops.v_provider_switch_panel_v1 AS
SELECT

    provider            AS "Provider",
    sport_code          AS "Sport",
    entity              AS "Entita",

    total_attempts      AS "Pokusů",
    success_count       AS "Úspěch",
    failed_count        AS "Neúspěch",

    success_rate_pct    AS "Úspěšnost %",

    recommendation_type AS "Typ doporučení",

    recommendation_cz   AS "Doporučení",

    confidence_score    AS "AI důvěra"

FROM ops.v_provider_switch_candidates_v1
ORDER BY
    success_rate_pct ASC,
    total_attempts DESC;