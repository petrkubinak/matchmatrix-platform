-- 722_audit_hb_planner_rows.sql
-- Audit: existuji skutecne HB planner/job rows?

-- 1) provider_jobs pro api_handball / HB
SELECT
    'provider_jobs' AS src,
    pj.id,
    pj.provider,
    pj.sport_code,
    pj.job_code,
    pj.endpoint_code,
    pj.ingest_mode,
    pj.enabled,
    pj.priority,
    pj.batch_size,
    pj.max_requests_per_run,
    pj.retry_limit,
    pj.cooldown_seconds,
    pj.days_back,
    pj.days_forward,
    pj.notes
FROM ops.provider_jobs pj
WHERE pj.provider = 'api_handball'
  AND pj.sport_code = 'HB'
ORDER BY pj.job_code, pj.endpoint_code;

-- 2) ingest_planner pro api_handball / HB / fixtures / HB_CORE
SELECT
    'ingest_planner' AS src,
    ip.id,
    ip.provider,
    ip.sport_code,
    ip.entity,
    ip.provider_league_id,
    ip.season,
    ip.run_group,
    ip.priority,
    ip.status,
    ip.attempts,
    ip.last_attempt,
    ip.next_run,
    ip.created_at,
    ip.updated_at
FROM ops.ingest_planner ip
WHERE ip.provider = 'api_handball'
  AND ip.sport_code = 'HB'
  AND ip.entity = 'fixtures'
  AND ip.run_group = 'HB_CORE'
ORDER BY ip.provider_league_id, ip.season;

-- 3) rychly souhrn
SELECT
    'provider_jobs_count' AS check_name,
    COUNT(*)::bigint AS row_count
FROM ops.provider_jobs pj
WHERE pj.provider = 'api_handball'
  AND pj.sport_code = 'HB'

UNION ALL

SELECT
    'ingest_planner_count' AS check_name,
    COUNT(*)::bigint AS row_count
FROM ops.ingest_planner ip
WHERE ip.provider = 'api_handball'
  AND ip.sport_code = 'HB'
  AND ip.entity = 'fixtures'
  AND ip.run_group = 'HB_CORE';