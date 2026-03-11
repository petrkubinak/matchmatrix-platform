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
    CASE
        WHEN s.code = 'FB'  THEN 'football'
        WHEN s.code = 'HK'  THEN 'hockey'
        WHEN s.code = 'BK'  THEN 'basketball'
        WHEN s.code = 'TN'  THEN 'tennis'
        WHEN s.code = 'MMA' THEN 'mma'
        WHEN s.code = 'VB'  THEN 'volleyball'
        WHEN s.code = 'HB'  THEN 'handball'
        WHEN s.code = 'BSB' THEN 'baseball'
        WHEN s.code = 'RGB' THEN 'rugby'
        WHEN s.code = 'CK'  THEN 'cricket'
        WHEN s.code = 'FH'  THEN 'field_hockey'
        WHEN s.code = 'AFB' THEN 'american_football'
        WHEN s.code = 'ESP' THEN 'esports'
    END AS sport_code,

    l.id,
    l.ext_source,
    l.ext_league_id,
    '' AS season,

    true,
    3,

    7,
    14,
    3,

    1,

    l.name,

    'GLOBAL_AUTO'
FROM public.leagues l
JOIN public.sports s
    ON s.id = l.sport_id
WHERE l.ext_source IS NOT NULL
ON CONFLICT (provider, provider_league_id) DO NOTHING;