CREATE OR REPLACE VIEW ops.v_top_ingest_jobs_full_mode AS
SELECT
    *,
    COALESCE(NULLIF(TRIM(season), ''), '2025') AS effective_season
FROM ops.v_top_ingest_jobs_ordered;