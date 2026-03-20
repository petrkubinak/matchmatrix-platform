-- ==========================================================
-- MATCHMATRIX
-- 039_ops_insert_job_unified_staging_to_public_merge.sql
--
-- Kam uložit:
-- C:\MatchMatrix-platform\db\039_ops_insert_job_unified_staging_to_public_merge.sql
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
    'unified_staging_to_public_merge',
    'Unified Staging To Public Merge',
    'Merges unified staging tables into public core tables.',
    true,
    true,
    '{}'::jsonb
)
ON CONFLICT (code) DO NOTHING;