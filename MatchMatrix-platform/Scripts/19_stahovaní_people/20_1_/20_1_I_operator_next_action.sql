/*
===============================================================================
MATCHMATRIX 20_1_I – OPERATOR NEXT ACTION
===============================================================================

CO TO JE:
Motor doporučené další akce pro operátora v záložce DENNÍ PRÁCE.

K ČEMU TO JE:
Panel nebude jen zobrazovat frontu, ale jasně řekne:
- co spustit dál,
- co sledovat,
- co opravit,
- co je hotové,
- proč je daná akce doporučená.

KDE TO UVIDÍME:
OPS Panel
→ DENNÍ PRÁCE
→ AKTUÁLNÍ / DALŠÍ BĚH
→ DOPORUČENÁ DALŠÍ AKCE

Databáze:
ops.v_operator_next_action_v1

JAK SE TO VYUŽIJE:
Panel vezme první řádek podle operator_rank a zobrazí ho jako hlavní doporučení.
Tabulka detailů zůstane dole jako doplněk.

NAVAZUJE NA:
20_1_A_harvest_run_monitor.sql
20_1_B_harvest_run_monitor_views.sql
20_1_H_operator_fix_statistics.sql

DALŠÍ KROK:
20_1_J_operator_dashboard_summary.sql
===============================================================================
*/

DROP VIEW IF EXISTS ops.v_operator_next_action_v1;

CREATE VIEW ops.v_operator_next_action_v1
AS
SELECT
    q.id AS command_id,

    q.sport_code,
    q.sport_name,
    q.target_layer,
    q.execution_bucket,

    q.priority_score,
    q.command_title,
    q.command_text,
    q.run_status,
    q.run_group,

    q.worker_name,
    q.worker_script,
    q.safety_mode,

    q.panel_visible,
    q.panel_action_enabled,

    q.last_started_at,
    q.last_finished_at,
    q.last_result,

    q.action_description,
    q.purpose_description,
    q.target_tables,
    q.panel_usage,
    q.expected_result,

    CASE
        WHEN q.run_status IN ('READY', 'READY_TO_RUN', 'PŘIPRAVENO') THEN 'SPUSTIT'
        WHEN q.run_status IN ('RUNNING', 'BĚŽÍ') THEN 'SLEDOVAT'
        WHEN q.run_status IN ('ERROR', 'FAILED', 'CHYBA') THEN 'OPRAVIT'
        WHEN q.run_status IN ('DONE', 'HOTOVO') THEN 'HOTOVO'
        WHEN q.run_status IN ('BLOCKED', 'BLOKOVÁNO') THEN 'BLOKOVÁNO'
        ELSE 'ZKONTROLOVAT'
    END AS operator_action,

    CASE
        WHEN q.run_status IN ('READY', 'READY_TO_RUN', 'PŘIPRAVENO')
            THEN 'Akce je připravena ke spuštění.'
        WHEN q.run_status IN ('RUNNING', 'BĚŽÍ')
            THEN 'Akce právě běží. Sleduj průběh v monitoru.'
        WHEN q.run_status IN ('ERROR', 'FAILED', 'CHYBA')
            THEN 'Nejdříve vyřeš chybu nebo spusť auto-fix.'
        WHEN q.run_status IN ('DONE', 'HOTOVO')
            THEN 'Akce je dokončená. Pokračuj další připravenou akcí.'
        WHEN q.run_status IN ('BLOCKED', 'BLOKOVÁNO')
            THEN 'Akce je blokovaná. Nejdříve zkontroluj důvod blokace.'
        ELSE 'Stav vyžaduje kontrolu operátora.'
    END AS recommendation_reason,

    CASE
        WHEN q.run_status IN ('ERROR', 'FAILED', 'CHYBA') THEN 'RED'
        WHEN q.run_status IN ('RUNNING', 'BĚŽÍ') THEN 'YELLOW'
        WHEN q.run_status IN ('READY', 'READY_TO_RUN', 'PŘIPRAVENO') THEN 'GREEN'
        WHEN q.run_status IN ('DONE', 'HOTOVO') THEN 'GREEN'
        WHEN q.run_status IN ('BLOCKED', 'BLOKOVÁNO') THEN 'BLACK'
        ELSE 'YELLOW'
    END AS traffic_light,

    ROW_NUMBER() OVER
    (
        ORDER BY
            CASE
                WHEN q.run_status IN ('ERROR', 'FAILED', 'CHYBA') THEN 1
                WHEN q.run_status IN ('RUNNING', 'BĚŽÍ') THEN 2
                WHEN q.run_status IN ('READY', 'READY_TO_RUN', 'PŘIPRAVENO') THEN 3
                WHEN q.run_status IN ('DONE', 'HOTOVO') THEN 8
                WHEN q.run_status IN ('BLOCKED', 'BLOKOVÁNO') THEN 9
                ELSE 7
            END,
            q.priority_score DESC NULLS LAST,
            q.id ASC
    ) AS operator_rank

FROM ops.pc2_run_command_queue q
WHERE q.panel_visible = true;