SELECT *
FROM ops.sports_import_plan;

SELECT *
FROM ops.provider_jobs
ORDER BY provider, sport_code, priority;

SELECT *
FROM ops.ingest_entity_plan
ORDER BY sport_code, priority;

SELECT *
FROM ops.v_ingest_planner_queue
LIMIT 30;

SELECT *
FROM ops.v_api_budget_today;
