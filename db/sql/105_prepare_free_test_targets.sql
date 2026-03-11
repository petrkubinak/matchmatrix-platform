-- všechno nejdřív vypnout pro test
UPDATE ops.ingest_targets
SET enabled = false
WHERE sport_code IN ('football', 'basketball', 'hockey');

-- povolit jen testovací sezóny 2022-2024
UPDATE ops.ingest_targets
SET enabled = true
WHERE sport_code IN ('football', 'basketball', 'hockey')
  AND season IN ('2022', '2023', '2024');

-- pokud chceš zatím testovat jen football top ligy:
UPDATE ops.ingest_targets
SET
    tier = 1,
    run_group = 'FREE_TEST_FOOTBALL',
    max_requests_per_run = 1
WHERE sport_code = 'football'
  AND provider = 'api_football'
  AND provider_league_id IN ('39', '78', '140')
  AND season IN ('2022', '2023', '2024');