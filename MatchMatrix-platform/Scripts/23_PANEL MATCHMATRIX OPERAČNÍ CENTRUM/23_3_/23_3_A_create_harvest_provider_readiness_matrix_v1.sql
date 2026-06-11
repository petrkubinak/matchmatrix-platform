/*
MATCHMATRIX SQL 23_3_A
HARVEST PROVIDER READINESS MATRIX V1

CO TO JE:
- Centrální přehled providerů pro velké stahování dat na PC2.

K ČEMU TO JE:
- Ukáže, odkud můžeme stahovat data.
- Ukáže, pro jaký sport a vrstvu je provider připravený.
- Ukáže, zda máme worker.
- Ukáže, zda provider podporuje FREE / PAID režim.
- Rozliší READY / PARTIAL / PAID_READY / NEEDS_RESEARCH.

KDE TO UVIDÍME:
- MatchMatrix Operační Centrum
- HARVEST PŘIPRAVENOST PRO PC2
- Provider Intelligence
- Sport Completion

JAK SE TO VYUŽIJE:
- Příprava velkého historického harvestu.
- Rozhodnutí, co pustit na novém PC.
- Výběr primárního a fallback providera.
- Zjištění, kde chybí worker nebo provider.
*/

DROP VIEW IF EXISTS ops.v_harvest_provider_readiness_matrix_v1;

CREATE OR REPLACE VIEW ops.v_harvest_provider_readiness_matrix_v1 AS

WITH provider_base AS (
    SELECT
        p.provider,
        p.sport_code,
        p.entity,
        p.coverage_status,
        p.is_enabled,
        p.provider_priority,
        p.merge_priority,
        p.fetch_priority,
        p.quality_rating,
        p.availability_scope,
        p.free_plan_supported,
        p.paid_plan_supported,
        p.expected_depth,
        p.is_primary_source,
        p.is_fallback_source,
        p.is_merge_source,
        p.source_endpoint,
        p.target_table,
        p.worker_script AS provider_declared_worker,
        p.notes,
        p.limitations,
        p.next_action,
        p.priority
    FROM ops.provider_entity_coverage p
),

worker_base AS (
    SELECT
        provider,
        sport_code,
        entity,
        string_agg(DISTINCT worker_type, ', ' ORDER BY worker_type) AS worker_types,
        string_agg(DISTINCT worker_script, ', ' ORDER BY worker_script) AS registered_workers,
        bool_or(is_supported) AS has_supported_worker,
        bool_or(is_active) AS has_active_worker
    FROM ops.provider_worker_registry
    GROUP BY
        provider,
        sport_code,
        entity
),

joined AS (
    SELECT
        p.provider,
        p.sport_code,
        p.entity,

        CASE
            WHEN lower(p.entity) IN ('fixtures','teams','leagues','standings','events','team_stats')
                THEN 'CORE'
            WHEN lower(p.entity) IN ('players','people','player_profiles','player_stats','player_season_stats','coaches')
                THEN 'PEOPLE'
            WHEN lower(p.entity) IN ('odds','bookmakers','markets')
                THEN 'ODDS'
            WHEN lower(p.entity) IN ('media','articles','videos','highlights','comments')
                THEN 'MEDIA'
            ELSE 'OTHER'
        END AS harvest_layer,

        p.coverage_status,
        p.is_enabled,
        p.provider_priority,
        p.merge_priority,
        p.fetch_priority,
        p.quality_rating,
        p.availability_scope,
        p.free_plan_supported,
        p.paid_plan_supported,
        p.expected_depth,
        p.is_primary_source,
        p.is_fallback_source,
        p.is_merge_source,
        p.source_endpoint,
        p.target_table,
        p.provider_declared_worker,
        w.worker_types,
        w.registered_workers,
        COALESCE(w.has_supported_worker, false) AS has_supported_worker,
        COALESCE(w.has_active_worker, false) AS has_active_worker,
        p.notes,
        p.limitations,
        p.next_action,
        p.priority
    FROM provider_base p
    LEFT JOIN worker_base w
        ON w.provider = p.provider
       AND w.sport_code = p.sport_code
       AND lower(w.entity) = lower(p.entity)
)

SELECT
    provider,
    sport_code,
    entity,
    harvest_layer,

    coverage_status,
    quality_rating,
    availability_scope,
    expected_depth,

    free_plan_supported,
    paid_plan_supported,

    is_primary_source,
    is_fallback_source,
    is_merge_source,

    source_endpoint,
    target_table,

    provider_declared_worker,
    registered_workers,
    worker_types,
    has_supported_worker,
    has_active_worker,

    CASE
        WHEN is_enabled = false
            THEN 'DISABLED'

        WHEN lower(coverage_status) IN ('blocked','error','failed')
            THEN 'BLOCKED'

        WHEN has_active_worker = true
         AND lower(coverage_status) IN ('confirmed','ready','implemented','active','tech_ready','runtime_tested')
            THEN 'READY'

        WHEN has_active_worker = true
         AND paid_plan_supported = true
         AND free_plan_supported = false
            THEN 'PAID_READY'

        WHEN free_plan_supported = true
         AND has_active_worker = false
            THEN 'NEEDS_WORKER_OR_TEST'

        WHEN paid_plan_supported = true
         AND free_plan_supported = false
            THEN 'WAIT_FOR_PAID_OR_TEST'

        WHEN lower(coverage_status) IN ('planned','partial','tech_ready','runtime_tested')
            THEN 'PARTIAL'

        ELSE 'NEEDS_RESEARCH'
    END AS harvest_readiness_status,

    CASE
        WHEN is_enabled = false
            THEN 'Provider je vypnutý.'

        WHEN lower(coverage_status) IN ('blocked','error','failed')
            THEN 'Nejdříve vyřešit blokaci nebo health providera.'

        WHEN has_active_worker = true
         AND lower(coverage_status) IN ('confirmed','ready','implemented','active','tech_ready','runtime_tested')
            THEN 'Lze zařadit do PC2 harvest plánu.'

        WHEN has_active_worker = true
         AND paid_plan_supported = true
         AND free_plan_supported = false
            THEN 'Worker existuje, čeká na placený plán nebo API klíč.'

        WHEN free_plan_supported = true
         AND has_active_worker = false
            THEN 'Otestovat FREE endpoint a doplnit worker do registry.'

        WHEN paid_plan_supported = true
         AND free_plan_supported = false
            THEN 'Připravit smoke test pro placený režim.'

        WHEN lower(coverage_status) IN ('planned','partial','tech_ready','runtime_tested')
            THEN 'Doplnit test, worker nebo merge napojení.'

        ELSE 'Provést provider research.'
    END AS recommended_next_step,

    CASE
        WHEN harvest_layer = 'CORE' THEN 100
        WHEN harvest_layer = 'PEOPLE' THEN 90
        WHEN harvest_layer = 'ODDS' THEN 80
        WHEN harvest_layer = 'MEDIA' THEN 70
        ELSE 50
    END
    + CASE WHEN is_primary_source THEN 20 ELSE 0 END
    + CASE WHEN is_fallback_source THEN 10 ELSE 0 END
    + CASE WHEN has_active_worker THEN 25 ELSE 0 END
    + CASE WHEN free_plan_supported THEN 15 ELSE 0 END
    + CASE WHEN paid_plan_supported THEN 10 ELSE 0 END
    - CASE WHEN lower(coverage_status) IN ('blocked','error','failed') THEN 80 ELSE 0 END
    - LEAST(COALESCE(fetch_priority, 100), 100) / 10
    AS harvest_priority_score,

    notes,
    limitations,
    next_action,
    now() AS refreshed_at

FROM joined
ORDER BY
    harvest_priority_score DESC,
    sport_code,
    harvest_layer,
    provider;