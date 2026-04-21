-- 723_insert_hb_ingest_planner.sql
-- Naplneni planner queue pro HB z existujicich ingest_targets

-- 1) kontrola pred insertem
SELECT
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
    ip.next_run
FROM ops.ingest_planner ip
WHERE ip.provider = 'api_handball'
  AND ip.sport_code = 'HB'
ORDER BY ip.entity, ip.provider_league_id, ip.season;


-- 2) insert HB fixtures do planneru
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
    t.provider,
    t.sport_code,
    'fixtures' AS entity,
    t.provider_league_id,
    t.season,
    t.run_group,
    7030 AS priority,
    'pending' AS status,
    0 AS attempts,
    NULL AS last_attempt,
    NOW() AS next_run,
    NOW() AS created_at,
    NOW() AS updated_at
FROM ops.ingest_targets t
WHERE t.provider = 'api_handball'
  AND t.sport_code = 'HB'
  AND t.run_group = 'HB_CORE'
  AND t.enabled = true
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_planner ip
      WHERE ip.provider = t.provider
        AND ip.sport_code = t.sport_code
        AND ip.entity = 'fixtures'
        AND ip.provider_league_id = t.provider_league_id
        AND ip.season = t.season
        AND ip.run_group = t.run_group
  );


-- 3) kontrola po insertu
SELECT
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
    ip.next_run
FROM ops.ingest_planner ip
WHERE ip.provider = 'api_handball'
  AND ip.sport_code = 'HB'
  AND ip.entity = 'fixtures'
  AND ip.run_group = 'HB_CORE'
ORDER BY ip.provider_league_id, ip.season;