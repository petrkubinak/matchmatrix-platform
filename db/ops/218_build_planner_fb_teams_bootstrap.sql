
-- 218_build_planner_fb_teams_bootstrap.sql
-- Vytvoření planner jobů pro TEAMS (FB bootstrap)

BEGIN;

INSERT INTO ops.ingest_planner
(
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    created_at,
    updated_at
)
SELECT
    t.provider,
    t.sport_code,
    'teams' AS entity,
    t.provider_league_id,
    t.season,
    t.run_group,
    2000 AS priority,
    'pending' AS status,
    0 AS attempts,
    NOW() AS created_at,
    NOW() AS updated_at
FROM ops.ingest_targets t
LEFT JOIN ops.ingest_planner p
    ON p.provider = t.provider
   AND p.sport_code = t.sport_code
   AND p.entity = 'teams'
   AND COALESCE(p.provider_league_id, '') = COALESCE(t.provider_league_id, '')
   AND COALESCE(p.season, '') = COALESCE(t.season, '')
   AND COALESCE(p.run_group, '') = COALESCE(t.run_group, '')
WHERE t.enabled = TRUE
  AND t.provider = 'api_football'
  AND t.sport_code = 'FB'
  AND t.run_group = 'FB_BOOTSTRAP_V1'
  AND p.id IS NULL;

COMMIT;

SELECT
    entity,
    run_group,
    status,
    COUNT(*) AS jobs
FROM ops.ingest_planner
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND run_group = 'FB_BOOTSTRAP_V1'
GROUP BY entity, run_group, status
ORDER BY entity, status;