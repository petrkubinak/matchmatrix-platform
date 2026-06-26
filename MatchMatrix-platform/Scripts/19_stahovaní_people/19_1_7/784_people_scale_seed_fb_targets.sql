BEGIN;

WITH selected_leagues AS (
    SELECT *
    FROM (VALUES
        (20894, 'api_football', 'FB', '205', '2024', '2. Lig Turkey'),
        (20871, 'api_football', 'FB', '40',  '2024', 'Championship England'),
        (20876, 'api_football', 'FB', '41',  '2024', 'League One England'),
        (20877, 'api_football', 'FB', '42',  '2024', 'League Two England'),
        (21246, 'api_football', 'FB', '111', '2024', 'FAW Championship Wales'),
        (21062, 'api_football', 'FB', '141', '2024', 'Segunda Division Spain'),
        (21063, 'api_football', 'FB', '136', '2024', 'Serie B Italy'),
        (20857, 'api_football', 'FB', '135', '2024', 'Serie A Italy'),
        (20964, 'api_football', 'FB', '80',  '2024', '3. Liga Germany'),
        (21065, 'api_football', 'FB', '89',  '2024', 'Eerste Divisie Netherlands')
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
    'PEOPLE SCALE FB batch 1: ' || label,
    'FB_PEOPLE_SCALE_01',
    now(),
    now()
FROM selected_leagues
ON CONFLICT (provider, provider_league_id, season)
DO UPDATE SET
    enabled = true,
    tier = EXCLUDED.tier,
    max_requests_per_run = EXCLUDED.max_requests_per_run,
    notes = EXCLUDED.notes,
    run_group = EXCLUDED.run_group,
    updated_at = now();

COMMIT;

SELECT
    id,
    provider,
    sport_code,
    canonical_league_id,
    provider_league_id,
    season,
    run_group,
    enabled,
    tier,
    max_requests_per_run,
    notes
FROM ops.ingest_targets
WHERE run_group = 'FB_PEOPLE_SCALE_01'
ORDER BY provider_league_id::int;