SELECT
    provider,
    entity,
    COUNT(*) AS jobs
FROM ops.v_fb_eu_ingest_jobs_test_mode
GROUP BY provider, entity
ORDER BY provider, entity;