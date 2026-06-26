INSERT INTO ops.provider_worker_registry (
    provider,
    sport_code,
    entity,
    worker_type,
    worker_script,
    notes
)
VALUES
('api_football', 'FB', 'leagues',  'UNIFIED_INGEST', 'ingest/run_unified_ingest_v1.py', 'Football leagues přes unified ingest'),
('api_football', 'FB', 'teams',    'UNIFIED_INGEST', 'ingest/run_unified_ingest_v1.py', 'Football teams přes unified ingest'),
('api_football', 'FB', 'fixtures', 'UNIFIED_INGEST', 'ingest/run_unified_ingest_v1.py', 'Football fixtures přes unified ingest'),

('api_cricket', 'CK', 'leagues',  'UNIFIED_INGEST', 'ingest/run_unified_ingest_v1.py', 'Cricket leagues přes unified ingest'),
('api_cricket', 'CK', 'teams',    'UNIFIED_INGEST', 'ingest/run_unified_ingest_v1.py', 'Cricket teams přes unified ingest'),
('api_cricket', 'CK', 'fixtures', 'UNIFIED_INGEST', 'ingest/run_unified_ingest_v1.py', 'Cricket fixtures přes unified ingest')

ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    worker_type = EXCLUDED.worker_type,
    worker_script = EXCLUDED.worker_script,
    notes = EXCLUDED.notes,
    updated_at = NOW();