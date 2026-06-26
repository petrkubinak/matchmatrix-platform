ROLLBACK;
BEGIN;

-- =========================================================
-- 178_seed_fb_provider_jobs_from_catalog_FINAL.sql
-- Seed football jobů do ops.provider_jobs (finální verze)
-- =========================================================

INSERT INTO ops.provider_jobs (
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
    notes,
    created_at,
    updated_at
)
SELECT
    c.provider,
    c.sport_code,
    c.job_code,
    c.entity AS endpoint_code,

    CASE
        WHEN c.layer = 'FB_TOP' THEN 'fast'
        WHEN c.layer = 'FB_FD_CORE' THEN 'slow'
        WHEN c.layer = 'FB_API_EXPANSION' THEN 'medium'
        ELSE 'medium'
    END AS ingest_mode,

    TRUE AS enabled,
    c.layer_order * 100 + c.entity_order AS priority,
    c.target_count AS batch_size,
    c.planned_requests AS max_requests_per_run,
    3 AS retry_limit,
    5 AS cooldown_seconds,
    CASE WHEN c.entity = 'fixtures' THEN 7 ELSE 0 END AS days_back,
    CASE WHEN c.entity = 'fixtures' THEN 7 ELSE 0 END AS days_forward,
    CONCAT(
        'Football layer=', c.layer,
        ', targets=', c.target_count,
        ', season=', c.min_effective_season, '-', c.max_effective_season
    ) AS notes,
    NOW(),
    NOW()
FROM ops.v_fb_job_catalog c
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.provider_jobs pj
    WHERE pj.job_code = c.job_code
);

COMMIT;

-- kontrola
SELECT
    provider,
    sport_code,
    endpoint_code,
    ingest_mode,
    job_code,
    priority,
    enabled,
    max_requests_per_run,
    batch_size
FROM ops.provider_jobs
WHERE sport_code = 'FB'
  AND job_code LIKE 'FB__%'
ORDER BY priority, job_code;