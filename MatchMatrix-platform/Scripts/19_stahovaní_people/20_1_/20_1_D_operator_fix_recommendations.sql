/*
===============================================================================
MATCHMATRIX 20_1_D – OPERATOR FIX RECOMMENDATIONS
===============================================================================

CO TO JE:
Doporučovací vrstva mezi detekovanou chybou a operátorem.

K ČEMU TO JE:
Převede technickou chybu na konkrétní doporučenou akci.

Příklad:

TIMEOUT
↓
OPAKOVAT
↓
90 % úspěšnost
↓
AUTO EXECUTABLE = TRUE

KDE TO UVIDÍME:
OPS Panel
→ DENNÍ PRÁCE
→ CHYBY / STOP
→ DOPORUČENÁ OPRAVA

ZDROJE:
ops.v_operator_stop_errors_v1
ops.operator_fix_catalog

NAVAZUJE NA:
20_1_A_harvest_run_monitor.sql
20_1_B_harvest_run_monitor_views.sql
20_1_C_operator_fix_catalog.sql

DALŠÍ KROK:
20_1_E_operator_fix_execution_log.sql
===============================================================================
*/

DROP VIEW IF EXISTS ops.v_operator_fix_recommendations_v1;

CREATE VIEW ops.v_operator_fix_recommendations_v1
AS
SELECT

    e.monitor_id,
    e.run_key,

    e.sport_code,
    e.sport_name,

    e.provider,
    e.entity_type,
    e.target_layer,

    e.run_status,

    e.last_error_code,
    e.last_error_message,

    c.fix_id,
    c.fix_code,

    c.fix_title_cz,
    c.fix_description_cz,
    c.operator_button_cz,

    c.risk_level,
    c.confidence_pct,

    c.auto_executable,
    c.requires_operator_confirm,

    c.target_table,
    c.target_action,

    e.recommended_fix_cz
        AS monitor_recommendation,

    CASE
        WHEN c.confidence_pct >= 90 THEN 'GREEN'
        WHEN c.confidence_pct >= 75 THEN 'YELLOW'
        ELSE 'RED'
    END
        AS confidence_color,

    CASE
        WHEN c.auto_executable THEN
            'Panel může opravu provést automaticky.'
        ELSE
            'Vyžaduje rozhodnutí operátora.'
    END
        AS execution_mode_cz,

    now()
        AS generated_at

FROM ops.v_operator_stop_errors_v1 e

LEFT JOIN ops.operator_fix_catalog c
    ON (
        UPPER(e.last_error_code)
        =
        UPPER(c.error_code)
    )

WHERE c.is_active = true;