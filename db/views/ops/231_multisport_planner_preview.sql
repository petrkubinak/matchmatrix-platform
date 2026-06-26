-- ============================================
-- 231_multisport_planner_preview.sql
-- Preview multisport planner vstupů
-- ============================================

-- 1) Přehled nových multisport targetů
SELECT
    sport_code,
    provider,
    run_group,
    canonical_league_id,
    provider_league_id,
    season,
    enabled,
    tier
FROM ops.ingest_targets
WHERE sport_code IN ('TN','MMA','VB','HB','BSB','RGB','CK','FH','AFB','ESP','DRT')
ORDER BY sport_code, provider, canonical_league_id;

-- 2) Napojení target -> entity plan
SELECT
    t.sport_code,
    t.provider,
    t.run_group,
    e.entity,
    e.default_run_group,
    e.enabled AS entity_enabled,
    e.priority
FROM ops.ingest_targets t
JOIN ops.ingest_entity_plan e
  ON e.sport_code = t.sport_code
 AND e.provider   = t.provider
WHERE t.sport_code IN ('TN','MMA','VB','HB','BSB','RGB','CK','FH','AFB','ESP','DRT')
ORDER BY t.sport_code, t.provider, e.priority;

-- 3) Napojení target -> provider_jobs
SELECT
    t.sport_code,
    t.provider,
    t.run_group,
    j.job_code,
    j.endpoint_code,
    j.ingest_mode,
    j.enabled AS job_enabled,
    j.priority
FROM ops.ingest_targets t
JOIN ops.provider_jobs j
  ON j.sport_code = t.sport_code
 AND j.provider   = t.provider
WHERE t.sport_code IN ('TN','MMA','VB','HB','BSB','RGB','CK','FH','AFB','ESP','DRT')
ORDER BY t.sport_code, t.provider, j.priority;

-- 4) Souhrn připravenosti po sportech
SELECT
    t.sport_code,
    count(distinct t.canonical_league_id) AS target_count,
    count(distinct e.entity)              AS entity_count,
    count(distinct j.job_code)            AS job_count
FROM ops.ingest_targets t
LEFT JOIN ops.ingest_entity_plan e
  ON e.sport_code = t.sport_code
 AND e.provider   = t.provider
LEFT JOIN ops.provider_jobs j
  ON j.sport_code = t.sport_code
 AND j.provider   = t.provider
WHERE t.sport_code IN ('TN','MMA','VB','HB','BSB','RGB','CK','FH','AFB','ESP','DRT')
GROUP BY t.sport_code
ORDER BY t.sport_code;