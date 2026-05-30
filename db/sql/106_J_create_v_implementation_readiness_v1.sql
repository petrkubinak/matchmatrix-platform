/*
MATCHMATRIX SQL 106_J V1

Co to je:
Implementation readiness view.

K čemu to je:
Rozliší:
- co je už skutečně spustitelné
- co je připravené, ale čeká na PRO/API tarif
- co je částečné
- co ještě není implementované

Výsledek:
ops.v_implementation_readiness_v1
*/

CREATE OR REPLACE VIEW ops.v_implementation_readiness_v1 AS

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
        WHEN q.entity IN ('fixtures', 'teams', 'leagues')
         AND q.resolved_worker_script = 'workers/run_ingest_cycle_v3.py'
        THEN 'IMPLEMENTED'

        WHEN q.entity = 'players'
         AND q.resolved_worker_script = 'workers/run_people_pipeline_v22_from_planner.py'
        THEN 'IMPLEMENTED'

        WHEN q.entity IN ('articles', 'media', 'highlights')
         AND q.resolved_worker_script = 'workers/run_media_pipeline_v1.py'
        THEN 'PARTIAL'

        WHEN q.entity = 'odds'
         AND (
                q.run_group ILIKE '%ODDS%'
             OR q.entity = 'odds'
         )
        THEN 'NOT_IMPLEMENTED'

        ELSE 'REVIEW_REQUIRED'
    END AS implementation_state,

    CASE
        WHEN q.entity = 'odds'
        THEN 'Doplnit odds worker: pull -> raw/staging -> parser -> public.odds merge.'

        WHEN q.entity IN ('articles', 'media', 'highlights')
        THEN 'Media pipeline existuje částečně; doplnit source-specific extractory a scheduler routing.'

        WHEN q.entity IN ('fixtures', 'teams', 'leagues')
        THEN 'Core pipeline je napojená přes run_ingest_cycle_v3.'

        WHEN q.entity = 'players'
        THEN 'People pipeline je napojená přes run_people_pipeline_v22_from_planner.'

        ELSE 'Vyžaduje ruční kontrolu.'
    END AS implementation_note,

    q.last_run_at,
    q.next_action

FROM ops.v_execution_priority_queue_v1 q

ORDER BY
    q.execution_priority_score DESC,
    q.sport_code,
    q.entity;