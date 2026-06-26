UPDATE ops.dispatch_queue
SET
    dispatch_status = 'SKIPPED_UNSUPPORTED_PROVIDER',
    completed_at = NOW(),
    execution_result = 'UNSUPPORTED_PROVIDER_SPORT',
    execution_notes = 'run_unified_ingest_v1.py nepodporuje kombinaci sportsdataio/basketball.'
WHERE provider = 'sportsdataio'
  AND sport_code = 'BK'
  AND entity = 'players'
  AND dispatch_status IN ('PENDING','SELECTED','READY_TO_RUN','SKIPPED_NO_PENDING')
RETURNING
    id,
    provider,
    sport_code,
    entity,
    dispatch_status,
    execution_result;