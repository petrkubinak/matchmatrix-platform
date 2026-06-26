BEGIN;

UPDATE ops.ingest_entity_plan
SET
    worker_script = 'workers/run_people_pipeline_v22_from_planner.py',
    notes = COALESCE(notes, '') || ' | FIX 701: AFB players runtime CONFIRMED, linked to PEOPLE pipeline V2.2.',
    updated_at = now()
WHERE provider = 'api_american_football'
  AND sport_code = 'AFB'
  AND entity = 'players'
  AND enabled = true
  AND COALESCE(worker_script, '') = '';

UPDATE ops.provider_entity_coverage
SET
    coverage_status = 'runtime_tested',
    worker_script = 'workers/run_people_pipeline_v22_from_planner.py',
    notes = COALESCE(notes, '') || ' | FIX 701: aligned with runtime_entity_audit CONFIRMED.',
    next_action = 'Rozšířit AFB people scope na více týmů/sezon.',
    updated_at = now()
WHERE provider = 'api_american_football'
  AND sport_code = 'AFB'
  AND entity = 'players';

COMMIT;

