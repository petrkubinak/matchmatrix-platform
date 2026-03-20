ROLLBACK;
BEGIN;

-- =========================================================
-- 105_create_ops_sport_entity_rules.sql
-- OPS pravidla: které entity se stahují pro který sport
-- =========================================================

CREATE TABLE IF NOT EXISTS ops.sport_entity_rules (
    id                      BIGSERIAL PRIMARY KEY,
    sport_code              TEXT NOT NULL,
    entity                  TEXT NOT NULL,
    is_enabled              BOOLEAN NOT NULL DEFAULT TRUE,
    priority                INTEGER NOT NULL DEFAULT 100,
    default_run_group       TEXT,
    requires_season         BOOLEAN NOT NULL DEFAULT FALSE,
    requires_league         BOOLEAN NOT NULL DEFAULT FALSE,
    requires_team           BOOLEAN NOT NULL DEFAULT FALSE,
    requires_player         BOOLEAN NOT NULL DEFAULT FALSE,
    requires_match          BOOLEAN NOT NULL DEFAULT FALSE,
    source_endpoint         TEXT,
    parser_name             TEXT,
    merge_target            TEXT,
    notes                   TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_ops_sport_entity_rules UNIQUE (sport_code, entity),
    CONSTRAINT fk_ops_sport_entity_rules_sport
        FOREIGN KEY (sport_code) REFERENCES public.sports(code)
);

CREATE INDEX IF NOT EXISTS idx_ops_sport_entity_rules_sport
    ON ops.sport_entity_rules (sport_code);

CREATE INDEX IF NOT EXISTS idx_ops_sport_entity_rules_entity
    ON ops.sport_entity_rules (entity);

INSERT INTO ops.sport_entity_rules (
    sport_code, entity, is_enabled, priority, default_run_group,
    requires_season, requires_league, requires_team, requires_player, requires_match,
    source_endpoint, parser_name, merge_target, notes
)
VALUES
    ('FB',  'leagues',             TRUE,  10, 'core',     TRUE,  FALSE, FALSE, FALSE, FALSE, 'leagues',   'parse_leagues',              'public.leagues',                  'Football leagues'),
    ('FB',  'teams',               TRUE,  20, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'teams',     'parse_teams',                'public.teams',                    'Football teams'),
    ('FB',  'fixtures',            TRUE,  30, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'fixtures',  'parse_fixtures',             'public.matches',                  'Football fixtures'),
    ('FB',  'odds',                TRUE,  40, 'core',     TRUE,  TRUE,  FALSE, FALSE, TRUE,  'odds',      'parse_odds',                 'public.odds',                     'Football odds'),
    ('FB',  'players',             TRUE,  50, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'players',   'parse_players',              'public.players',                  'Football players'),
    ('FB',  'player_season_stats', TRUE,  60, 'extended', TRUE,  TRUE,  TRUE,  TRUE,  FALSE, 'players',   'parse_player_season_stats',  'public.player_season_statistics', 'Football season stats'),
    ('FB',  'coaches',             TRUE,  70, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'coaches',   'parse_coaches',              'public.coaches',                  'Football coaches'),

    ('HK',  'leagues',             TRUE,  10, 'core',     TRUE,  FALSE, FALSE, FALSE, FALSE, 'leagues',   'parse_leagues',              'public.leagues',                  'Hockey leagues'),
    ('HK',  'teams',               TRUE,  20, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'teams',     'parse_teams',                'public.teams',                    'Hockey teams'),
    ('HK',  'fixtures',            TRUE,  30, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'fixtures',  'parse_fixtures',             'public.matches',                  'Hockey fixtures'),
    ('HK',  'odds',                TRUE,  40, 'core',     TRUE,  TRUE,  FALSE, FALSE, TRUE,  'odds',      'parse_odds',                 'public.odds',                     'Hockey odds'),
    ('HK',  'players',             TRUE,  50, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'players',   'parse_players',              'public.players',                  'Hockey players'),
    ('HK',  'coaches',             TRUE,  70, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'coaches',   'parse_coaches',              'public.coaches',                  'Hockey coaches'),

    ('BK',  'leagues',             TRUE,  10, 'core',     TRUE,  FALSE, FALSE, FALSE, FALSE, 'leagues',   'parse_leagues',              'public.leagues',                  'Basketball leagues'),
    ('BK',  'teams',               TRUE,  20, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'teams',     'parse_teams',                'public.teams',                    'Basketball teams'),
    ('BK',  'fixtures',            TRUE,  30, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'fixtures',  'parse_fixtures',             'public.matches',                  'Basketball fixtures'),
    ('BK',  'odds',                TRUE,  40, 'core',     TRUE,  TRUE,  FALSE, FALSE, TRUE,  'odds',      'parse_odds',                 'public.odds',                     'Basketball odds'),
    ('BK',  'players',             TRUE,  50, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'players',   'parse_players',              'public.players',                  'Basketball players'),
    ('BK',  'coaches',             TRUE,  70, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'coaches',   'parse_coaches',              'public.coaches',                  'Basketball coaches'),

    ('TN',  'leagues',             TRUE,  10, 'core',     TRUE,  FALSE, FALSE, FALSE, FALSE, 'tournaments','parse_tournaments',         'public.leagues',                  'Tennis tournaments'),
    ('TN',  'fixtures',            TRUE,  20, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'fixtures',  'parse_tennis_matches',       'public.matches',                  'Tennis matches'),
    ('TN',  'players',             TRUE,  30, 'core',     FALSE, FALSE, FALSE, FALSE, FALSE, 'players',   'parse_players',              'public.players',                  'Tennis players'),
    ('TN',  'rankings',            TRUE,  40, 'extended', FALSE, FALSE, FALSE, TRUE,  FALSE, 'rankings',  'parse_tennis_rankings',      'analytics.rankings',              'Tennis rankings'),
    ('TN',  'odds',                TRUE,  50, 'core',     FALSE, FALSE, FALSE, FALSE, TRUE,  'odds',      'parse_odds',                 'public.odds',                     'Tennis odds'),

    ('MMA', 'leagues',             TRUE,  10, 'core',     FALSE, FALSE, FALSE, FALSE, FALSE, 'events',    'parse_mma_events',           'public.leagues',                  'MMA events/promotions'),
    ('MMA', 'fixtures',            TRUE,  20, 'core',     FALSE, TRUE,  FALSE, FALSE, FALSE, 'bouts',     'parse_mma_bouts',            'public.matches',                  'MMA bouts'),
    ('MMA', 'players',             TRUE,  30, 'core',     FALSE, FALSE, FALSE, FALSE, FALSE, 'fighters',  'parse_mma_fighters',         'public.players',                  'MMA fighters'),
    ('MMA', 'rankings',            TRUE,  40, 'extended', FALSE, FALSE, FALSE, TRUE,  FALSE, 'rankings',  'parse_mma_rankings',         'analytics.rankings',              'MMA rankings'),
    ('MMA', 'odds',                TRUE,  50, 'core',     FALSE, FALSE, FALSE, FALSE, TRUE,  'odds',      'parse_odds',                 'public.odds',                     'MMA odds'),

    ('DRT', 'leagues',             TRUE,  10, 'core',     FALSE, FALSE, FALSE, FALSE, FALSE, 'tournaments','parse_darts_tournaments',   'public.leagues',                  'Darts tournaments'),
    ('DRT', 'fixtures',            TRUE,  20, 'core',     FALSE, TRUE,  FALSE, FALSE, FALSE, 'fixtures',  'parse_darts_matches',        'public.matches',                  'Darts matches'),
    ('DRT', 'players',             TRUE,  30, 'core',     FALSE, FALSE, FALSE, FALSE, FALSE, 'players',   'parse_players',              'public.players',                  'Darts players'),
    ('DRT', 'rankings',            TRUE,  40, 'extended', FALSE, FALSE, FALSE, TRUE,  FALSE, 'rankings',  'parse_darts_rankings',       'analytics.rankings',              'Darts rankings'),
    ('DRT', 'odds',                TRUE,  50, 'core',     FALSE, FALSE, FALSE, FALSE, TRUE,  'odds',      'parse_odds',                 'public.odds',                     'Darts odds')

ON CONFLICT (sport_code, entity) DO UPDATE
SET
    is_enabled        = EXCLUDED.is_enabled,
    priority          = EXCLUDED.priority,
    default_run_group = EXCLUDED.default_run_group,
    requires_season   = EXCLUDED.requires_season,
    requires_league   = EXCLUDED.requires_league,
    requires_team     = EXCLUDED.requires_team,
    requires_player   = EXCLUDED.requires_player,
    requires_match    = EXCLUDED.requires_match,
    source_endpoint   = EXCLUDED.source_endpoint,
    parser_name       = EXCLUDED.parser_name,
    merge_target      = EXCLUDED.merge_target,
    notes             = EXCLUDED.notes,
    updated_at        = NOW();

COMMIT;