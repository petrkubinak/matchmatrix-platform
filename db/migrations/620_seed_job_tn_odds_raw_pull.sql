-- 620_seed_job_tn_odds_raw_pull.sql
-- Účel:
-- zaregistruje TN odds raw pull job do ops.jobs

BEGIN;

INSERT INTO ops.jobs (
    code,
    name,
    description,
    recommended,
    enabled,
    default_params
)
SELECT
    'TN_ODDS_RAW_PULL_V1',
    'Tennis odds raw pull v1',
    'Pull RAW winning odds payloads for tennis matches from RapidAPI TennisAPI into public.api_raw_payloads.',
    'Run manually first in dry-run mode, then enable for planner/runtime.',
    true,
    jsonb_build_object(
        'limit', 3,
        'provider_id', 1,
        'sleep_ms', 300,
        'timeout_sec', 30,
        'dry_run', true
    )
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.jobs
    WHERE code = 'TN_ODDS_RAW_PULL_V1'
);

COMMIT;

-- kontrola
SELECT
    code,
    name,
    enabled,
    default_params
FROM ops.jobs
WHERE code = 'TN_ODDS_RAW_PULL_V1';