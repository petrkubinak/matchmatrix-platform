-- 112_runtime_audit_master_quickcheck_v2.sql
-- Opravená verze:
-- ops.ingest_targets nemá sloupec entity
-- entity bereme z ops.ingest_entity_plan a ops.runtime_entity_audit

-- ============================================================
-- 1) DETAILNÍ PŘEHLED RUNTIME AUDITU
-- ============================================================
SELECT
    provider,
    sport_code,
    entity,
    current_state,
    panel_runner_exists,
    planner_target_exists,
    batch_target_exists,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed,
    last_run_group,
    last_run_at,
    last_check_at,
    next_action
FROM ops.v_runtime_entity_audit_summary
ORDER BY sport_code, state_sort, provider, entity;

-- ============================================================
-- 2) SOUHRN PODLE SPORTU
-- ============================================================
SELECT
    sport_code,
    COUNT(*) AS total_rows,
    SUM(CASE WHEN current_state = 'CONFIRMED' THEN 1 ELSE 0 END) AS confirmed_rows,
    SUM(CASE WHEN current_state = 'RUNNABLE' THEN 1 ELSE 0 END) AS runnable_rows,
    SUM(CASE WHEN current_state = 'PARTIAL' THEN 1 ELSE 0 END) AS partial_rows,
    SUM(CASE WHEN current_state = 'PLANNED' THEN 1 ELSE 0 END) AS planned_rows,
    SUM(CASE WHEN current_state = 'BROKEN' THEN 1 ELSE 0 END) AS broken_rows,
    SUM(CASE WHEN current_state = 'BLOCKED' THEN 1 ELSE 0 END) AS blocked_rows
FROM ops.v_runtime_entity_audit_summary
GROUP BY sport_code
ORDER BY sport_code;

-- ============================================================
-- 3) SOUHRN PODLE STAVU
-- ============================================================
SELECT
    current_state,
    COUNT(*) AS rows_count
FROM ops.v_runtime_entity_audit_summary
GROUP BY current_state
ORDER BY
    CASE current_state
        WHEN 'CONFIRMED' THEN 1
        WHEN 'RUNNABLE' THEN 2
        WHEN 'PARTIAL' THEN 3
        WHEN 'PLANNED' THEN 4
        WHEN 'NOT_TESTED' THEN 5
        WHEN 'BLOCKED' THEN 6
        WHEN 'BROKEN' THEN 7
        ELSE 99
    END;

-- ============================================================
-- 4) CO JE TEĎ NEJBLÍŽE KE SPUŠTĚNÍ
-- ============================================================
SELECT
    provider,
    sport_code,
    entity,
    current_state,
    last_run_group,
    next_action
FROM ops.v_runtime_entity_audit_summary
WHERE current_state IN ('RUNNABLE', 'PARTIAL', 'PLANNED')
ORDER BY sport_code, state_sort, provider, entity;

-- ============================================================
-- 5) CO MÁ ORCHESTRACI, ALE JEŠTĚ NENÍ CONFIRMED
-- ============================================================
SELECT
    provider,
    sport_code,
    entity,
    current_state,
    panel_runner_exists,
    planner_target_exists,
    batch_target_exists,
    next_action
FROM ops.v_runtime_entity_audit_summary
WHERE panel_runner_exists = TRUE
  AND planner_target_exists = TRUE
  AND batch_target_exists = TRUE
  AND current_state <> 'CONFIRMED'
ORDER BY sport_code, state_sort, provider, entity;

-- ============================================================
-- 6) CO JE UŽ POTVRZENÉ
-- ============================================================
SELECT
    provider,
    sport_code,
    entity,
    current_state,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed,
    db_evidence_summary
FROM ops.v_runtime_entity_audit_summary
WHERE current_state = 'CONFIRMED'
ORDER BY sport_code, provider, entity;

-- ============================================================
-- 7) KDE JE CHAIN ZATÍM PRAKTICKY PRÁZDNÝ
-- ============================================================
SELECT
    provider,
    sport_code,
    entity,
    current_state,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed,
    next_action
FROM ops.v_runtime_entity_audit_summary
WHERE pull_confirmed = FALSE
  AND raw_confirmed = FALSE
  AND staging_confirmed = FALSE
  AND provider_map_confirmed = FALSE
  AND public_merge_confirmed = FALSE
  AND downstream_confirmed = FALSE
ORDER BY sport_code, state_sort, provider, entity;

-- ============================================================
-- 8) CHAT EXPORT – KOMPAKTNÍ VÝPIS
-- ============================================================
SELECT
    provider || ' | ' ||
    sport_code || ' | ' ||
    entity || ' | ' ||
    current_state || ' | ' ||
    COALESCE(last_run_group, '-') || ' | ' ||
    COALESCE(next_action, '-') AS chat_export_line
FROM ops.v_runtime_entity_audit_summary
ORDER BY sport_code, state_sort, provider, entity;

-- ============================================================
-- 9) INGEST TARGETS – CO EXISTUJE PRO PROVIDER × SPORT
-- ingest_targets nemá entity
-- ============================================================
SELECT
    provider,
    sport_code,
    COUNT(*) AS target_rows,
    COUNT(*) FILTER (WHERE enabled = TRUE) AS enabled_target_rows,
    COUNT(DISTINCT run_group) FILTER (WHERE COALESCE(BTRIM(run_group), '') <> '') AS run_group_count
FROM ops.ingest_targets
GROUP BY provider, sport_code
ORDER BY sport_code, provider;

-- ============================================================
-- 10) ENTITY PLAN – CO EXISTUJE PRO PROVIDER × SPORT × ENTITY
-- ============================================================
SELECT
    provider,
    sport_code,
    entity,
    enabled
FROM ops.ingest_entity_plan
ORDER BY sport_code, provider, entity;

-- ============================================================
-- 11) CO JE V ENTITY PLANU A CHYBÍ V RUNTIME AUDITU
-- ============================================================
SELECT
    iep.provider,
    iep.sport_code,
    iep.entity,
    iep.enabled
FROM ops.ingest_entity_plan iep
LEFT JOIN ops.runtime_entity_audit rea
  ON rea.provider = iep.provider
 AND rea.sport_code = iep.sport_code
 AND rea.entity = iep.entity
WHERE rea.id IS NULL
ORDER BY iep.sport_code, iep.provider, iep.entity;

-- ============================================================
-- 12) RUNTIME AUDIT vs TARGETS – MÁME AUDIT ŘÁDEK, ALE CHYBÍ TARGETY PRO DANÝ PROVIDER × SPORT
-- ============================================================
SELECT
    rea.provider,
    rea.sport_code,
    COUNT(*) AS audit_rows_for_provider_sport
FROM ops.runtime_entity_audit rea
LEFT JOIN ops.ingest_targets it
  ON it.provider = rea.provider
 AND it.sport_code = rea.sport_code
WHERE it.id IS NULL
GROUP BY rea.provider, rea.sport_code
ORDER BY rea.sport_code, rea.provider;