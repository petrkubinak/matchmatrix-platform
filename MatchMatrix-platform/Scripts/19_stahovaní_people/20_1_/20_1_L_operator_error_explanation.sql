/*
===============================================================================
MATCHMATRIX 20_1_L – OPERATOR ERROR EXPLANATION
===============================================================================

CO TO JE:
View, které převede technický poslední výsledek/chybu z PC2 fronty na čitelný důvod chyby.

K ČEMU TO JE:
Operátor v panelu DENNÍ PRÁCE neuvidí jen FAILED / CHYBA,
ale i krátké vysvětlení:
- TIMEOUT
- 429 RATE LIMIT
- ModuleNotFoundError
- Parser error
- prázdná odpověď providera
- neznámá chyba

KDE TO UVIDÍME:
OPS Panel
→ DENNÍ PRÁCE
→ AKTUÁLNÍ / DALŠÍ BĚH
→ DŮVOD CHYBY

Databáze:
ops.v_operator_error_explanation_v1

JAK SE TO VYUŽIJE:
Panel spojí tuto vrstvu s ops.v_operator_dashboard_summary_v1
a do červeného boxu vypíše:
PROČ se akce zastavila a CO má operátor udělat.

NAVAZUJE NA:
20_1_I_operator_next_action.sql
20_1_J_operator_dashboard_summary.sql
20_1_K_operator_panel_visual_binding.py

DALŠÍ KROK:
20_1_M_operator_dashboard_summary_with_error.sql
===============================================================================
*/

DROP VIEW IF EXISTS ops.v_operator_error_explanation_v1;

CREATE VIEW ops.v_operator_error_explanation_v1
AS
SELECT
    q.id AS command_id,
    q.sport_code,
    q.sport_name,
    q.target_layer,
    q.command_title,
    q.run_status,
    q.priority_score,
    q.last_result,

    CASE
        WHEN q.last_result ILIKE '%ModuleNotFoundError%' THEN 'MODULE_NOT_FOUND'
        WHEN q.last_result ILIKE '%Traceback%' THEN 'PYTHON_TRACEBACK'
        WHEN q.last_result ILIKE '%TIMEOUT%' THEN 'TIMEOUT'
        WHEN q.last_result ILIKE '%429%' THEN 'RATE_LIMIT_429'
        WHEN q.last_result ILIKE '%403%' THEN 'FORBIDDEN_403'
        WHEN q.last_result ILIKE '%401%' THEN 'UNAUTHORIZED_401'
        WHEN q.last_result ILIKE '%subscription%' THEN 'SUBSCRIPTION_REQUIRED'
        WHEN q.last_result ILIKE '%RESULTS=0%' THEN 'EMPTY_RESPONSE'
        WHEN q.last_result ILIKE '%parser%' THEN 'PARSER_ERROR'
        WHEN q.last_result ILIKE '%return_code=1%' THEN 'RETURN_CODE_1'
        WHEN q.run_status IN ('FAILED', 'ERROR', 'CHYBA') THEN 'UNKNOWN_ERROR'
        ELSE 'NO_ERROR'
    END AS error_code_detected,

    CASE
        WHEN q.last_result ILIKE '%ModuleNotFoundError%' THEN 'Chybí Python modul nebo špatná import cesta.'
        WHEN q.last_result ILIKE '%Traceback%' THEN 'Worker spadl na Python výjimce. Je potřeba otevřít log.'
        WHEN q.last_result ILIKE '%TIMEOUT%' THEN 'Provider nebo worker neodpověděl v časovém limitu.'
        WHEN q.last_result ILIKE '%429%' THEN 'Provider vrátil rate limit. Je potřeba počkat.'
        WHEN q.last_result ILIKE '%403%' THEN 'Provider zakázal přístup. Může jít o plán, endpoint nebo klíč.'
        WHEN q.last_result ILIKE '%401%' THEN 'Chyba autorizace. Zkontroluj API klíč.'
        WHEN q.last_result ILIKE '%subscription%' THEN 'Endpoint pravděpodobně vyžaduje placený plán.'
        WHEN q.last_result ILIKE '%RESULTS=0%' THEN 'Provider odpověděl, ale nevrátil žádná data.'
        WHEN q.last_result ILIKE '%parser%' THEN 'Data přišla, ale parser je neuměl zpracovat.'
        WHEN q.last_result ILIKE '%return_code=1%' THEN 'Worker skončil chybou. Detail je v posledním výsledku/logu.'
        WHEN q.run_status IN ('FAILED', 'ERROR', 'CHYBA') THEN 'Akce skončila chybou, ale typ chyby zatím nebyl rozpoznán.'
        ELSE 'Bez aktivní chyby.'
    END AS error_reason_cz,

    CASE
        WHEN q.last_result ILIKE '%ModuleNotFoundError%' THEN 'Otevři log a oprav import / cestu ke skriptu.'
        WHEN q.last_result ILIKE '%Traceback%' THEN 'Otevři detail logu a najdi poslední řádek Tracebacku.'
        WHEN q.last_result ILIKE '%TIMEOUT%' THEN 'Zkus RETRY / READY s menší dávkou nebo později.'
        WHEN q.last_result ILIKE '%429%' THEN 'Počkej podle API limitu a spusť retry později.'
        WHEN q.last_result ILIKE '%403%' THEN 'Ověř API plán, endpoint a oprávnění.'
        WHEN q.last_result ILIKE '%401%' THEN 'Ověř API klíč a provider konfiguraci.'
        WHEN q.last_result ILIKE '%subscription%' THEN 'Zařaď do WAIT_FOR_PAID_PLAN nebo hledej fallback provider.'
        WHEN q.last_result ILIKE '%RESULTS=0%' THEN 'Ověř, zda pro ligu/sezónu opravdu existují data.'
        WHEN q.last_result ILIKE '%parser%' THEN 'Otevři parser worker a oprav mapování polí.'
        WHEN q.last_result ILIKE '%return_code=1%' THEN 'Otevři log, oprav příčinu a potom vrať akci na READY.'
        WHEN q.run_status IN ('FAILED', 'ERROR', 'CHYBA') THEN 'Otevři detail posledního výsledku a rozhodni: auto-fix / retry / ruční oprava.'
        ELSE 'Můžeš pokračovat další připravenou akcí.'
    END AS operator_fix_hint_cz,

    CASE
        WHEN q.run_status IN ('FAILED', 'ERROR', 'CHYBA') THEN 'RED'
        WHEN q.run_status IN ('RUNNING', 'BĚŽÍ') THEN 'YELLOW'
        WHEN q.run_status IN ('READY', 'READY_TO_RUN', 'PŘIPRAVENO') THEN 'GREEN'
        WHEN q.run_status IN ('DONE', 'HOTOVO') THEN 'GREEN'
        ELSE 'YELLOW'
    END AS traffic_light

FROM ops.pc2_run_command_queue q
WHERE q.panel_visible = true;