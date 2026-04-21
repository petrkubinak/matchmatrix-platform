-- 712_audit_hb_runtime_reality.sql
-- Účel:
-- Ověřit reálný HB stav v OPS podle skutečné struktury tabulek.

-- =========================================================
-- A) provider_sport_matrix
-- =========================================================
select
    'provider_sport_matrix' as source_table,
    psm.id,
    psm.provider,
    psm.sport_code,
    psm.sport_name,
    psm.is_enabled,
    psm.supports_leagues,
    psm.supports_teams,
    psm.supports_fixtures,
    psm.supports_players,
    psm.supports_player_stats,
    psm.supports_odds,
    psm.supports_coaches,
    psm.supports_standings,
    psm.notes
from ops.provider_sport_matrix psm
where upper(psm.sport_code) = 'HB'
order by psm.provider;

-- =========================================================
-- B) provider_entity_coverage
-- =========================================================
select
    'provider_entity_coverage' as source_table,
    pec.id,
    pec.provider,
    pec.sport_code,
    pec.entity,
    pec.coverage_status,
    pec.is_enabled,
    pec.provider_priority,
    pec.merge_priority,
    pec.fetch_priority,
    pec.is_primary_source,
    pec.is_fallback_source,
    pec.is_merge_source,
    pec.target_table,
    pec.worker_script,
    pec.next_action,
    pec.notes
from ops.provider_entity_coverage pec
where upper(pec.sport_code) = 'HB'
order by pec.provider, pec.entity;

-- =========================================================
-- C) ingest_entity_plan
-- =========================================================
select
    'ingest_entity_plan' as source_table,
    iep.id,
    iep.provider,
    iep.sport_code,
    iep.entity,
    iep.enabled,
    iep.priority,
    iep.scope_type,
    iep.requires_league,
    iep.requires_season,
    iep.default_run_group,
    iep.ingest_mode,
    iep.target_table,
    iep.worker_script,
    iep.notes
from ops.ingest_entity_plan iep
where upper(iep.sport_code) = 'HB'
order by iep.provider, iep.entity;

-- =========================================================
-- D) ingest_targets
-- =========================================================
select
    'ingest_targets' as source_table,
    it.id,
    it.provider,
    it.sport_code,
    it.canonical_league_id,
    it.provider_league_id,
    it.season,
    it.enabled,
    it.tier,
    it.run_group,
    it.max_requests_per_run,
    it.notes,
    it.updated_at
from ops.ingest_targets it
where upper(it.sport_code) = 'HB'
order by it.provider, it.provider_league_id nulls last, it.season desc nulls last;

-- =========================================================
-- E) runtime_entity_audit
-- =========================================================
select
    'runtime_entity_audit' as source_table,
    rea.id,
    rea.provider,
    rea.sport_code,
    rea.entity,
    rea.current_state,
    rea.state_reason,
    rea.panel_runner_exists,
    rea.planner_target_exists,
    rea.batch_target_exists,
    rea.pull_confirmed,
    rea.raw_confirmed,
    rea.staging_confirmed,
    rea.provider_map_confirmed,
    rea.public_merge_confirmed,
    rea.downstream_confirmed,
    rea.last_run_group,
    rea.last_run_at,
    rea.db_evidence_summary,
    rea.next_action,
    rea.audit_note
from ops.runtime_entity_audit rea
where upper(rea.sport_code) = 'HB'
order by rea.provider, rea.entity;

-- =========================================================
-- F) sport_completion_audit
-- Bez znalosti přesné struktury jen existence řádků přes to_jsonb
-- =========================================================
select
    'sport_completion_audit' as source_table,
    to_jsonb(sca) as row_data
from ops.sport_completion_audit sca
where upper(sca.sport_code) = 'HB';

-- =========================================================
-- G) Souhrn counts
-- =========================================================
select 'provider_sport_matrix' as check_name, count(*) as row_count
from ops.provider_sport_matrix
where upper(sport_code) = 'HB'

union all
select 'provider_entity_coverage', count(*)
from ops.provider_entity_coverage
where upper(sport_code) = 'HB'

union all
select 'ingest_entity_plan', count(*)
from ops.ingest_entity_plan
where upper(sport_code) = 'HB'

union all
select 'ingest_targets', count(*)
from ops.ingest_targets
where upper(sport_code) = 'HB'

union all
select 'runtime_entity_audit', count(*)
from ops.runtime_entity_audit
where upper(sport_code) = 'HB'

union all
select 'sport_completion_audit', count(*)
from ops.sport_completion_audit
where upper(sport_code) = 'HB';