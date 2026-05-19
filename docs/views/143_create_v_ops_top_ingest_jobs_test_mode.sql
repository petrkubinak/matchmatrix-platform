CREATE OR REPLACE VIEW ops.v_top_ingest_jobs_test_mode AS
SELECT
    *,
    COALESCE(NULLIF(TRIM(season), ''), '2024') AS effective_season
FROM ops.v_top_ingest_jobs_runnable
WHERE COALESCE(NULLIF(TRIM(season), ''), '2024') IN ('2022', '2023', '2024');