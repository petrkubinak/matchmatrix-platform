/*
MATCHMATRIX SQL 23_1_C

PROVIDER RECOMMENDATION ENGINE V1

CO TO JE:
- Doporučovací engine providerů pro MatchMatrix Operační Centrum.

K ČEMU TO JE:
- Nejdříve doporučí vhodné providery.
- Až potom budeme navrhovat worker.
- Podporuje multi-provider strategii: primary / fallback / custom / paid.

KDE TO UVIDÍME:
- V19 Panel
- Provider Intelligence
- Sport Completion
- People / Media / Odds záložky

JAK SE TO VYUŽIJE:
- Panel ukáže, odkud data získat.
- Panel rozliší FREE / PAID / CUSTOM SCRAPER.
- Panel doporučí další akci: otestovat, zapsat, najít alternativu, čekat na PRO.
*/

DROP VIEW IF EXISTS ops.v_provider_recommendation_engine_v1;

CREATE OR REPLACE VIEW ops.v_provider_recommendation_engine_v1 AS

WITH gaps AS (
    SELECT
        recommendation_rank,
        sport_code,
        sport_name,
        weakest_layer,
        problem_description,
        recommended_action,
        estimated_project_gain,
        priority_level,
        total_pct,
        sport_readiness
    FROM ops.v_panel_action_recommendations_v1
),

provider_candidates AS (

    SELECT
        g.recommendation_rank,
        g.sport_code,
        g.sport_name,
        g.weakest_layer,
        g.problem_description,
        g.estimated_project_gain,
        g.priority_level,
        g.total_pct,
        g.sport_readiness,

        COALESCE(p.provider, 'UNKNOWN') AS provider,
        COALESCE(p.entity, lower(g.weakest_layer)) AS entity,

        COALESCE(p.coverage_status, 'not_registered') AS coverage_status,
        COALESCE(p.quality_rating, 'unknown') AS quality_rating,
        COALESCE(p.availability_scope, 'unknown') AS availability_scope,
        COALESCE(p.free_plan_supported, false) AS free_plan_supported,
        COALESCE(p.paid_plan_supported, false) AS paid_plan_supported,
        COALESCE(p.expected_depth, 'unknown') AS expected_depth,
        COALESCE(p.is_primary_source, false) AS is_primary_source,
        COALESCE(p.is_fallback_source, false) AS is_fallback_source,
        COALESCE(p.provider_priority, 999) AS provider_priority,
        COALESCE(p.merge_priority, 999) AS merge_priority,
        COALESCE(p.fetch_priority, 999) AS fetch_priority,
        p.source_endpoint,
        p.target_table,
        p.worker_script,
        p.next_action,
        p.limitations,
        p.notes

    FROM gaps g
    LEFT JOIN ops.provider_entity_coverage p
        ON p.sport_code = g.sport_code
       AND (
            lower(p.entity) = lower(g.weakest_layer)
            OR (
                g.weakest_layer = 'PEOPLE'
                AND lower(p.entity) IN ('players','people','player_profiles','player_stats','coaches')
            )
            OR (
                g.weakest_layer = 'MEDIA'
                AND lower(p.entity) IN ('media','articles','videos','highlights')
            )
            OR (
                g.weakest_layer = 'ODDS'
                AND lower(p.entity) IN ('odds','bookmakers','markets')
            )
            OR (
                g.weakest_layer = 'CORE'
                AND lower(p.entity) IN ('fixtures','teams','leagues','standings')
            )
       )
),

scored AS (

    SELECT
        *,

        (
            CASE WHEN is_primary_source THEN 30 ELSE 0 END
            + CASE WHEN is_fallback_source THEN 15 ELSE 0 END
            + CASE WHEN free_plan_supported THEN 20 ELSE 0 END
            + CASE WHEN paid_plan_supported THEN 10 ELSE 0 END
            + CASE
                WHEN lower(quality_rating) IN ('high','excellent','confirmed') THEN 25
                WHEN lower(quality_rating) IN ('medium','good') THEN 15
                WHEN lower(quality_rating) IN ('low','limited') THEN 5
                ELSE 0
              END
            + CASE
                WHEN lower(coverage_status) IN ('confirmed','ready','implemented','active') THEN 25
                WHEN lower(coverage_status) IN ('partial','planned') THEN 10
                ELSE 0
              END
            + GREATEST(0, 20 - LEAST(provider_priority, 20))
        ) AS provider_score

    FROM provider_candidates
),

fallback_needed AS (

    SELECT
        g.recommendation_rank,
        g.sport_code,
        g.sport_name,
        g.weakest_layer,
        g.problem_description,
        g.estimated_project_gain,
        g.priority_level,
        g.total_pct,
        g.sport_readiness,

        'PROVIDER_NOT_FOUND'::text AS provider,
        lower(g.weakest_layer)::text AS entity,
        'missing'::text AS coverage_status,
        'unknown'::text AS quality_rating,
        'research_required'::text AS availability_scope,
        false AS free_plan_supported,
        false AS paid_plan_supported,
        'unknown'::text AS expected_depth,
        false AS is_primary_source,
        false AS is_fallback_source,
        999 AS provider_priority,
        999 AS merge_priority,
        999 AS fetch_priority,
        NULL::text AS source_endpoint,
        NULL::text AS target_table,
        NULL::text AS worker_script,
        'Najít vhodného providera pro tuto vrstvu a sport.'::text AS next_action,
        'Provider zatím není registrovaný.'::text AS limitations,
        'Nejdřív research providera, potom smoke test, potom worker.'::text AS notes,
        0 AS provider_score

    FROM gaps g
    WHERE NOT EXISTS (
        SELECT 1
        FROM ops.provider_entity_coverage p
        WHERE p.sport_code = g.sport_code
          AND (
                lower(p.entity) = lower(g.weakest_layer)
                OR (
                    g.weakest_layer = 'PEOPLE'
                    AND lower(p.entity) IN ('players','people','player_profiles','player_stats','coaches')
                )
                OR (
                    g.weakest_layer = 'MEDIA'
                    AND lower(p.entity) IN ('media','articles','videos','highlights')
                )
                OR (
                    g.weakest_layer = 'ODDS'
                    AND lower(p.entity) IN ('odds','bookmakers','markets')
                )
                OR (
                    g.weakest_layer = 'CORE'
                    AND lower(p.entity) IN ('fixtures','teams','leagues','standings')
                )
          )
    )
),

unioned AS (
    SELECT * FROM scored
    WHERE provider <> 'UNKNOWN'

    UNION ALL

    SELECT * FROM fallback_needed
),

ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY sport_code, weakest_layer
            ORDER BY
                provider_score DESC,
                free_plan_supported DESC,
                paid_plan_supported DESC,
                provider_priority ASC,
                provider
        ) AS provider_rank
    FROM unioned
)

SELECT
    recommendation_rank,
    provider_rank,

    sport_code,
    sport_name,
    weakest_layer,

    problem_description,

    provider,
    entity,

    coverage_status,
    quality_rating,
    availability_scope,
    free_plan_supported,
    paid_plan_supported,
    expected_depth,
    is_primary_source,
    is_fallback_source,

    provider_score,

    CASE
        WHEN provider = 'PROVIDER_NOT_FOUND'
            THEN 'NAJÍT PROVIDERA'
        WHEN coverage_status IN ('confirmed','ready','implemented','active')
             AND COALESCE(worker_script, '') <> ''
            THEN 'LZE PŘIPRAVIT WORKER / OVĚŘIT RUN'
        WHEN coverage_status IN ('confirmed','ready','implemented','active')
            THEN 'OVĚŘIT ENDPOINT A DOPLNIT WORKER'
        WHEN free_plan_supported = true
            THEN 'OTESTOVAT FREE ENDPOINT'
        WHEN paid_plan_supported = true
            THEN 'ČEKÁ NA PRO / PAID TEST'
        ELSE 'PROVÉST PROVIDER RESEARCH'
    END AS recommended_provider_action,

    CASE
        WHEN provider = 'PROVIDER_NOT_FOUND'
            THEN 'MANUAL_RESEARCH'
        WHEN coverage_status IN ('confirmed','ready','implemented','active')
             AND COALESCE(worker_script, '') <> ''
            THEN 'READY_FOR_WORKER_REVIEW'
        WHEN free_plan_supported = true
            THEN 'READY_FOR_SMOKE_TEST'
        WHEN paid_plan_supported = true
            THEN 'WAIT_FOR_PAID_PLAN'
        ELSE 'RESEARCH_REQUIRED'
    END AS provider_action_status,

    estimated_project_gain,
    priority_level,
    total_pct,
    sport_readiness,

    source_endpoint,
    target_table,
    worker_script,
    next_action,
    limitations,
    notes,

    now() AS refreshed_at

FROM ranked
WHERE provider_rank <= 5
ORDER BY
    recommendation_rank,
    provider_rank;