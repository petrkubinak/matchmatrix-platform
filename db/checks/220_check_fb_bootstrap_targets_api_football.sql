SELECT
    provider,
    sport_code,
    run_group,
    enabled,
    COUNT(*) AS targets
FROM ops.ingest_targets
WHERE sport_code = 'FB'
  AND run_group = 'FB_BOOTSTRAP_V1'
GROUP BY provider, sport_code, run_group, enabled
ORDER BY provider, enabled;

SELECT
    provider,
    sport_code,
    provider_league_id,
    season,
    run_group,
    enabled
FROM ops.ingest_targets
WHERE sport_code = 'FB'
  AND run_group = 'FB_BOOTSTRAP_V1'
ORDER BY provider, provider_league_id
LIMIT 50;