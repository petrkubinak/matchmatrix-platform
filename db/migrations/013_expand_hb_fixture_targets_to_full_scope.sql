-- 013_expand_hb_fixture_targets_to_full_scope.sql
-- Rozšíření HB fixtures ingest_targets na celý aktuální scope api_handball lig

INSERT INTO ops.ingest_targets
(
    sport_code,
    canonical_league_id,
    provider,
    provider_league_id,
    season,
    enabled,
    tier,
    fixtures_days_back,
    fixtures_days_forward,
    odds_days_forward,
    max_requests_per_run,
    notes,
    run_group,
    created_at,
    updated_at
)
SELECT
    'HB' AS sport_code,
    l.id AS canonical_league_id,
    'api_handball' AS provider,
    lpm.provider_league_id,
    '2024' AS season,
    true AS enabled,
    CASE
        WHEN lpm.provider_league_id IN ('131', '145', '183') THEN 1
        WHEN l.country = 'Europe' THEN 2
        WHEN l.country IN ('World', 'Africa', 'Asia') THEN 2
        ELSE 3
    END AS tier,
    30 AS fixtures_days_back,
    30 AS fixtures_days_forward,
    3 AS odds_days_forward,
    NULL AS max_requests_per_run,
    'HB full scope after leagues unblock | auto-expanded from public.league_provider_map' AS notes,
    'HB_CORE' AS run_group,
    NOW() AS created_at,
    NOW() AS updated_at
FROM public.league_provider_map lpm
JOIN public.leagues l
  ON l.id = lpm.league_id
WHERE lpm.provider = 'api_handball'
  AND l.ext_source = 'api_handball'
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_targets t
      WHERE t.sport_code = 'HB'
        AND t.provider = 'api_handball'
        AND t.run_group = 'HB_CORE'
        AND t.provider_league_id = lpm.provider_league_id
        AND COALESCE(t.season, '') = '2024'
  );