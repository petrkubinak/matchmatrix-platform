-- Všechny football targety nejdřív zklidnit
UPDATE ops.ingest_targets
SET
    tier = 4,
    run_group = 'FOOTBALL_MAINTENANCE',
    max_requests_per_run = 1
WHERE sport_code = 'football';

-- Jen 3 top ligy nechat jako maintenance prioritu
UPDATE ops.ingest_targets
SET
    tier = 2,
    run_group = 'FOOTBALL_MAINTENANCE_TOP',
    max_requests_per_run = 1
WHERE sport_code = 'football'
  AND provider = 'api_football'
  AND provider_league_id IN ('39', '78', '140');

-- Basketball a hockey držet jako hlavní testovací sporty
UPDATE ops.ingest_targets
SET
    tier = 1,
    run_group = 'FREE_TEST_PRIMARY',
    max_requests_per_run = 1
WHERE sport_code IN ('basketball', 'hockey');