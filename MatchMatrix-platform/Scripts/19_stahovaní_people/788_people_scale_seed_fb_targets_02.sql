BEGIN;

WITH selected_leagues AS (
    SELECT *
    FROM (VALUES
        (20859, 'api_football', 'FB', '140', '2024', 'La Liga Spain'),
        (20852, 'api_football', 'FB', '61',  '2024', 'Ligue 1 France'),
        (20851, 'api_football', 'FB', '62',  '2024', 'Ligue 2 France'),
        (20849, 'api_football', 'FB', '88',  '2024', 'Eredivisie Netherlands'),
        (20853, 'api_football', 'FB', '144', '2024', 'Belgium Pro League'),
        (20963, 'api_football', 'FB', '79',  '2024', '2. Bundesliga Germany'),
        (20856, 'api_football', 'FB', '78',  '2024', 'Bundesliga Germany'),
        (20858, 'api_football', 'FB', '94',  '2024', 'Primeira Liga Portugal'),
        (21110, 'api_football', 'FB', '283', '2024', 'Liga I Romania'),
        (20949, 'api_football', 'FB', '272', '2024', 'NB II Hungary')
    ) AS x(canonical_league_id, provider, sport_code, provider_league_id, season, label)
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
    run_group,
    created_at,
    updated_at
)
SELECT
    sport_code,
    canonical_league_id,
    provider,
    provider_league_id,
    season,
    true,
    2,
    0,
    0,
    0,
    3,
    'PEOPLE SCALE FB batch 2: ' || label,
    'FB_PEOPLE_SCALE_02',
    now(),
    now()
FROM selected_leagues
ON CONFLICT (provider, provider_league_id, season)
DO UPDATE SET
    enabled = true,
    run_group = 'FB_PEOPLE_SCALE_02',
    updated_at = now();

COMMIT;