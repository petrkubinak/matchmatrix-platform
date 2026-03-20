SELECT
    sport_code,
    run_group,
    provider,
    entity,
    COUNT(*) AS jobs
FROM ops.v_fb_eu_ingest_jobs
GROUP BY sport_code, run_group, provider, entity
ORDER BY sport_code, run_group, provider, entity;