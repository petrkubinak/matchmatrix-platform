-- =====================================================================
-- 575_create_v_harvest_e2e_control.sql
-- Účel:
-- centrální řídicí view pro budoucí E2E harvester
-- =====================================================================

DROP VIEW IF EXISTS ops.v_harvest_e2e_control;

CREATE VIEW ops.v_harvest_e2e_control AS
WITH targets AS (
    SELECT
        it.provider,
        it.sport_code,
        it.run_group,
        COUNT(*) AS targets_total,
        COUNT(*) FILTER (WHERE it.enabled = TRUE) AS targets_enabled
    FROM ops.ingest_targets it
    GROUP BY it.provider, it.sport_code, it.run_group
),
entity_plan AS (
    SELECT
        iep.provider,
        iep.sport_code,
        iep.entity,
        iep.enabled,
        iep.priority,
        iep.default_run_group,
        iep.ingest_mode,
        iep.scope_type,
        iep.requires_league,
        iep.requires_season,
        iep.source_endpoint,
        iep.target_table,
        iep.worker_script
    FROM ops.ingest_entity_plan iep
),
coverage AS (
    SELECT
        pec.provider,
        pec.sport_code,
        pec.entity,
        pec.coverage_status,
        pec.is_enabled,
        pec.provider_priority,
        pec.fetch_priority,
        pec.merge_priority,
        pec.quality_rating,
        pec.availability_scope,
        pec.free_plan_supported,
        pec.paid_plan_supported,
        pec.is_primary_source,
        pec.is_fallback_source,
        pec.source_endpoint,
        pec.target_table,
        pec.worker_script,
        pec.notes,
        pec.limitations,
        pec.next_action
    FROM ops.provider_entity_coverage pec
),
planner AS (
    SELECT
        ip.provider,
        ip.sport_code,
        ip.entity,
        ip.run_group,
        COUNT(*) FILTER (WHERE ip.status = 'pending') AS pending_cnt,
        COUNT(*) FILTER (WHERE ip.status = 'running') AS running_cnt,
        COUNT(*) FILTER (WHERE ip.status = 'done') AS done_cnt,
        COUNT(*) FILTER (WHERE ip.status = 'error') AS error_cnt,
        MAX(ip.updated_at) AS planner_last_update
    FROM ops.ingest_planner ip
    GROUP BY ip.provider, ip.sport_code, ip.entity, ip.run_group
),
accounts AS (
    SELECT
        pa.provider,
        COUNT(*) FILTER (WHERE pa.is_active = TRUE) AS active_accounts,
        MAX(pa.plan_code) AS max_plan_code
    FROM ops.provider_accounts pa
    GROUP BY pa.provider
),
matrix AS (
    SELECT
        psm.provider,
        psm.sport_code,
        psm.is_enabled AS provider_sport_enabled,
        psm.supports_leagues,
        psm.supports_teams,
        psm.supports_fixtures,
        psm.supports_players,
        psm.supports_player_stats,
        psm.supports_odds,
        psm.supports_coaches,
        psm.supports_standings
    FROM ops.provider_sport_matrix psm
),
locks AS (
    SELECT COUNT(*) AS active_worker_locks
    FROM ops.worker_locks
)
SELECT
    ep.provider,
    ep.sport_code,
    s.name AS sport_name,
    ep.entity,
    COALESCE(ep.default_run_group, t.run_group) AS run_group,

    ep.enabled AS entity_plan_enabled,
    COALESCE(c.is_enabled, FALSE) AS coverage_enabled,
    COALESCE(t.targets_enabled, 0) AS targets_enabled,
    COALESCE(t.targets_total, 0) AS targets_total,

    COALESCE(c.coverage_status, 'planned') AS coverage_status,
    COALESCE(c.provider_priority, 999) AS provider_priority,
    COALESCE(c.fetch_priority, 999) AS fetch_priority,
    COALESCE(c.merge_priority, 999) AS merge_priority,
    COALESCE(c.quality_rating, 'unknown') AS quality_rating,
    COALESCE(c.availability_scope, 'unknown') AS availability_scope,
    COALESCE(c.free_plan_supported, FALSE) AS free_plan_supported,
    COALESCE(c.paid_plan_supported, FALSE) AS paid_plan_supported,
    COALESCE(c.is_primary_source, FALSE) AS is_primary_source,
    COALESCE(c.is_fallback_source, FALSE) AS is_fallback_source,

    COALESCE(p.pending_cnt, 0) AS pending_cnt,
    COALESCE(p.running_cnt, 0) AS running_cnt,
    COALESCE(p.done_cnt, 0) AS done_cnt,
    COALESCE(p.error_cnt, 0) AS error_cnt,
    p.planner_last_update,

    COALESCE(a.active_accounts, 0) AS active_accounts,
    a.max_plan_code,

    COALESCE(m.provider_sport_enabled, FALSE) AS provider_sport_enabled,
    COALESCE(m.supports_leagues, FALSE) AS supports_leagues,
    COALESCE(m.supports_teams, FALSE) AS supports_teams,
    COALESCE(m.supports_fixtures, FALSE) AS supports_fixtures,
    COALESCE(m.supports_players, FALSE) AS supports_players,
    COALESCE(m.supports_player_stats, FALSE) AS supports_player_stats,
    COALESCE(m.supports_odds, FALSE) AS supports_odds,
    COALESCE(m.supports_coaches, FALSE) AS supports_coaches,
    COALESCE(m.supports_standings, FALSE) AS supports_standings,

    ep.ingest_mode,
    ep.scope_type,
    ep.requires_league,
    ep.requires_season,
    COALESCE(ep.worker_script, c.worker_script) AS worker_script,
    COALESCE(ep.source_endpoint, c.source_endpoint) AS source_endpoint,
    COALESCE(ep.target_table, c.target_table) AS target_table,
    c.notes,
    c.limitations,
    c.next_action,

    CASE
        WHEN ep.enabled = FALSE THEN 'SKIP_ENTITY_DISABLED'
        WHEN COALESCE(c.is_enabled, FALSE) = FALSE THEN 'SKIP_COVERAGE_DISABLED'
        WHEN COALESCE(m.provider_sport_enabled, FALSE) = FALSE THEN 'SKIP_PROVIDER_SPORT_DISABLED'
        WHEN COALESCE(a.active_accounts, 0) = 0 THEN 'SKIP_NO_ACTIVE_ACCOUNT'
        WHEN COALESCE(t.targets_enabled, 0) = 0 AND ep.scope_type <> 'global' THEN 'SKIP_NO_TARGETS'
        WHEN COALESCE(c.coverage_status, 'planned') IN ('blocked', 'deprecated') THEN 'SKIP_BLOCKED'
        WHEN COALESCE(p.running_cnt, 0) > 0 THEN 'RUNNING'
        WHEN COALESCE(p.error_cnt, 0) > 0 THEN 'REVIEW_ERROR'
        WHEN COALESCE(c.coverage_status, 'planned') IN ('runtime_tested', 'production_ready')
             AND ep.enabled = TRUE
             AND COALESCE(c.is_enabled, FALSE) = TRUE
             AND COALESCE(m.provider_sport_enabled, FALSE) = TRUE
             AND COALESCE(a.active_accounts, 0) > 0
             AND (COALESCE(t.targets_enabled, 0) > 0 OR ep.scope_type = 'global')
        THEN 'READY_AUTOMAT'
        WHEN COALESCE(c.coverage_status, 'planned') = 'tech_ready' THEN 'READY_VALIDATE'
        ELSE 'HOLD'
    END AS harvest_status,

    (
        COALESCE(c.provider_priority, 999) * 100000
      + COALESCE(c.fetch_priority, 999) * 1000
      + COALESCE(ep.priority, 999)
    ) AS harvest_rank,

    (SELECT active_worker_locks FROM locks) AS active_worker_locks

FROM entity_plan ep
LEFT JOIN coverage c
  ON c.provider = ep.provider
 AND c.sport_code = ep.sport_code
 AND c.entity = ep.entity
LEFT JOIN targets t
  ON t.provider = ep.provider
 AND t.sport_code = ep.sport_code
 AND t.run_group = ep.default_run_group
LEFT JOIN planner p
  ON p.provider = ep.provider
 AND p.sport_code = ep.sport_code
 AND p.entity = ep.entity
 AND p.run_group = COALESCE(ep.default_run_group, t.run_group)
LEFT JOIN accounts a
  ON a.provider = ep.provider
LEFT JOIN matrix m
  ON m.provider = ep.provider
 AND m.sport_code = ep.sport_code
LEFT JOIN public.sports s
  ON s.code = ep.sport_code
ORDER BY
    harvest_rank,
    ep.provider,
    ep.sport_code,
    ep.entity;