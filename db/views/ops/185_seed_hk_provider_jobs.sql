-- =========================================================
-- 185_seed_hk_provider_jobs.sql
-- MATCHMATRIX - seed HK provider jobs from catalog
-- =========================================================

INSERT INTO ops.provider_jobs
(
    provider,
    sport_code,
    job_code,
    endpoint_code,
    ingest_mode,
    enabled,
    priority,
    batch_size,
    max_requests_per_run,
    retry_limit,
    cooldown_seconds,
    days_back,
    days_forward,
    notes
)
SELECT
    provider,
    sport_code,
    job_code,
    entity AS endpoint_code,
    'fast' AS ingest_mode,
    true AS enabled,
    2000 + entity_order * 10 AS priority,
    20 AS batch_size,
    20 AS max_requests_per_run,
    3 AS retry_limit,
    0 AS cooldown_seconds,
    7 AS days_back,
    14 AS days_forward,
    'HK TOP job seeded from ops.v_ops_hk_job_catalog' AS notes
FROM ops.v_ops_hk_job_catalog
ON CONFLICT (provider, sport_code, job_code)
DO UPDATE SET
    endpoint_code         = EXCLUDED.endpoint_code,
    ingest_mode           = EXCLUDED.ingest_mode,
    enabled               = EXCLUDED.enabled,
    priority              = EXCLUDED.priority,
    batch_size            = EXCLUDED.batch_size,
    max_requests_per_run  = EXCLUDED.max_requests_per_run,
    retry_limit           = EXCLUDED.retry_limit,
    cooldown_seconds      = EXCLUDED.cooldown_seconds,
    days_back             = EXCLUDED.days_back,
    days_forward          = EXCLUDED.days_forward,
    notes                 = EXCLUDED.notes;

-- kontrola
SELECT
    provider,
    sport_code,
    job_code,
    endpoint_code,
    ingest_mode,
    enabled,
    priority,
    batch_size,
    max_requests_per_run,
    retry_limit,
    cooldown_seconds,
    days_back,
    days_forward
FROM ops.provider_jobs
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
ORDER BY priority, endpoint_code;