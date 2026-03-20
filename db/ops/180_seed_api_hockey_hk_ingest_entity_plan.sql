-- ============================================
-- MATCHMATRIX - HK ingest_entity_plan FIX
-- ============================================

INSERT INTO ops.ingest_entity_plan
(
    provider,
    sport_code,
    entity,
    enabled,
    priority,
    scope_type,
    requires_league,
    requires_season,
    source_endpoint,
    target_table,
    worker_script,
    notes
)
VALUES
-- leagues
(
    'api_hockey',
    'HK',
    'leagues',
    true,
    10,
    'league',
    false,
    false,
    'leagues',
    'staging.stg_provider_leagues',
    NULL,
    'HK base entity - leagues'
),

-- teams
(
    'api_hockey',
    'HK',
    'teams',
    true,
    20,
    'league_season',
    true,
    true,
    'teams',
    'staging.stg_provider_teams',
    NULL,
    'HK base entity - teams'
),

-- fixtures
(
    'api_hockey',
    'HK',
    'fixtures',
    true,
    30,
    'league_season',
    true,
    true,
    'fixtures',
    'staging.stg_provider_fixtures',
    NULL,
    'HK base entity - fixtures'
),

-- players
(
    'api_hockey',
    'HK',
    'players',
    true,
    40,
    'league_season',
    true,
    true,
    'players',
    'staging.stg_provider_players',
    NULL,
    'HK expansion entity - players'
),

-- coaches
(
    'api_hockey',
    'HK',
    'coaches',
    true,
    50,
    'league_season',
    false,
    true,
    'coaches',
    'staging.stg_provider_coaches',
    NULL,
    'HK expansion entity - coaches'
)

ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    enabled         = EXCLUDED.enabled,
    priority        = EXCLUDED.priority,
    scope_type      = EXCLUDED.scope_type,
    requires_league = EXCLUDED.requires_league,
    requires_season = EXCLUDED.requires_season,
    source_endpoint = EXCLUDED.source_endpoint,
    target_table    = EXCLUDED.target_table,
    worker_script   = EXCLUDED.worker_script,
    notes           = EXCLUDED.notes;

-- kontrola
SELECT
    provider,
    sport_code,
    entity,
    enabled,
    priority,
    scope_type,
    requires_league,
    requires_season,
    source_endpoint
FROM ops.ingest_entity_plan
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
ORDER BY priority, entity;