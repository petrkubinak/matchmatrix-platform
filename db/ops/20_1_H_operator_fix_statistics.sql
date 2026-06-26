/*
===============================================================================
MATCHMATRIX 20_1_H – OPERATOR FIX STATISTICS
===============================================================================

CO TO JE:
Statistický přehled úspěšnosti operátorských oprav v DENNÍ PRÁCI.

K ČEMU TO JE:
Panel nebude jen ukazovat doporučenou opravu, ale i její historickou úspěšnost.

Příklad:
TIMEOUT
→ RETRY_READY
→ použito 12x
→ úspěšnost 91.67 %

KDE TO UVIDÍME:
OPS Panel
→ DENNÍ PRÁCE
→ CHYBY / STOP
→ DOPORUČENÁ OPRAVA
→ ÚSPĚŠNOST OPRAVY

Databáze:
ops.v_operator_fix_statistics_v1

JAK SE TO VYUŽIJE:
Při další chybě panel zobrazí:
- doporučenou opravu
- počet použití
- počet úspěchů
- procento úspěšnosti
- riziko
- zda je oprava auto-executable

NAVAZUJE NA:
20_1_C_operator_fix_catalog.sql
20_1_D_operator_fix_recommendations.sql
20_1_E_operator_fix_execution_log.sql
20_1_F_operator_auto_fix_engine.sql

DALŠÍ KROK:
20_1_I_operator_next_action.sql
===============================================================================
*/

DROP VIEW IF EXISTS ops.v_operator_fix_statistics_v1;

CREATE VIEW ops.v_operator_fix_statistics_v1
AS
SELECT
    c.error_code,
    c.fix_code,
    c.fix_title_cz,
    c.operator_button_cz,
    c.risk_level,
    c.confidence_pct AS default_confidence_pct,
    c.auto_executable,
    c.requires_operator_confirm,

    COUNT(l.fix_execution_id) AS total_attempts,

    COUNT(l.fix_execution_id) FILTER (
        WHERE l.execution_status = 'SUCCESS'
           OR l.execution_result = 'FIX_APPLIED'
    ) AS success_attempts,

    COUNT(l.fix_execution_id) FILTER (
        WHERE l.execution_status IN ('FAILED', 'BLOCKED')
           OR l.execution_result IN ('MANUAL_REQUIRED', 'UNSUPPORTED_ACTION')
    ) AS failed_or_blocked_attempts,

    CASE
        WHEN COUNT(l.fix_execution_id) = 0 THEN c.confidence_pct
        ELSE ROUND(
            100.0 * COUNT(l.fix_execution_id) FILTER (
                WHERE l.execution_status = 'SUCCESS'
                   OR l.execution_result = 'FIX_APPLIED'
            ) / COUNT(l.fix_execution_id),
            2
        )
    END AS learned_success_pct,

    CASE
        WHEN COUNT(l.fix_execution_id) = 0 THEN 'BEZ HISTORIE'
        WHEN ROUND(
            100.0 * COUNT(l.fix_execution_id) FILTER (
                WHERE l.execution_status = 'SUCCESS'
                   OR l.execution_result = 'FIX_APPLIED'
            ) / COUNT(l.fix_execution_id),
            2
        ) >= 90 THEN 'VYSOKÁ ÚSPĚŠNOST'
        WHEN ROUND(
            100.0 * COUNT(l.fix_execution_id) FILTER (
                WHERE l.execution_status = 'SUCCESS'
                   OR l.execution_result = 'FIX_APPLIED'
            ) / COUNT(l.fix_execution_id),
            2
        ) >= 70 THEN 'DOBRÁ ÚSPĚŠNOST'
        WHEN ROUND(
            100.0 * COUNT(l.fix_execution_id) FILTER (
                WHERE l.execution_status = 'SUCCESS'
                   OR l.execution_result = 'FIX_APPLIED'
            ) / COUNT(l.fix_execution_id),
            2
        ) >= 50 THEN 'NEJISTÉ'
        ELSE 'SLABÁ ÚSPĚŠNOST'
    END AS learned_success_label_cz,

    MAX(l.finished_at) AS last_fix_finished_at

FROM ops.operator_fix_catalog c

LEFT JOIN ops.operator_fix_execution_log l
    ON l.fix_code = c.fix_code
   AND l.error_code = c.error_code

WHERE c.is_active = true

GROUP BY
    c.error_code,
    c.fix_code,
    c.fix_title_cz,
    c.operator_button_cz,
    c.risk_level,
    c.confidence_pct,
    c.auto_executable,
    c.requires_operator_confirm;