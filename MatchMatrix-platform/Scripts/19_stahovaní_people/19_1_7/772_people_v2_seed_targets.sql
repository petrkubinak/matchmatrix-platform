BEGIN;

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
VALUES
    (
        'FB',
        20855,
        'api_football',
        '39',
        '2024',
        true,
        1,
        0,
        0,
        0,
        5,
        'PEOPLE V2 target: FB players/coaches Premier League. league=39 season=2024.',
        'FB_PEOPLE_V2',
        now(),
        now()
    ),
    (
        'AFB',
        24867,
        'api_american_football',
        '1',
        '2024',
        true,
        1,
        0,
        0,
        0,
        5,
        'PEOPLE V2 target: AFB players NFL. team/provider scope=1 season=2024.',
        'AFB_PEOPLE_V2',
        now(),
        now()
    )
ON CONFLICT (provider, provider_league_id, season)
DO UPDATE SET
    enabled = EXCLUDED.enabled,
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
    enabled,
    tier,
    max_requests_per_run,
    run_group,
    notes
FROM ops.ingest_targets
WHERE run_group IN ('FB_PEOPLE_V2', 'AFB_PEOPLE_V2')
ORDER BY provider, sport_code, provider_league_id, season;