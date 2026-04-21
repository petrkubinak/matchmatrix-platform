-- 702_hb_extend_ingest_targets_safe.sql
-- Bez technickych fallback ID.
-- Vlozi jen ty HB targety, pro ktere uz existuje canonical league v public.leagues.

WITH hb_candidates AS (
    SELECT *
    FROM (
        VALUES
            ('HB', 'api_handball', '131', '2024', 'HB_CORE', 1, 'HB smoke test confirmed - Champions League'),
            ('HB', 'api_handball', '145', '2024', 'HB_CORE', 1, 'HB extension - EHF European League'),
            ('HB', 'api_handball', '183', '2024', 'HB_CORE', 2, 'HB extension - African Championship')
    ) AS t(sport_code, provider, provider_league_id, season, run_group, tier, notes)
),
resolved AS (
    SELECT
        c.sport_code,
        l.id::bigint AS canonical_league_id,
        c.provider,
        c.provider_league_id,
        c.season,
        c.run_group,
        c.tier,
        c.notes
    FROM hb_candidates c
    JOIN public.leagues l
      ON l.ext_source = c.provider
     AND l.ext_league_id = c.provider_league_id
)
INSERT INTO ops.ingest_targets (
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
    r.sport_code,
    r.canonical_league_id,
    r.provider,
    r.provider_league_id,
    r.season,
    TRUE,
    r.tier,
    14,
    30,
    3,
    50,
    r.notes,
    r.run_group
FROM resolved r
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.ingest_targets t
    WHERE t.provider = r.provider
      AND t.sport_code = r.sport_code
      AND t.provider_league_id = r.provider_league_id
      AND COALESCE(t.season, '') = COALESCE(r.season, '')
);

-- kontrola vlozenych HB targetu
SELECT
    id,
    sport_code,
    canonical_league_id,
    provider,
    provider_league_id,
    season,
    enabled,
    tier,
    run_group,
    notes
FROM ops.ingest_targets
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
ORDER BY tier, provider_league_id, season;