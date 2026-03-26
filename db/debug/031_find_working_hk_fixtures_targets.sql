-- 031_find_working_hk_fixtures_targets.sql
-- Cíl:
-- najít HK fixtures league targety, které historicky nebo nově vrací data

-- 1) payloady z unified raw pro HK fixtures
SELECT
    split_part(external_id, '_', 1) AS provider_league_id,
    split_part(external_id, '_', 2) AS season,
    COALESCE((payload_json ->> 'results')::int, 0) AS results_count,
    fetched_at,
    parse_status
FROM staging.stg_api_payloads
WHERE provider = 'api_hockey'
  AND entity_type = 'fixtures'
ORDER BY fetched_at DESC, provider_league_id;

-- 2) agregace podle ligy
SELECT
    split_part(external_id, '_', 1) AS provider_league_id,
    MAX(COALESCE((payload_json ->> 'results')::int, 0)) AS max_results,
    COUNT(*) AS payload_count,
    MAX(fetched_at) AS last_seen_at
FROM staging.stg_api_payloads
WHERE provider = 'api_hockey'
  AND entity_type = 'fixtures'
GROUP BY split_part(external_id, '_', 1)
ORDER BY max_results DESC, provider_league_id;

-- 3) co je teď v planneru pro HK fixtures
SELECT
    id,
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
  AND entity = 'fixtures'
  AND run_group = 'HK_TOP'
ORDER BY priority, id;