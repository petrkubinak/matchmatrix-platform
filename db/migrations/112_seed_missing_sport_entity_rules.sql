ROLLBACK;
BEGIN;

-- =========================================================
-- 112_seed_missing_sport_entity_rules.sql
-- Doplnění chybějících sportů do ops.sport_entity_rules
-- =========================================================

INSERT INTO ops.sport_entity_rules (
    sport_code, entity, is_enabled, priority, default_run_group,
    requires_season, requires_league, requires_team, requires_player, requires_match,
    source_endpoint, parser_name, merge_target, notes
)
VALUES
    -- Volleyball
    ('VB',  'leagues',   TRUE, 10, 'core',     TRUE,  FALSE, FALSE, FALSE, FALSE, 'leagues',  'parse_leagues',   'public.leagues', 'Volleyball leagues'),
    ('VB',  'teams',     TRUE, 20, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'teams',    'parse_teams',     'public.teams',   'Volleyball teams'),
    ('VB',  'fixtures',  TRUE, 30, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'fixtures', 'parse_fixtures',  'public.matches', 'Volleyball fixtures'),
    ('VB',  'odds',      TRUE, 40, 'core',     TRUE,  TRUE,  FALSE, FALSE, TRUE,  'odds',     'parse_odds',      'public.odds',    'Volleyball odds'),
    ('VB',  'players',   TRUE, 50, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'players',  'parse_players',   'public.players', 'Volleyball players'),
    ('VB',  'coaches',   TRUE, 70, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'coaches',  'parse_coaches',   'public.coaches', 'Volleyball coaches'),

    -- Handball
    ('HB',  'leagues',   TRUE, 10, 'core',     TRUE,  FALSE, FALSE, FALSE, FALSE, 'leagues',  'parse_leagues',   'public.leagues', 'Handball leagues'),
    ('HB',  'teams',     TRUE, 20, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'teams',    'parse_teams',     'public.teams',   'Handball teams'),
    ('HB',  'fixtures',  TRUE, 30, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'fixtures', 'parse_fixtures',  'public.matches', 'Handball fixtures'),
    ('HB',  'odds',      TRUE, 40, 'core',     TRUE,  TRUE,  FALSE, FALSE, TRUE,  'odds',     'parse_odds',      'public.odds',    'Handball odds'),
    ('HB',  'players',   TRUE, 50, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'players',  'parse_players',   'public.players', 'Handball players'),
    ('HB',  'coaches',   TRUE, 70, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'coaches',  'parse_coaches',   'public.coaches', 'Handball coaches'),

    -- Baseball
    ('BSB', 'leagues',   TRUE, 10, 'core',     TRUE,  FALSE, FALSE, FALSE, FALSE, 'leagues',  'parse_leagues',   'public.leagues', 'Baseball leagues'),
    ('BSB', 'teams',     TRUE, 20, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'teams',    'parse_teams',     'public.teams',   'Baseball teams'),
    ('BSB', 'fixtures',  TRUE, 30, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'fixtures', 'parse_fixtures',  'public.matches', 'Baseball fixtures'),
    ('BSB', 'odds',      TRUE, 40, 'core',     TRUE,  TRUE,  FALSE, FALSE, TRUE,  'odds',     'parse_odds',      'public.odds',    'Baseball odds'),
    ('BSB', 'players',   TRUE, 50, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'players',  'parse_players',   'public.players', 'Baseball players'),
    ('BSB', 'coaches',   TRUE, 70, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'coaches',  'parse_coaches',   'public.coaches', 'Baseball coaches'),

    -- Rugby
    ('RGB', 'leagues',   TRUE, 10, 'core',     TRUE,  FALSE, FALSE, FALSE, FALSE, 'leagues',  'parse_leagues',   'public.leagues', 'Rugby leagues'),
    ('RGB', 'teams',     TRUE, 20, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'teams',    'parse_teams',     'public.teams',   'Rugby teams'),
    ('RGB', 'fixtures',  TRUE, 30, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'fixtures', 'parse_fixtures',  'public.matches', 'Rugby fixtures'),
    ('RGB', 'odds',      TRUE, 40, 'core',     TRUE,  TRUE,  FALSE, FALSE, TRUE,  'odds',     'parse_odds',      'public.odds',    'Rugby odds'),
    ('RGB', 'players',   TRUE, 50, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'players',  'parse_players',   'public.players', 'Rugby players'),
    ('RGB', 'coaches',   TRUE, 70, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'coaches',  'parse_coaches',   'public.coaches', 'Rugby coaches'),

    -- Cricket
    ('CK',  'leagues',   TRUE, 10, 'core',     TRUE,  FALSE, FALSE, FALSE, FALSE, 'leagues',  'parse_leagues',   'public.leagues', 'Cricket leagues'),
    ('CK',  'teams',     TRUE, 20, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'teams',    'parse_teams',     'public.teams',   'Cricket teams'),
    ('CK',  'fixtures',  TRUE, 30, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'fixtures', 'parse_fixtures',  'public.matches', 'Cricket fixtures'),
    ('CK',  'odds',      TRUE, 40, 'core',     TRUE,  TRUE,  FALSE, FALSE, TRUE,  'odds',     'parse_odds',      'public.odds',    'Cricket odds'),
    ('CK',  'players',   TRUE, 50, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'players',  'parse_players',   'public.players', 'Cricket players'),
    ('CK',  'coaches',   TRUE, 70, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'coaches',  'parse_coaches',   'public.coaches', 'Cricket coaches'),

    -- Field Hockey
    ('FH',  'leagues',   TRUE, 10, 'core',     TRUE,  FALSE, FALSE, FALSE, FALSE, 'leagues',  'parse_leagues',   'public.leagues', 'Field hockey leagues'),
    ('FH',  'teams',     TRUE, 20, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'teams',    'parse_teams',     'public.teams',   'Field hockey teams'),
    ('FH',  'fixtures',  TRUE, 30, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'fixtures', 'parse_fixtures',  'public.matches', 'Field hockey fixtures'),
    ('FH',  'odds',      TRUE, 40, 'core',     TRUE,  TRUE,  FALSE, FALSE, TRUE,  'odds',     'parse_odds',      'public.odds',    'Field hockey odds'),
    ('FH',  'players',   TRUE, 50, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'players',  'parse_players',   'public.players', 'Field hockey players'),
    ('FH',  'coaches',   TRUE, 70, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'coaches',  'parse_coaches',   'public.coaches', 'Field hockey coaches'),

    -- American Football
    ('AFB', 'leagues',   TRUE, 10, 'core',     TRUE,  FALSE, FALSE, FALSE, FALSE, 'leagues',  'parse_leagues',   'public.leagues', 'American football leagues'),
    ('AFB', 'teams',     TRUE, 20, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'teams',    'parse_teams',     'public.teams',   'American football teams'),
    ('AFB', 'fixtures',  TRUE, 30, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'fixtures', 'parse_fixtures',  'public.matches', 'American football fixtures'),
    ('AFB', 'odds',      TRUE, 40, 'core',     TRUE,  TRUE,  FALSE, FALSE, TRUE,  'odds',     'parse_odds',      'public.odds',    'American football odds'),
    ('AFB', 'players',   TRUE, 50, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'players',  'parse_players',   'public.players', 'American football players'),
    ('AFB', 'coaches',   TRUE, 70, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'coaches',  'parse_coaches',   'public.coaches', 'American football coaches'),

    -- Esports
    ('ESP', 'leagues',   TRUE, 10, 'core',     TRUE,  FALSE, FALSE, FALSE, FALSE, 'leagues',  'parse_leagues',   'public.leagues', 'Esports leagues'),
    ('ESP', 'fixtures',  TRUE, 20, 'core',     TRUE,  TRUE,  FALSE, FALSE, FALSE, 'fixtures', 'parse_fixtures',  'public.matches', 'Esports fixtures'),
    ('ESP', 'players',   TRUE, 30, 'core',     FALSE, FALSE, FALSE, FALSE, FALSE, 'players',  'parse_players',   'public.players', 'Esports players'),
    ('ESP', 'coaches',   TRUE, 40, 'extended', TRUE,  TRUE,  TRUE,  FALSE, FALSE, 'coaches',  'parse_coaches',   'public.coaches', 'Esports coaches'),
    ('ESP', 'odds',      TRUE, 50, 'core',     FALSE, FALSE, FALSE, FALSE, TRUE,  'odds',     'parse_odds',      'public.odds',    'Esports odds')

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