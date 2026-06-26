-- 213_build_planner_from_fb_bootstrap_v1.sql
-- FIX pro tvé schéma (bez canonical_league_id)

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
    'fixtures' AS entity,
    t.provider_league_id,
    t.season,
    t.run_group,
    CASE
        WHEN COALESCE(t.tier, 3) = 1 THEN 1000
        WHEN COALESCE(t.tier, 3) = 2 THEN 2000
        ELSE 3000
    END AS priority,
    'pending' AS status,
    0 AS attempts,
    NOW(),
    NOW()
FROM ops.ingest_targets t
LEFT JOIN ops.ingest_planner p
    ON p.provider = t.provider
   AND p.sport_code = t.sport_code
   AND p.entity = 'fixtures'
   AND COALESCE(p.provider_league_id, '') = COALESCE(t.provider_league_id, '')
   AND COALESCE(p.season, '') = COALESCE(t.season, '')
   AND COALESCE(p.run_group, '') = COALESCE(t.run_group, '')
WHERE t.enabled = TRUE
  AND t.sport_code = 'FB'
  AND t.provider = 'api_football'
  AND t.run_group = 'FB_BOOTSTRAP_V1'
  AND p.id IS NULL;

COMMIT;