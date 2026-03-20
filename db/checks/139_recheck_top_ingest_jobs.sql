SELECT
    provider,
    sport_code,
    entity,
    COUNT(*) AS rows_count
FROM ops.v_top_ingest_jobs
GROUP BY provider, sport_code, entity
ORDER BY provider, sport_code, entity;