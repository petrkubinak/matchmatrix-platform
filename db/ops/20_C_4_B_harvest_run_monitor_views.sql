/*
===============================================================================
MATCHMATRIX 20_C_4_B – HARVEST RUN MONITOR VIEWS
===============================================================================

CO TO JE:
Operační view nad ops.harvest_run_monitor pro grafické karty v DENNÍ PRÁCI.

K ČEMU TO JE:
Překládá technické běhy na srozumitelný operátorský výstup:
- aktuální běh
- poslední výsledek
- chyby / stop
- dnešní souhrn

KDE TO UVIDÍME:
OPS Panel
→ DENNÍ PRÁCE
→ DNEŠNÍ POSTUP
→ AKTUÁLNÍ BĚH
→ POSLEDNÍ VÝSLEDEK
→ CHYBY / STOP

JAK SE TO VYUŽIJE:
Panel nebude číst surovou tabulku, ale připravená view.
Grafické karty dostanou procenta, barvy, stav a doporučení.

NAVAZUJE NA:
20_C_4_A Harvest Run Monitor

DALŠÍ KROK:
20_C_4_C Napojení panelu na monitor view
===============================================================================
*/

DROP VIEW IF EXISTS ops.v_operator_today_progress_v1;
DROP VIEW IF EXISTS ops.v_operator_current_run_v1;
DROP VIEW IF EXISTS ops.v_operator_last_result_v1;
DROP VIEW IF EXISTS ops.v_operator_stop_errors_v1;

CREATE VIEW ops.v_operator_today_progress_v1 AS
SELECT
    CURRENT_DATE AS work_day,

    COUNT(*) AS total_runs,

    COUNT(*) FILTER (
        WHERE run_status IN ('DONE', 'SUCCESS', 'COMPLETED')
    ) AS done_runs,

    COUNT(*) FILTER (
        WHERE run_status IN ('RUNNING', 'IN_PROGRESS')
    ) AS running_runs,

    COUNT(*) FILTER (
        WHERE run_status IN ('READY', 'PENDING', 'READY_TO_RUN')
    ) AS waiting_runs,

    COUNT(*) FILTER (
        WHERE run_status IN ('ERROR', 'FAILED')
    ) AS error_runs,

    COUNT(*) FILTER (
        WHERE run_status IN ('BLOCKED', 'ON_HOLD')
    ) AS blocked_runs,

    CASE
        WHEN COUNT(*) = 0 THEN 0
        ELSE ROUND(
            100.0 * COUNT(*) FILTER (
                WHERE run_status IN ('DONE', 'SUCCESS', 'COMPLETED')
            ) / COUNT(*),
            2
        )
    END AS day_progress_pct,

    CASE
        WHEN COUNT(*) FILTER (WHERE run_status IN ('ERROR', 'FAILED')) > 0 THEN 'RED'
        WHEN COUNT(*) FILTER (WHERE run_status IN ('RUNNING', 'IN_PROGRESS')) > 0 THEN 'YELLOW'
        WHEN COUNT(*) FILTER (WHERE run_status IN ('READY', 'PENDING', 'READY_TO_RUN')) > 0 THEN 'GREEN'
        ELSE 'GREEN'
    END AS traffic_light,

    CASE
        WHEN COUNT(*) FILTER (WHERE run_status IN ('ERROR', 'FAILED')) > 0 THEN 'Zastav se a vyřeš chyby.'
        WHEN COUNT(*) FILTER (WHERE run_status IN ('RUNNING', 'IN_PROGRESS')) > 0 THEN 'Sleduj aktuální běh.'
        WHEN COUNT(*) FILTER (WHERE run_status IN ('READY', 'PENDING', 'READY_TO_RUN')) > 0 THEN 'Můžeš pokračovat další připravenou akcí.'
        ELSE 'Dnešní fronta je hotová.'
    END AS operator_message

FROM ops.harvest_run_monitor
WHERE created_at::date = CURRENT_DATE;


CREATE VIEW ops.v_operator_current_run_v1 AS
SELECT
    monitor_id,
    run_key,
    sport_code,
    sport_name,
    provider,
    entity_type,
    target_layer,
    run_status,
    COALESCE(run_status_cz, run_status) AS run_status_cz,

    started_at,
    last_heartbeat_at,
    finished_at,

    total_count,
    processed_count,
    inserted_count,
    updated_count,
    skipped_count,
    error_count,

    CASE
        WHEN total_count > 0 THEN ROUND(100.0 * processed_count / total_count, 2)
        ELSE COALESCE(progress_pct, 0)
    END AS progress_pct,

    eta_seconds,

    CASE
        WHEN run_status IN ('ERROR', 'FAILED') THEN 'RED'
        WHEN run_status IN ('RUNNING', 'IN_PROGRESS') THEN 'YELLOW'
        WHEN run_status IN ('DONE', 'SUCCESS', 'COMPLETED') THEN 'GREEN'
        WHEN run_status IN ('BLOCKED', 'ON_HOLD') THEN 'BLACK'
        ELSE 'GREEN'
    END AS traffic_light,

    CASE
        WHEN run_status IN ('ERROR', 'FAILED') THEN 'Chyba běhu – otevři doporučení.'
        WHEN run_status IN ('RUNNING', 'IN_PROGRESS') THEN 'Běh právě probíhá.'
        WHEN run_status IN ('READY', 'PENDING', 'READY_TO_RUN') THEN 'Připraveno ke spuštění.'
        WHEN run_status IN ('DONE', 'SUCCESS', 'COMPLETED') THEN 'Běh dokončen.'
        ELSE 'Zkontroluj stav běhu.'
    END AS operator_message,

    result_message,
    operator_recommendation,
    updated_at

FROM ops.harvest_run_monitor
WHERE run_status IN ('RUNNING', 'IN_PROGRESS', 'READY', 'PENDING', 'READY_TO_RUN')
ORDER BY
    CASE
        WHEN run_status IN ('RUNNING', 'IN_PROGRESS') THEN 1
        WHEN run_status IN ('READY', 'READY_TO_RUN') THEN 2
        ELSE 3
    END,
    updated_at DESC
LIMIT 1;


CREATE VIEW ops.v_operator_last_result_v1 AS
SELECT
    monitor_id,
    run_key,
    sport_code,
    sport_name,
    provider,
    entity_type,
    target_layer,
    run_status,
    COALESCE(run_status_cz, run_status) AS run_status_cz,
    started_at,
    finished_at,

    total_count,
    processed_count,
    inserted_count,
    updated_count,
    skipped_count,
    error_count,

    CASE
        WHEN total_count > 0 THEN ROUND(100.0 * processed_count / total_count, 2)
        ELSE COALESCE(progress_pct, 0)
    END AS result_pct,

    return_code,
    result_message,

    CASE
        WHEN run_status IN ('DONE', 'SUCCESS', 'COMPLETED') AND error_count = 0 THEN 'GREEN'
        WHEN run_status IN ('DONE', 'SUCCESS', 'COMPLETED') AND error_count > 0 THEN 'YELLOW'
        WHEN run_status IN ('ERROR', 'FAILED') THEN 'RED'
        ELSE 'YELLOW'
    END AS traffic_light,

    CASE
        WHEN run_status IN ('DONE', 'SUCCESS', 'COMPLETED') AND error_count = 0 THEN 'Hotovo bez chyb. Můžeš pokračovat další akcí.'
        WHEN run_status IN ('DONE', 'SUCCESS', 'COMPLETED') AND error_count > 0 THEN 'Hotovo s chybami. Zkontroluj detail.'
        WHEN run_status IN ('ERROR', 'FAILED') THEN 'Běh skončil chybou. Nejdřív řeš opravu.'
        ELSE 'Výsledek vyžaduje kontrolu.'
    END AS operator_message,

    operator_recommendation,
    updated_at

FROM ops.harvest_run_monitor
WHERE run_status IN ('DONE', 'SUCCESS', 'COMPLETED', 'ERROR', 'FAILED')
ORDER BY
    COALESCE(finished_at, updated_at, created_at) DESC
LIMIT 1;


CREATE VIEW ops.v_operator_stop_errors_v1 AS
SELECT
    monitor_id,
    run_key,
    sport_code,
    sport_name,
    provider,
    entity_type,
    target_layer,
    run_status,
    last_error_code,
    last_error_message,
    error_count,

    CASE
        WHEN last_error_code ILIKE '%429%' THEN 'Počkej a spusť retry později.'
        WHEN last_error_code ILIKE '%TIMEOUT%' THEN 'Zkus retry s menší dávkou.'
        WHEN last_error_code ILIKE '%DUPLICATE%' THEN 'Zkontroluj UPSERT / ON CONFLICT.'
        WHEN last_error_code ILIKE '%PARSER%' THEN 'Zkontroluj parser worker.'
        WHEN run_status IN ('ERROR', 'FAILED') THEN 'Otevři log a rozhodni: retry / oprava / přeskočit.'
        ELSE 'Bez aktivní chyby.'
    END AS recommended_fix_cz,

    'RED' AS traffic_light,
    updated_at

FROM ops.harvest_run_monitor
WHERE run_status IN ('ERROR', 'FAILED')
ORDER BY
    updated_at DESC,
    monitor_id DESC
LIMIT 10;