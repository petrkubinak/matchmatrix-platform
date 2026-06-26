/*
===============================================================================
MATCHMATRIX 20_1_M – OPERATOR RESULT CLASSIFIER
===============================================================================

CO TO JE:
Klasifikátor výsledků běhů operátorského panelu.

Vyhodnocuje skutečný stav běhu podle obsahu logu a ne pouze podle
návratového kódu launcheru.

===============================================================================

K ČEMU TO JE:

Odhalí situace:

Launcher = DONE
Worker   = ERROR

Příklad:

VB PEOPLE

run_status = DONE

ale log obsahuje:

STATUS       : error
RESULT       : ERROR
RETURNCODE   : 2

Nově:

effective_status = FAILED

===============================================================================

KDE TO UVIDÍME:

OPS PANEL
→ DENNÍ PRÁCE

AKTUÁLNÍ / DALŠÍ BĚH

PC2 COMMAND DETAIL

STOP / CHYBY

===============================================================================

JAK SE TO VYUŽIJE:

Panel nebude zobrazovat:

DONE

pokud log obsahuje:

RESULT: ERROR

nebo:

ROUTING_ERROR

nebo:

STATUS : error

Místo toho zobrazí:

FAILED

a správný důvod chyby.

===============================================================================

NAVAZUJE NA:

20_1_A_harvest_run_monitor.sql

20_1_B_harvest_run_monitor_views.sql

20_1_I_operator_next_action.sql

20_1_J_operator_dashboard_summary.sql

20_1_L_operator_error_explanation.sql

===============================================================================

DALŠÍ KROK:

20_1_N_operator_recommendation_engine.sql

Automatické doporučení:

VB

CHYBÍ SPECIALIZOVANÝ PROVIDER

DOPORUČENÍ:
Otevřít Missing Provider Matrix

STATUS:
RESEARCH_REQUIRED

===============================================================================

SOUBOR:

20_1_M_operator_result_classifier.sql

===============================================================================

KAM ULOŽIT:

C:\MatchMatrix-platform\db\ops\20_1\

===============================================================================

JAK SPUSTIT:

DBeaver

Spustit celý SQL skript:

20_1_M_operator_result_classifier.sql

===============================================================================

CO OČEKÁVAT:

VB:

effective_status = FAILED

classification_reason =
CHYBÍ SPECIALIZOVANÝ PROVIDER

TN:

effective_status = DONE

BSB:

effective_status = DONE

===============================================================================

AUTOR:
MatchMatrix Platform

VĚTEV:
20_1 Operator Center

DATUM:
2026-06-17

===============================================================================
*/

DROP VIEW IF EXISTS ops.v_operator_result_classifier_v1;

CREATE VIEW ops.v_operator_result_classifier_v1
AS
SELECT
    q.id,
    q.sport_code,
    q.sport_name,
    q.target_layer,
    q.command_title,
    q.run_status,
    q.last_result,

    CASE

        WHEN q.last_result ILIKE '%RESULT: ERROR%'
            THEN 'FAILED'

        WHEN q.last_result ILIKE '%STATUS       : error%'
            THEN 'FAILED'

        WHEN q.last_result ILIKE '%RETURNCODE: 2%'
            THEN 'FAILED'

        WHEN q.last_result ILIKE '%ROUTING_ERROR%'
            THEN 'FAILED'

        WHEN q.last_result ILIKE '%not supported%'
            THEN 'FAILED'

        WHEN q.last_result ILIKE '%není podporována%'
            THEN 'FAILED'

        WHEN q.last_result ILIKE '%RESULT: OK%'
            THEN 'DONE'

        ELSE q.run_status

    END AS effective_status,

    CASE

        WHEN q.last_result ILIKE '%GenericApiSportProvider%'
            THEN 'CHYBÍ SPECIALIZOVANÝ PROVIDER'

        WHEN q.last_result ILIKE '%není podporována%'
            THEN 'ENTITY NENÍ PODPOROVÁNA'

        WHEN q.last_result ILIKE '%RESULT: ERROR%'
            THEN 'WORKER ERROR'

        WHEN q.last_result ILIKE '%ROUTING_ERROR%'
            THEN 'ROUTING ERROR'

        ELSE 'OK'

    END AS classification_reason

FROM ops.pc2_run_command_queue q;