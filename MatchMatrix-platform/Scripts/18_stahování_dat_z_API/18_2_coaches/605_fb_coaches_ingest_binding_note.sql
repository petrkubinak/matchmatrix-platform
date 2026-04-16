-- 605_fb_coaches_ingest_binding_note.sql
-- Účel:
-- pracovní poznámka / kontrolní zápis k FB coaches ingest binding gap

select
    'FB coaches ingest binding gap' as task_name,
    'api_football' as provider,
    'FB' as sport_code,
    'coaches' as entity,
    'provider_jobs exist, ale jobs/scheduler/planner/staging jsou prazdne' as current_problem,
    'chybi realna job/worker vazba pro ingest do staging.stg_provider_coaches' as root_cause,
    'dalsi krok: dohledat nebo doplnit worker/script binding pro coaches a az potom reseit planner seed' as next_step;