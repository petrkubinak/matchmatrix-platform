-- ==========================================================
-- MATCHMATRIX
-- 037_ops_insert_job_ingest_cycle_v2.sql
--
-- Kam uložit:
-- C:\MatchMatrix-platform\db\037_ops_insert_job_ingest_cycle_v2.sql
-- ==========================================================

INSERT INTO ops.jobs
(
    code,
    name,
    description,
    recommended,
    enabled,
    default_params
)
VALUES
(
    'ingest_cycle_v2',
    'Ingest Cycle V2',
    'Planner-driven ingest cycle with worker lock, audit, planner execution and merge step.',
    true,
    true,
    '{}'::jsonb
)
ON CONFLICT (code) DO NOTHING;