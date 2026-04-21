-- Cíl:
-- 1) najít existující HB leagues planner row
-- 2) vrátit ji do pending stavu
-- 3) když neexistuje pending/použitelná row, založit ji

-- 1) kontrola pred zmenou
SELECT
    id,
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    last_attempt,
    next_run,
    created_at,
    updated_at
FROM ops.ingest_planner
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'leagues'
  AND run_group = 'HB_CORE'
ORDER BY id;

-- 2) reset existujiciho HB leagues planner jobu do pending
UPDATE ops.ingest_planner
SET status = 'pending',
    attempts = 0,
    last_attempt = NULL,
    next_run = NOW(),
    updated_at = NOW()
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'leagues'
  AND run_group = 'HB_CORE';

-- 3) pokud radek neexistuje, zaloz ho
INSERT INTO ops.ingest_planner (
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    last_attempt,
    next_run,
    created_at,
    updated_at
)
SELECT
    'api_handball' AS provider,
    'HB' AS sport_code,
    'leagues' AS entity,
    NULL AS provider_league_id,
    '2024' AS season,
    'HB_CORE' AS run_group,
    7010 AS priority,
    'pending' AS status,
    0 AS attempts,
    NULL AS last_attempt,
    NOW() AS next_run,
    NOW() AS created_at,
    NOW() AS updated_at
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.ingest_planner
    WHERE provider = 'api_handball'
      AND sport_code = 'HB'
      AND entity = 'leagues'
      AND run_group = 'HB_CORE'
);

-- 4) kontrola po zmene
SELECT
    id,
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    next_run,
    updated_at
FROM ops.ingest_planner
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'leagues'
  AND run_group = 'HB_CORE'
ORDER BY id;
