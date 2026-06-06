INSERT INTO ops.provider_worker_registry (
    provider,
    sport_code,
    entity,
    worker_type,
    worker_script,
    is_supported,
    is_active,
    notes
)
VALUES (
    'api_cricket',
    'CK',
    'players',
    'CUSTOM_WORKER',
    NULL,
    true,
    true,
    'Unified ingest hráče pro api_cricket nepodporuje. Players budou řešeni přes samostatného providera/custom worker.'
)
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    worker_type = EXCLUDED.worker_type,
    worker_script = EXCLUDED.worker_script,
    is_supported = EXCLUDED.is_supported,
    is_active = EXCLUDED.is_active,
    notes = EXCLUDED.notes,
    updated_at = NOW();