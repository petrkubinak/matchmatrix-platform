-- 703_insert_ingest_targets_hb_core_extension.sql
-- Cíl:
-- Doplnit HB ingest targety pro canonical public.leagues:
-- 145 -> EHF European League
-- 183 -> African Championship
--
-- 131 Champions League uz existuje, tu zde znovu nevkladame.

WITH src AS (
    SELECT *
    FROM (
        VALUES
            ('HB', 24882::bigint, 'api_handball', '145', '2024', true, 1, 30, 30, 3, 'HB_CORE',
             'HB extension: EHF European League (api_handball league_id=145) | fixtures date window enabled (±30 days)'),

            ('HB', 24883::bigint, 'api_handball', '183', '2024', true, 2, 30, 30, 3, 'HB_CORE',
             'HB extension: African Championship (api_handball league_id=183) | fixtures date window enabled (±30 days)')
    ) AS t(
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
        run_group,
        notes
    )
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
    run_group,
    notes
)
SELECT
    s.sport_code,
    s.canonical_league_id,
    s.provider,
    s.provider_league_id,
    s.season,
    s.enabled,
    s.tier,
    s.fixtures_days_back,
    s.fixtures_days_forward,
    s.odds_days_forward,
    s.run_group,
    s.notes
FROM src s
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.ingest_targets t
    WHERE t.provider = s.provider
      AND t.sport_code = s.sport_code
      AND t.provider_league_id = s.provider_league_id
      AND COALESCE(t.season, '') = COALESCE(s.season, '')
);

-- kontrola
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