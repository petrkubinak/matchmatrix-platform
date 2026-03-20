INSERT INTO ops.ingest_runtime_config
(
    provider,
    sport_code,
    plan_code,
    season_min,
    season_max,
    maintenance_season,
    max_daily_requests,
    notes,
    is_active
)
VALUES
(
    'api_football',
    'football',
    'free_test',
    '2022',
    '2024',
    '2024',
    100,
    'Testovaci free rezim: povolene sezony 2022-2024, maintenance na 2024.',
    TRUE
)
ON CONFLICT (provider, sport_code, plan_code)
DO UPDATE SET
    season_min = EXCLUDED.season_min,
    season_max = EXCLUDED.season_max,
    maintenance_season = EXCLUDED.maintenance_season,
    max_daily_requests = EXCLUDED.max_daily_requests,
    notes = EXCLUDED.notes,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();