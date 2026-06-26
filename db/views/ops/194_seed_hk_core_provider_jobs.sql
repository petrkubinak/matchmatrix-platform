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
    notes
)
SELECT
    c.provider,
    c.sport_code,
    c.job_code,
    c.entity AS endpoint_code,
    'fast' AS ingest_mode,
    true AS enabled,
    CASE c.entity
        WHEN 'leagues'  THEN 2110
        WHEN 'teams'    THEN 2120
        WHEN 'fixtures' THEN 2130
        WHEN 'odds'     THEN 2140
        WHEN 'players'  THEN 2150
        WHEN 'coaches'  THEN 2160
        ELSE 2999
    END AS priority,
    50 AS batch_size,
    50 AS max_requests_per_run,
    3 AS retry_limit,
    0 AS cooldown_seconds,
    7 AS days_back,
    14 AS days_forward,
    'HK CORE provider jobs seeded from ops.v_ops_hk_core_full_job_catalog' AS notes
FROM ops.v_ops_hk_core_full_job_catalog c
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.provider_jobs pj
    WHERE pj.provider = c.provider
      AND pj.sport_code = c.sport_code
      AND pj.job_code = c.job_code
);