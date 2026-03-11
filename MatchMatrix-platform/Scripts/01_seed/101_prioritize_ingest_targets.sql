-- 1) základ: všechno dát do defaultního bootstrap režimu
UPDATE ops.ingest_targets
SET
    tier = 3,
    run_group = 'GLOBAL_TIER3',
    max_requests_per_run = COALESCE(max_requests_per_run, 1)
WHERE sport_code IN ('football', 'basketball', 'hockey');

-- 2) top football ligy povýšit do tier 1
UPDATE ops.ingest_targets
SET
    tier = 1,
    run_group = 'GLOBAL_TIER1',
    max_requests_per_run = 3
WHERE sport_code = 'football'
  AND provider_league_id IN ('39', '140', '78');

-- 3) rozumný první val pro basketball
UPDATE ops.ingest_targets
SET
    tier = 2,
    run_group = 'GLOBAL_TIER2',
    max_requests_per_run = 2
WHERE sport_code = 'basketball';

-- 4) rozumný první val pro hockey
UPDATE ops.ingest_targets
SET
    tier = 2,
    run_group = 'GLOBAL_TIER2',
    max_requests_per_run = 2
WHERE sport_code = 'hockey';

-- 5) football mimo top ligy nechat jako tier 3
UPDATE ops.ingest_targets
SET
    tier = 3,
    run_group = 'GLOBAL_TIER3',
    max_requests_per_run = 1
WHERE sport_code = 'football'
  AND provider_league_id NOT IN ('39', '140', '78');