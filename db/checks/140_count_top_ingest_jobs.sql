SELECT
    COUNT(*) AS total_top_jobs,
    COUNT(*) FILTER (WHERE sport_code = 'FB') AS fb_jobs,
    COUNT(*) FILTER (WHERE sport_code = 'BK') AS bk_jobs,
    COUNT(*) FILTER (WHERE sport_code = 'HK') AS hk_jobs
FROM ops.v_top_ingest_jobs;