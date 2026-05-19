CREATE OR REPLACE VIEW ops.v_top_ingest_jobs_test_mode AS
SELECT *
FROM ops.v_top_ingest_jobs_runnable
WHERE entity <> 'odds'
  AND COALESCE(NULLIF(TRIM(season), ''), '2024') IN ('2022', '2023', '2024');