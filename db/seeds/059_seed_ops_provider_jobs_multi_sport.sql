INSERT INTO ops.provider_jobs (
    provider,
    sport_code,
    job_code,
    endpoint_code,
    ingest_mode,
    enabled,
    priority,
    batch_size,
    max_requests_per_run,
    retry_limit,
    cooldown_seconds,
    days_back,
    days_forward,
    notes
)
VALUES

-- ============================================================
-- FOOTBALL
-- ============================================================
('api_sport', 'football', 'football_leagues',          'leagues',    'slow',   TRUE,  10, 100, 200, 3, 1, NULL, NULL, 'Football leagues'),
('api_sport', 'football', 'football_teams',            'teams',      'slow',   TRUE,  20, 100, 300, 3, 1, NULL, NULL, 'Football teams'),
('api_sport', 'football', 'football_players',          'players',    'slow',   FALSE, 30, 100, 300, 3, 1, NULL, NULL, 'Football players'),
('api_sport', 'football', 'football_seasons',          'seasons',    'slow',   TRUE,  40, 100, 100, 3, 1, NULL, NULL, 'Football seasons'),
('api_sport', 'football', 'football_fixtures_backfill','fixtures',   'medium', TRUE, 100, 100,1000, 3, 1, 365, 30,   'Football fixtures backfill'),
('api_sport', 'football', 'football_fixtures_daily',   'fixtures',   'medium', TRUE, 110, 100, 300, 3, 1,  14, 14,   'Football fixtures daily'),
('api_sport', 'football', 'football_standings',        'standings',  'medium', TRUE, 120, 100, 200, 3, 1, NULL, NULL, 'Football standings'),
('api_sport', 'football', 'football_injuries',         'injuries',   'medium', FALSE,130, 100, 200, 3, 1,   7, 14,   'Football injuries'),
('api_sport', 'football', 'football_lineups',          'lineups',    'medium', FALSE,140, 100, 200, 3, 1,   2,  2,   'Football lineups'),
('api_sport', 'football', 'football_odds_refresh',     'odds',       'fast',   FALSE,220, 100, 500, 3, 5,   0,  3,   'Football odds'),

-- ============================================================
-- HOCKEY
-- ============================================================
('api_sport', 'hockey',   'hockey_leagues',            'leagues',    'slow',   TRUE,  10, 100, 200, 3, 1, NULL, NULL, 'Hockey leagues'),
('api_sport', 'hockey',   'hockey_teams',              'teams',      'slow',   TRUE,  20, 100, 300, 3, 1, NULL, NULL, 'Hockey teams'),
('api_sport', 'hockey',   'hockey_players',            'players',    'slow',   FALSE, 30, 100, 300, 3, 1, NULL, NULL, 'Hockey players'),
('api_sport', 'hockey',   'hockey_seasons',            'seasons',    'slow',   TRUE,  40, 100, 100, 3, 1, NULL, NULL, 'Hockey seasons'),
('api_sport', 'hockey',   'hockey_fixtures_backfill',  'fixtures',   'medium', TRUE, 100, 100,1000, 3, 1, 365, 30,   'Hockey fixtures backfill'),
('api_sport', 'hockey',   'hockey_fixtures_daily',     'fixtures',   'medium', TRUE, 110, 100, 300, 3, 1,  14, 14,   'Hockey fixtures daily'),
('api_sport', 'hockey',   'hockey_standings',          'standings',  'medium', TRUE, 120, 100, 200, 3, 1, NULL, NULL, 'Hockey standings'),
('api_sport', 'hockey',   'hockey_lineups',            'lineups',    'medium', FALSE,140, 100, 200, 3, 1,   2,  2,   'Hockey lineups'),
('api_sport', 'hockey',   'hockey_odds_refresh',       'odds',       'fast',   FALSE,220, 100, 500, 3, 5,   0,  3,   'Hockey odds'),

-- ============================================================
-- BASKETBALL
-- ============================================================
('api_sport', 'basketball','basketball_leagues',       'leagues',    'slow',   TRUE,  10, 100, 200, 3, 1, NULL, NULL, 'Basketball leagues'),
('api_sport', 'basketball','basketball_teams',         'teams',      'slow',   TRUE,  20, 100, 300, 3, 1, NULL, NULL, 'Basketball teams'),
('api_sport', 'basketball','basketball_players',       'players',    'slow',   FALSE, 30, 100, 300, 3, 1, NULL, NULL, 'Basketball players'),
('api_sport', 'basketball','basketball_seasons',       'seasons',    'slow',   TRUE,  40, 100, 100, 3, 1, NULL, NULL, 'Basketball seasons'),
('api_sport', 'basketball','basketball_fixtures_backfill','fixtures','medium', TRUE, 100, 100,1000, 3, 1, 365, 30,   'Basketball fixtures backfill'),
('api_sport', 'basketball','basketball_fixtures_daily','fixtures',   'medium', TRUE, 110, 100, 300, 3, 1,  14, 14,   'Basketball fixtures daily'),
('api_sport', 'basketball','basketball_standings',     'standings',  'medium', TRUE, 120, 100, 200, 3, 1, NULL, NULL, 'Basketball standings'),
('api_sport', 'basketball','basketball_odds_refresh',  'odds',       'fast',   FALSE,220, 100, 500, 3, 5,   0,  3,   'Basketball odds'),

-- ============================================================
-- TENNIS
-- ============================================================
('api_sport', 'tennis',   'tennis_tournaments',        'leagues',    'slow',   TRUE,  10, 100, 200, 3, 1, NULL, NULL, 'Tennis tournaments'),
('api_sport', 'tennis',   'tennis_players',            'players',    'slow',   TRUE,  20, 100, 300, 3, 1, NULL, NULL, 'Tennis players'),
('api_sport', 'tennis',   'tennis_seasons',            'seasons',    'slow',   TRUE,  30, 100, 100, 3, 1, NULL, NULL, 'Tennis seasons'),
('api_sport', 'tennis',   'tennis_fixtures_backfill',  'fixtures',   'medium', TRUE, 100, 100,1000, 3, 1, 365, 30,   'Tennis fixtures backfill'),
('api_sport', 'tennis',   'tennis_fixtures_daily',     'fixtures',   'medium', TRUE, 110, 100, 300, 3, 1,  14, 14,   'Tennis fixtures daily'),
('api_sport', 'tennis',   'tennis_rankings',           'rankings',   'medium', TRUE, 120, 100, 200, 3, 1, NULL, NULL, 'Tennis rankings'),
('api_sport', 'tennis',   'tennis_odds_refresh',       'odds',       'fast',   FALSE,220, 100, 500, 3, 5,   0,  3,   'Tennis odds'),

-- ============================================================
-- MMA
-- ============================================================
('api_sport', 'mma',      'mma_events',                'events',     'slow',   TRUE,  10, 100, 200, 3, 1, NULL, NULL, 'MMA events'),
('api_sport', 'mma',      'mma_fighters',              'players',    'slow',   TRUE,  20, 100, 300, 3, 1, NULL, NULL, 'MMA fighters'),
('api_sport', 'mma',      'mma_fixtures_backfill',     'fixtures',   'medium', TRUE, 100, 100,1000, 3, 1, 365, 30,   'MMA bouts backfill'),
('api_sport', 'mma',      'mma_fixtures_daily',        'fixtures',   'medium', TRUE, 110, 100, 300, 3, 1,  30, 30,   'MMA bouts daily'),
('api_sport', 'mma',      'mma_odds_refresh',          'odds',       'fast',   FALSE,220, 100, 500, 3, 5,   0,  7,   'MMA odds')

ON CONFLICT DO NOTHING;