/*
===============================================================================
MATCHMATRIX
23_3_Q_CREATE_MASS_HARVEST_IMPLEMENTATION_READINESS_V1.SQL
===============================================================================

OBLAST:
23_PANEL MATCHMATRIX OPERAČNÍ CENTRUM

SEKCE:
23.3 HARVEST MANAGEMENT

NÁZEV:
Mass Harvest Implementation Readiness

VERZE:
V1

===============================================================================
CO TO JE
===============================================================================

Hlavní implementační readiness vrstva pro řízení připravenosti všech sportů,
entit, providerů, workerů a pipeline před spuštěním hromadného historického
harvestu MatchMatrix.

Navazuje na:

• Provider Readiness Matrix
• Harvest Master Plan
• Execution Plans
• Go-Live Checklist

===============================================================================
K ČEMU TO JE
===============================================================================

Poskytuje jednotný pohled na připravenost jednotlivých sportů a entit
pro spuštění hromadného harvestu.

Vyhodnocuje připravenost:

• CORE
• PEOPLE
• MEDIA
• ODDS
• SOURCE

a propojuje informace z Runtime Queue,
Development Queue a Harvest Readiness.

===============================================================================
KDE SE POUŽÍVÁ
===============================================================================

OPS Panel

Harvest Dashboard

Mass Harvest Dashboard

Autonomous Scheduler

Go-Live Decision

===============================================================================
CO KONTROLUJE
===============================================================================

✓ Provider

✓ Worker

✓ Runtime

✓ Planner

✓ Staging

✓ Public

✓ Parser

✓ Merge

✓ Mapping

✓ Scheduler

✓ OPS evidence

✓ Development readiness

✓ Production readiness

===============================================================================
VÝSTUP
===============================================================================

Jednotný pohled:

ops.v_mass_harvest_implementation_readiness_v1

který slouží jako hlavní rozhodovací vrstva před spuštěním historického
harvestu všech sportů a všech entit.

===============================================================================
AUTOR
===============================================================================

MatchMatrix Platform
Petr Kubínák
OpenAI ChatGPT

===============================================================================
DATUM
===============================================================================

2026

===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_implementation_readiness_v3
AS

SELECT
    q.sport_code,
    q.sport_name,
    q.entity,
    q.candidate_provider,
    q.run_group,
    q.resolved_worker_script,
    q.runtime_execution_state,
    q.provider_route_state,
    q.provider_gap,
    q.runtime_state,
    q.production_readiness,
    q.execution_priority_score,

    CASE
        WHEN q.entity = ANY (ARRAY['fixtures', 'teams', 'leagues'])
             AND q.resolved_worker_script = 'workers/run_ingest_cycle_v3.py'
            THEN 'IMPLEMENTED_CORE'

        WHEN q.entity = ANY (ARRAY['players', 'coaches', 'player_stats'])
             AND q.resolved_worker_script = 'workers/run_people_pipeline_v22_from_planner.py'
            THEN 'IMPLEMENTED'

        WHEN q.entity = 'player_season_stats'
            THEN 'TEST_READY'

        WHEN q.entity = ANY (ARRAY['media', 'articles', 'news', 'highlights'])
             AND q.resolved_worker_script = 'workers/run_media_pipeline_v1.py'
            THEN 'PARTIAL'

        WHEN q.entity = 'odds'
            THEN 'NOT_IMPLEMENTED'

        ELSE 'REVIEW_REQUIRED'
    END AS implementation_state,

    CASE
        WHEN q.entity = ANY (ARRAY['fixtures', 'teams', 'leagues'])
            THEN 'Core ingest orchestration je production-ready.'

        WHEN q.entity = ANY (ARRAY['players', 'coaches', 'player_stats'])
            THEN 'People pipeline je napojená přes planner orchestration.'

        WHEN q.entity = 'player_season_stats'
            THEN 'Season stats staging/public/normalizace existují; připravit mass harvest worker a finální readiness.'

        WHEN q.entity = ANY (ARRAY['media', 'articles', 'news', 'highlights'])
            THEN 'Media ingest + parser + merge existuje; rozšířit scheduler intelligence a source-specific extractory.'

        WHEN q.entity = 'odds'
            THEN 'Doplnit odds ingest orchestration, parsery a public.odds merge.'

        ELSE 'Vyžaduje ruční kontrolu.'
    END AS implementation_note,

    q.last_run_at,
    q.next_action,
    'EXECUTION_QUEUE'::text AS readiness_source

FROM ops.v_execution_priority_queue_v1 q

UNION ALL

SELECT
    d.sport_code,
    d.sport_code AS sport_name,
    d.entity,
    NULL::text AS candidate_provider,
    NULL::text AS run_group,
    NULL::text AS resolved_worker_script,
    NULL::text AS runtime_execution_state,
    d.action_code AS provider_route_state,
    NULL::text AS provider_gap,
    d.task_status AS runtime_state,
    NULL::text AS production_readiness,
    d.priority_score AS execution_priority_score,

    CASE
        WHEN d.entity = 'player_season_stats'
            THEN 'TEST_READY'

        WHEN d.action_code = 'PAID_PLAN_REQUIRED'
            THEN 'PAID_PLAN_REQUIRED'

        WHEN d.action_code = 'IMPLEMENTATION_REQUIRED'
            THEN 'IMPLEMENTATION_REQUIRED'

        ELSE 'REVIEW_REQUIRED'
    END AS implementation_state,

    d.task_description AS implementation_note,
    d.created_at AS last_run_at,
    d.task_title AS next_action,
    'DEVELOPMENT_QUEUE'::text AS readiness_source

FROM ops.v_development_task_queue_v1 d
WHERE NOT EXISTS
(
    SELECT 1
    FROM ops.v_execution_priority_queue_v1 q
    WHERE q.sport_code = d.sport_code
      AND q.entity = d.entity
);

COMMENT ON VIEW ops.v_implementation_readiness_v3 IS
'Implementation Readiness V3 - rozšířený readiness pohled pro Mass Harvest přípravu; kombinuje execution priority queue a development task queue.';