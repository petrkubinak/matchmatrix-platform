/*
MATCHMATRIX SQL 106_D
Soubor:
C:\MatchMatrix-platform\sql\106_D_audit_provider_routing_candidates_v1.sql

Co to je:
Audit provider routing candidates pro MatchMatrix orchestration layer.

K čemu to je:
Ukáže pro každý sport + entity:
- primary provider
- fallback provider
- blocked provider stav
- provider gap
- endpoint
- worker script
- runtime stav
- next action

Kam výsledek vede:
Výstup je SELECT audit report.
Později z něj můžeme vytvořit view pro Control Panel V16+.

Kde to uvidíme v aplikaci:
V budoucím panelu jako:
- Provider Routing
- Failover Candidates
- Automation Readiness
- Provider Gaps
- Next Action Queue

Jak se to použije na webu / platformě:
Tento audit nebude přímo pro koncového uživatele.
Je to OPS vrstva pro automatické rozhodování:
- odkud stáhnout data
- kdy použít fallback
- co je blokované
- co je připravené pro scheduler
*/

WITH coverage AS (
    SELECT
        pec.provider,
        pec.sport_code,
        pec.entity,
        pec.coverage_status,
        pec.is_enabled,
        pec.provider_priority,
        pec.merge_priority,
        pec.fetch_priority,
        pec.quality_rating,
        pec.availability_scope,
        pec.free_plan_supported,
        pec.paid_plan_supported,
        pec.expected_depth,
        pec.is_primary_source,
        pec.is_fallback_source,
        pec.source_endpoint,
        pec.target_table,
        pec.worker_script,
        pec.limitations,
        pec.next_action
    FROM ops.provider_entity_coverage pec
),

runtime AS (
    SELECT
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
        rea.next_action AS runtime_next_action
    FROM ops.runtime_entity_audit rea
),

sport_completion AS (
    SELECT
        sca.sport_code,
        sca.entity,
        sca.layer_type,
        sca.current_status,
        sca.production_readiness,
        sca.provider_primary,
        sca.provider_fallback,
        sca.db_layer_ready,
        sca.planner_ready,
        sca.queue_ready,
        sca.public_ready,
        sca.key_gap,
        sca.next_step,
        sca.evidence_note,
        sca.priority_rank
    FROM ops.sport_completion_audit sca
),

people AS (
    SELECT
        ppa.provider,
        ppa.sport_code,
        ppa.entity,
        ppa.endpoint_exists,
        ppa.endpoint_tested,
        ppa.endpoint_returns_data,
        ppa.usable_for_league,
        ppa.usable_for_team,
        ppa.usable_for_season,
        ppa.technical_status,
        ppa.data_quality_status,
        ppa.final_verdict,
        ppa.requires_pro,
        ppa.alternative_provider_needed,
        ppa.evidence_note AS people_evidence_note,
        ppa.next_step AS people_next_step,
        ppa.priority_rank AS people_priority_rank
    FROM ops.provider_people_audit ppa
),

matrix AS (
    SELECT
        psm.provider,
        psm.sport_code,
        psm.sport_name,
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

ranked AS (
    SELECT
        c.*,

        ROW_NUMBER() OVER (
            PARTITION BY c.sport_code, c.entity
            ORDER BY
                CASE WHEN c.is_primary_source THEN 0 ELSE 1 END,
                c.provider_priority ASC,
                c.fetch_priority ASC,
                c.merge_priority ASC,
                c.provider ASC
        ) AS provider_rank,

        MIN(
            CASE WHEN c.is_primary_source THEN c.provider END
        ) OVER (
            PARTITION BY c.sport_code, c.entity
        ) AS declared_primary_provider,

        MIN(
            CASE WHEN c.is_fallback_source THEN c.provider END
        ) OVER (
            PARTITION BY c.sport_code, c.entity
        ) AS declared_fallback_provider

    FROM coverage c
),

audit AS (
    SELECT
        r.sport_code,
        COALESCE(m.sport_name, r.sport_code) AS sport_name,
        r.entity,

        COALESCE(
            r.declared_primary_provider,
            sc.provider_primary,
            CASE WHEN r.provider_rank = 1 THEN r.provider END
        ) AS primary_provider,

        COALESCE(
            r.declared_fallback_provider,
            sc.provider_fallback
        ) AS fallback_provider,

        r.provider AS candidate_provider,

        r.coverage_status,
        r.is_enabled AS coverage_enabled,
        r.provider_priority,
        r.fetch_priority,
        r.merge_priority,
        r.quality_rating,
        r.availability_scope,
        r.expected_depth,

        r.free_plan_supported,
        r.paid_plan_supported,

        r.is_primary_source,
        r.is_fallback_source,

        r.source_endpoint,
        r.target_table,
        r.worker_script,

        rt.current_state AS runtime_state,
        rt.state_reason AS runtime_reason,
        rt.panel_runner_exists,
        rt.planner_target_exists,
        rt.batch_target_exists,
        rt.pull_confirmed,
        rt.raw_confirmed,
        rt.staging_confirmed,
        rt.provider_map_confirmed,
        rt.public_merge_confirmed,
        rt.downstream_confirmed,
        rt.last_run_group,
        rt.last_run_at,
        rt.db_evidence_summary,

        sc.layer_type,
        sc.current_status AS sport_completion_status,
        sc.production_readiness,
        sc.db_layer_ready,
        sc.planner_ready,
        sc.queue_ready,
        sc.public_ready,
        sc.key_gap,
        sc.evidence_note,
        sc.priority_rank,

        p.endpoint_exists AS people_endpoint_exists,
        p.endpoint_tested AS people_endpoint_tested,
        p.endpoint_returns_data AS people_endpoint_returns_data,
        p.technical_status AS people_technical_status,
        p.data_quality_status AS people_data_quality_status,
        p.final_verdict AS people_final_verdict,
        p.requires_pro AS people_requires_pro,
        p.alternative_provider_needed AS people_alternative_provider_needed,

        m.provider_sport_enabled,
        m.supports_leagues,
        m.supports_teams,
        m.supports_fixtures,
        m.supports_players,
        m.supports_player_stats,
        m.supports_odds,
        m.supports_coaches,
        m.supports_standings,

        r.limitations,

        COALESCE(
            r.next_action,
            rt.runtime_next_action,
            sc.next_step,
            p.people_next_step
        ) AS next_action

    FROM ranked r

    LEFT JOIN runtime rt
        ON rt.provider = r.provider
       AND rt.sport_code = r.sport_code
       AND rt.entity = r.entity

    LEFT JOIN sport_completion sc
        ON sc.sport_code = r.sport_code
       AND sc.entity = r.entity

    LEFT JOIN people p
        ON p.provider = r.provider
       AND p.sport_code = r.sport_code
       AND p.entity = r.entity

    LEFT JOIN matrix m
        ON m.provider = r.provider
       AND m.sport_code = r.sport_code
)

SELECT
    sport_code,
    sport_name,
    entity,

    primary_provider,
    fallback_provider,
    candidate_provider,

    CASE
        WHEN coverage_enabled IS FALSE THEN 'BLOCKED_COVERAGE_DISABLED'
        WHEN provider_sport_enabled IS FALSE THEN 'BLOCKED_PROVIDER_SPORT_DISABLED'
        WHEN coverage_status ILIKE 'blocked%' THEN 'BLOCKED_PROVIDER'
        WHEN coverage_status ILIKE 'planned%' THEN 'PLANNED_PROVIDER'
        WHEN coverage_status ILIKE 'partial%' THEN 'PARTIAL_PROVIDER'
        WHEN coverage_status ILIKE 'confirmed%' THEN 'CONFIRMED_PROVIDER'
        WHEN coverage_status ILIKE 'runnable%' THEN 'RUNNABLE_PROVIDER'
        ELSE 'UNKNOWN_PROVIDER_STATE'
    END AS provider_route_state,

    CASE
        WHEN primary_provider IS NULL THEN 'GAP_NO_PRIMARY_PROVIDER'
        WHEN fallback_provider IS NULL THEN 'GAP_NO_FALLBACK_PROVIDER'
        WHEN source_endpoint IS NULL THEN 'GAP_NO_ENDPOINT'
        WHEN worker_script IS NULL THEN 'GAP_NO_WORKER'
        WHEN production_readiness IS NOT NULL
             AND production_readiness NOT ILIKE 'ready%'
             AND production_readiness NOT ILIKE 'confirmed%'
            THEN 'GAP_NOT_PRODUCTION_READY'
        WHEN coverage_status ILIKE 'blocked%' THEN 'GAP_PROVIDER_BLOCKED'
        WHEN coverage_status ILIKE 'planned%' THEN 'GAP_PROVIDER_PLANNED_ONLY'
        ELSE 'OK'
    END AS provider_gap,

    CASE
        WHEN coverage_status ILIKE 'confirmed%'
          OR coverage_status ILIKE 'runnable%'
          OR coverage_status ILIKE 'partial%'
        THEN TRUE
        ELSE FALSE
    END AS routing_candidate,

    coverage_status,
    runtime_state,
    sport_completion_status,
    production_readiness,

    free_plan_supported,
    paid_plan_supported,
    people_requires_pro,

    source_endpoint,
    target_table,
    worker_script,

    limitations,
    key_gap,
    runtime_reason,
    db_evidence_summary,
    next_action,

    last_run_group,
    last_run_at,

    provider_priority,
    fetch_priority,
    merge_priority,
    priority_rank

FROM audit
ORDER BY
    sport_code,
    entity,
    CASE
        WHEN candidate_provider = primary_provider THEN 0
        WHEN candidate_provider = fallback_provider THEN 1
        ELSE 2
    END,
    provider_priority,
    fetch_priority,
    candidate_provider;