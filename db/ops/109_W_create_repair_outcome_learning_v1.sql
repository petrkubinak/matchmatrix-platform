/*
MATCHMATRIX SQL 109_W Create Repair Outcome Learning V1

CO TO JE:
- Učící vrstva OPS.
- Evidence výsledků oprav.

K ČEMU TO JE:
- Aby systém věděl, které opravy fungují.
- Aby se postupně učil nejlepší řešení.
- Aby mohl doporučovat jiného providera.

KDE TO UVIDÍME:
- AI OPS
- BLOKOVANÉ
- KNOWLEDGE BASE
- AUTONOMOUS OPS

JAK SE TO VYUŽIJE:
- oprava
- reset
- opětovné spuštění
- výsledek
- uložení zkušenosti
*/


CREATE TABLE IF NOT EXISTS ops.repair_outcome_learning (

    id bigserial PRIMARY KEY,

    reason_code text NOT NULL,

    provider text,
    sport_code text,
    entity text,

    repair_action text,

    outcome_code text NOT NULL,

    outcome_note text,

    created_at timestamptz NOT NULL DEFAULT now()

);



CREATE TABLE IF NOT EXISTS ops.repair_outcome_catalog (

    outcome_code text PRIMARY KEY,

    outcome_name text NOT NULL,

    outcome_description text NOT NULL

);



INSERT INTO ops.repair_outcome_catalog (
    outcome_code,
    outcome_name,
    outcome_description
)
VALUES

(
'CONFIRMED_OK',
'Oprava úspěšná',
'Po opravě a resetu proběhl harvest úspěšně.'
),

(
'FAILED_AGAIN',
'Stejná chyba znovu',
'Po opravě se znovu objevil stejný problém.'
),

(
'NEW_ERROR',
'Nový typ chyby',
'Po opravě vznikl jiný problém.'
),

(
'PROVIDER_SWITCH_NEEDED',
'Nutná změna providera',
'Provider dlouhodobě neposkytuje použitelná data.'
),

(
'ABANDONED',
'Vyřazeno',
'Položka byla vyřazena z dalšího zpracování.'
)

ON CONFLICT DO NOTHING;



CREATE OR REPLACE VIEW ops.v_repair_learning_stats_v1 AS
SELECT

    reason_code,

    COUNT(*) AS total_cases,

    COUNT(*) FILTER (
        WHERE outcome_code='CONFIRMED_OK'
    ) AS success_count,

    COUNT(*) FILTER (
        WHERE outcome_code='FAILED_AGAIN'
    ) AS failed_again_count,

    COUNT(*) FILTER (
        WHERE outcome_code='NEW_ERROR'
    ) AS new_error_count,

    COUNT(*) FILTER (
        WHERE outcome_code='PROVIDER_SWITCH_NEEDED'
    ) AS provider_switch_count,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE outcome_code='CONFIRMED_OK'
        )
        /
        NULLIF(COUNT(*),0)
    ,2) AS success_pct

FROM ops.repair_outcome_learning
GROUP BY reason_code;



CREATE OR REPLACE VIEW ops.v_repair_learning_recommendations_v1 AS
SELECT

    reason_code,

    total_cases,

    success_count,

    success_pct,

    provider_switch_count,

    CASE

        WHEN provider_switch_count >= 5
        THEN 'ZVÁŽIT ZMĚNU PROVIDERA'

        WHEN success_pct >= 80
        THEN 'DOPORUČENÁ OPRAVA JE OVĚŘENÁ'

        WHEN success_pct BETWEEN 40 AND 79
        THEN 'ČÁSTEČNĚ ÚSPĚŠNÉ'

        WHEN success_pct < 40
        THEN 'NUTNÁ DALŠÍ ANALÝZA'

        ELSE 'SBÍRÁNÍ DAT'

    END AS ai_recommendation

FROM ops.v_repair_learning_stats_v1;