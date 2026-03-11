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
    run_group
)
SELECT
    lip.sport_code,
    l.id AS canonical_league_id,
    lip.provider,
    lip.provider_league_id::text,
    COALESCE(lip.season::text, '') AS season,
    lip.enabled,
    lip.tier,
    lip.fixtures_days_back,
    lip.fixtures_days_forward,
    lip.odds_days_forward,
    lip.max_requests_per_run,
    lip.notes,
    CASE
        WHEN lip.tier = 1 THEN 'GLOBAL_TIER1'
        WHEN lip.tier = 2 THEN 'GLOBAL_TIER2'
        WHEN lip.tier = 3 THEN 'GLOBAL_TIER3'
        ELSE 'GLOBAL_TIER4'
    END AS run_group
FROM ops.league_import_plan lip
JOIN ops.sports_import_plan sip
    ON sip.sport_code = lip.sport_code
   AND sip.enabled = true
JOIN public.leagues l
    ON l.ext_source = lip.provider
   AND l.ext_league_id = lip.provider_league_id::text
WHERE lip.enabled = true
ON CONFLICT (provider, provider_league_id) DO NOTHING;