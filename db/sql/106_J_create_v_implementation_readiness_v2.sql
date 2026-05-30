/*
MATCHMATRIX SQL 106_J V2

Co to je:
Implementation readiness + orchestration maturity view.

K čemu to je:
Rozlišuje:
- IMPLEMENTED
- IMPLEMENTED_CORE
- PARTIAL
- NOT_IMPLEMENTED
- REVIEW_REQUIRED

MEDIA už není považována za neimplementovanou,
protože:
- ingest existuje
- parser existuje
- merge existuje
- public articles existují
- scheduler worker existuje
*/

CREATE OR REPLACE VIEW ops.v_implementation_readiness_v2 AS

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

        /* CORE */
        WHEN q.entity IN (
            'fixtures',
            'teams',
            'leagues'
        )
        AND q.resolved_worker_script =
            'workers/run_ingest_cycle_v3.py'
        THEN 'IMPLEMENTED_CORE'

        /* PEOPLE */
        WHEN q.entity IN (
            'players',
            'coaches',
            'player_stats'
        )
        AND q.resolved_worker_script =
            'workers/run_people_pipeline_v22_from_planner.py'
        THEN 'IMPLEMENTED'

        /* MEDIA */
        WHEN q.entity IN (
            'media',
            'articles',
            'news',
            'highlights'
        )
        AND q.resolved_worker_script =
            'workers/run_media_pipeline_v1.py'
        THEN 'PARTIAL'

        /* ODDS */
        WHEN q.entity = 'odds'
        THEN 'NOT_IMPLEMENTED'

        ELSE 'REVIEW_REQUIRED'

    END AS implementation_state,

    CASE

        WHEN q.entity IN (
            'fixtures',
            'teams',
            'leagues'
        )
        THEN
            'Core ingest orchestration je production-ready.'

        WHEN q.entity IN (
            'players',
            'coaches',
            'player_stats'
        )
        THEN
            'People pipeline je napojená přes planner orchestration.'

        WHEN q.entity IN (
            'media',
            'articles',
            'news',
            'highlights'
        )
        THEN
            'Media ingest + parser + merge existuje; rozšířit scheduler intelligence a source-specific extractory.'

        WHEN q.entity = 'odds'
        THEN
            'Doplnit odds ingest orchestration, parsery a public.odds merge.'

        ELSE
            'Vyžaduje ruční kontrolu.'

    END AS implementation_note,

    q.last_run_at,
    q.next_action

FROM ops.v_execution_priority_queue_v1 q

ORDER BY
    q.execution_priority_score DESC,
    q.sport_code,
    q.entity;