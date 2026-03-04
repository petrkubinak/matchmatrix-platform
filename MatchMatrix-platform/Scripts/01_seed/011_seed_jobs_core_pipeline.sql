-- 091_seed_jobs_core_pipeline.sql
-- Seed základních produkčních jobů

INSERT INTO ops.jobs (code, name, description, recommended, enabled, default_params, created_at, updated_at)
VALUES

(
    'odds_refresh',
    'Odds refresh (0/+3)',
    'Fetch a merge odds for short forward window',
    true,
    true,
    '{
        "sport_code": "football",
        "provider": "api_football",
        "target_ids": [1],
        "odds_days_forward": 3,
        "max_requests_per_run": 100
    }'::jsonb,
    NOW(),
    NOW()
),

(
    'fixtures_refresh',
    'Fixtures refresh (-3/+7)',
    'Fetch and merge fixtures and status updates',
    true,
    true,
    '{
        "sport_code": "football",
        "provider": "api_football",
        "target_ids": [1],
        "fixtures_days_back": 3,
        "fixtures_days_forward": 7,
        "max_requests_per_run": 100
    }'::jsonb,
    NOW(),
    NOW()
),

(
    'model_refresh',
    'Model + feature refresh',
    'Rebuild features, datasets and run predictions',
    true,
    true,
    '{
        "sport_code": "football",
        "kickoff_from_days": 0,
        "kickoff_to_days": 7,
        "rebuild_features": true,
        "rebuild_dataset": true,
        "model_code": "mm_v1"
    }'::jsonb,
    NOW(),
    NOW()
)

ON CONFLICT (code)
DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    recommended = EXCLUDED.recommended,
    enabled = EXCLUDED.enabled,
    default_params = EXCLUDED.default_params,
    updated_at = NOW();