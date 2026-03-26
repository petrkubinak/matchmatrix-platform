-- 027_check_hk_team_targets.sql
-- Cíl:
-- 1) ukázat poslední HK teams payloady a jejich results
-- 2) rychle vytipovat použitelné HK league targety

SELECT
    id,
    provider,
    sport_code,
    entity_type,
    external_id,
    season,
    COALESCE((payload_json ->> 'results')::int, 0) AS results_count,
    parse_status,
    fetched_at
FROM staging.stg_api_payloads
WHERE provider = 'api_hockey'
  AND entity_type = 'teams'
ORDER BY id DESC
LIMIT 50;

-- přehled podle ligy
SELECT
    split_part(external_id, '_', 1) AS provider_league_id,
    MAX(COALESCE((payload_json ->> 'results')::int, 0)) AS max_results,
    COUNT(*) AS payload_count,
    MAX(fetched_at) AS last_seen_at
FROM staging.stg_api_payloads
WHERE provider = 'api_hockey'
  AND entity_type = 'teams'
GROUP BY split_part(external_id, '_', 1)
ORDER BY max_results DESC, provider_league_id;

-- HK_TOP planner targety pro teams
SELECT
    id,
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    status,
    attempts,
    priority,
    run_group,
    updated_at
FROM ops.ingest_planner
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
  AND entity = 'teams'
  AND run_group = 'HK_TOP'
ORDER BY priority, id;