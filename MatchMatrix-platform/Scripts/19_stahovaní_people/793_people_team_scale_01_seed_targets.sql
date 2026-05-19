BEGIN;

WITH selected_teams AS (
    SELECT *
    FROM (VALUES
        ('api_football','FB','531','2024','Athletic Club'),
        ('api_football','FB','497','2024','AS Roma'),
        ('api_football','FB','489','2024','AC Milan'),
        ('api_football','FB','165','2024','Borussia Dortmund'),
        ('api_football','FB','169','2024','Eintracht Frankfurt'),
        ('api_football','FB','212','2024','FC Porto'),
        ('api_football','FB','170','2024','FC Augsburg'),
        ('api_football','FB','173','2024','RB Leipzig'),
        ('api_football','FB','160','2024','SC Freiburg'),
        ('api_football','FB','161','2024','VfL Wolfsburg'),
        ('api_football','FB','94','2024','Rennes'),
        ('api_football','FB','83','2024','Nantes'),
        ('api_football','FB','95','2024','Strasbourg'),
        ('api_football','FB','490','2024','Cagliari'),
        ('api_football','FB','53','2024','Reading'),
        ('api_football','FB','172','2024','VfB Stuttgart'),
        ('api_football','FB','93','2024','Reims'),
        ('api_football','FB','82','2024','Montpellier'),
        ('api_football','FB','77','2024','Angers'),
        ('api_football','FB','222','2024','Boavista')
    ) AS x(provider, sport_code, provider_team_id, season, team_name)
),
team_targets AS (
    SELECT
        st.*,
        tpm.team_id AS canonical_league_id
    FROM selected_teams st
    JOIN public.team_provider_map tpm
        ON tpm.provider = st.provider
       AND tpm.provider_team_id = st.provider_team_id
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
    provider_team_id,
    season,
    true,
    3,
    0,
    0,
    0,
    3,
    'PEOPLE TEAM SCALE 01: team=' || provider_team_id || ' | ' || team_name,
    'FB_PEOPLE_TEAM_SCALE_01',
    now(),
    now()
FROM team_targets
ON CONFLICT (provider, provider_league_id, season)
DO UPDATE SET
    enabled = true,
    tier = EXCLUDED.tier,
    notes = EXCLUDED.notes,
    run_group = EXCLUDED.run_group,
    updated_at = now();

COMMIT;

SELECT
    id,
    provider,
    sport_code,
    canonical_league_id,
    provider_league_id AS provider_team_id,
    season,
    run_group,
    enabled,
    notes
FROM ops.ingest_targets
WHERE run_group = 'FB_PEOPLE_TEAM_SCALE_01'
ORDER BY provider_league_id::int;