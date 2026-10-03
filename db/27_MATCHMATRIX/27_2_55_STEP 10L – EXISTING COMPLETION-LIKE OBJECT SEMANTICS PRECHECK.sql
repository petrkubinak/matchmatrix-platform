/*
CO:
STEP 10L – EXISTING COMPLETION-LIKE OBJECT SEMANTICS PRECHECK

K ČEMU:
Před návrhem nového Harvest Completion Registry ověřit,
jak jsou reálně používány tři existující kandidátní objekty:

- ops.sport_completion_audit
- ops.harvest_run_monitor
- ops.harvest_readiness_snapshot

CÍL:
Rozhodnout, zda:
A) některý objekt lze bezpečně rozšířit,
nebo
B) nový exact Harvest Completion Registry musí vzniknout samostatně.

JAK:
Pouze SELECT.
Žádný INSERT / UPDATE / DELETE / DDL.
*/


/* =========================================================
   1. POČTY ŘÁDKŮ
   ========================================================= */

SELECT
    'sport_completion_audit' AS object_name,
    COUNT(*) AS rows_count
FROM ops.sport_completion_audit

UNION ALL

SELECT
    'harvest_run_monitor',
    COUNT(*)
FROM ops.harvest_run_monitor

UNION ALL

SELECT
    'harvest_readiness_snapshot',
    COUNT(*)
FROM ops.harvest_readiness_snapshot

ORDER BY object_name;


/* =========================================================
   2. SPORT_COMPLETION_AUDIT – SKUTEČNÝ OBSAH
   ========================================================= */

SELECT *
FROM ops.sport_completion_audit
ORDER BY
    sport_code,
    entity
LIMIT 200;


/* =========================================================
   3. HARVEST_RUN_MONITOR – POSLEDNÍ BĚHY
   ========================================================= */

SELECT
    monitor_id,
    run_key,
    run_group,
    worker_name,
    sport_code,
    provider,
    entity_type,
    target_layer,
    season_from,
    season_to,
    current_season,
    run_status,
    started_at,
    finished_at,
    total_count,
    processed_count,
    inserted_count,
    updated_count,
    skipped_count,
    error_count,
    progress_pct,
    return_code,
    result_message
FROM ops.harvest_run_monitor
ORDER BY monitor_id DESC
LIMIT 100;


/* =========================================================
   4. HARVEST_READINESS_SNAPSHOT – AKTUÁLNÍ OBSAH
   ========================================================= */

SELECT *
FROM ops.harvest_readiness_snapshot
ORDER BY
    snapshot_at DESC,
    sport_code
LIMIT 200;


/* =========================================================
   5. VIEWS ZÁVISLÉ NA SPORT_COMPLETION_AUDIT
   ========================================================= */

SELECT
    schemaname,
    viewname
FROM pg_views
WHERE definition ILIKE '%sport_completion_audit%'
ORDER BY
    schemaname,
    viewname;


/* =========================================================
   6. VIEWS ZÁVISLÉ NA HARVEST_RUN_MONITOR
   ========================================================= */

SELECT
    schemaname,
    viewname
FROM pg_views
WHERE definition ILIKE '%harvest_run_monitor%'
ORDER BY
    schemaname,
    viewname;


/* =========================================================
   7. VIEWS ZÁVISLÉ NA HARVEST_READINESS_SNAPSHOT
   ========================================================= */

SELECT
    schemaname,
    viewname
FROM pg_views
WHERE definition ILIKE '%harvest_readiness_snapshot%'
ORDER BY
    schemaname,
    viewname;


/* =========================================================
   8. FUNKCE / PROCEDURY ODKAZUJÍCÍ NA TYTO OBJEKTY
   ========================================================= */

SELECT
    n.nspname AS schema_name,
    p.proname AS routine_name,
    p.prokind AS routine_kind,

    CASE
        WHEN pg_get_functiondef(p.oid)
             ILIKE '%sport_completion_audit%'
            THEN 'sport_completion_audit'

        WHEN pg_get_functiondef(p.oid)
             ILIKE '%harvest_run_monitor%'
            THEN 'harvest_run_monitor'

        WHEN pg_get_functiondef(p.oid)
             ILIKE '%harvest_readiness_snapshot%'
            THEN 'harvest_readiness_snapshot'

        ELSE 'OTHER'
    END AS referenced_object

FROM pg_proc p

JOIN pg_namespace n
  ON n.oid = p.pronamespace

WHERE p.prokind IN ('f', 'p')
  AND (
       pg_get_functiondef(p.oid)
           ILIKE '%sport_completion_audit%'

    OR pg_get_functiondef(p.oid)
           ILIKE '%harvest_run_monitor%'

    OR pg_get_functiondef(p.oid)
           ILIKE '%harvest_readiness_snapshot%'
  )

ORDER BY
    referenced_object,
    n.nspname,
    p.proname;


/* =========================================================
   9. TRIGGERY NA TĚCHTO TABULKÁCH
   ========================================================= */

SELECT
    n.nspname AS table_schema,
    c.relname AS table_name,
    t.tgname AS trigger_name,
    pg_get_triggerdef(t.oid, true) AS trigger_definition

FROM pg_trigger t

JOIN pg_class c
  ON c.oid = t.tgrelid

JOIN pg_namespace n
  ON n.oid = c.relnamespace

WHERE NOT t.tgisinternal

  AND n.nspname = 'ops'

  AND c.relname IN (
      'sport_completion_audit',
      'harvest_run_monitor',
      'harvest_readiness_snapshot'
  )

ORDER BY
    c.relname,
    t.tgname;