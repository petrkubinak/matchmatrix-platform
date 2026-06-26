-- ============================================================
-- 885_seed_players_jobs_from_enrichment_plan_v1.sql
-- Přenese player_enrichment_plan -> ingest_planner
-- ============================================================

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
    next_run,
    created_at,
    updated_at
)
SELECT
    'api_football'                    AS provider,
    'FB'                              AS sport_code,
    'players'                         AS entity,
    external_league_id                AS provider_league_id,
    season,
    'FB_PEOPLE'                       AS run_group,
    50                                AS priority,
    'pending'                         AS status,
    0                                 AS attempts,
    NOW()                             AS next_run,
    NOW(),
    NOW()
FROM ops.player_enrichment_plan
WHERE provider = 'api_football'
  AND entity = 'players'
  AND status = 'pending'
GROUP BY external_league_id, season;

COMMIT;

SELECT
    provider,
    sport_code,
    entity,
    run_group,
    status,
    COUNT(*)
FROM ops.ingest_planner
WHERE provider = 'api_football'
  AND entity = 'players'
GROUP BY provider, sport_code, entity, run_group, status;