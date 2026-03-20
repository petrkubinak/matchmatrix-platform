INSERT INTO ops.jobs
(
    code,
    name,
    description,
    recommended,
    enabled,
    default_params
)
VALUES
(
    'unified_ingest_batch',
    'Unified Ingest Batch',
    'Batch runner pro unified ingest přes ops.ingest_targets a run_group.',
    'on-demand / panel / scheduler',
    true,
    '{}'::jsonb
)
ON CONFLICT (code) DO NOTHING;