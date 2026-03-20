ROLLBACK;
BEGIN;

-- =========================================================
-- 106_create_ops_sport_dimension_rules.sql
-- Logická pravidla sportů pro multisport planner
-- =========================================================

CREATE TABLE IF NOT EXISTS ops.sport_dimension_rules (
    id                          BIGSERIAL PRIMARY KEY,
    sport_code                  TEXT NOT NULL,
    uses_teams                  BOOLEAN NOT NULL DEFAULT TRUE,
    uses_players                BOOLEAN NOT NULL DEFAULT TRUE,
    uses_coaches                BOOLEAN NOT NULL DEFAULT FALSE,
    uses_seasons                BOOLEAN NOT NULL DEFAULT TRUE,
    uses_rounds                 BOOLEAN NOT NULL DEFAULT TRUE,
    uses_rankings               BOOLEAN NOT NULL DEFAULT FALSE,
    uses_surfaces               BOOLEAN NOT NULL DEFAULT FALSE,
    uses_weight_classes         BOOLEAN NOT NULL DEFAULT FALSE,
    uses_sets                   BOOLEAN NOT NULL DEFAULT FALSE,
    uses_legs                   BOOLEAN NOT NULL DEFAULT FALSE,
    match_side_1_label          TEXT NOT NULL DEFAULT 'home',
    match_side_2_label          TEXT NOT NULL DEFAULT 'away',
    entity_model                TEXT NOT NULL DEFAULT 'team_vs_team',
    notes                       TEXT,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_ops_sport_dimension_rules UNIQUE (sport_code),
    CONSTRAINT fk_ops_sport_dimension_rules_sport
        FOREIGN KEY (sport_code) REFERENCES public.sports(code)
);

CREATE INDEX IF NOT EXISTS idx_ops_sport_dimension_rules_sport
    ON ops.sport_dimension_rules (sport_code);

INSERT INTO ops.sport_dimension_rules (
    sport_code, uses_teams, uses_players, uses_coaches, uses_seasons, uses_rounds,
    uses_rankings, uses_surfaces, uses_weight_classes, uses_sets, uses_legs,
    match_side_1_label, match_side_2_label, entity_model, notes
)
VALUES
    ('FB',  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',      'away',      'team_vs_team',              'Football'),
    ('HK',  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',      'away',      'team_vs_team',              'Hockey'),
    ('BK',  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',      'away',      'team_vs_team',              'Basketball'),
    ('VB',  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, TRUE,  FALSE, 'home',      'away',      'team_vs_team',              'Volleyball uses sets'),
    ('HB',  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',      'away',      'team_vs_team',              'Handball'),
    ('BSB', TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',      'away',      'team_vs_team',              'Baseball'),
    ('RGB', TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',      'away',      'team_vs_team',              'Rugby'),
    ('CK',  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',      'away',      'team_vs_team',              'Cricket'),
    ('FH',  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',      'away',      'team_vs_team',              'Field hockey'),
    ('AFB', TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',      'away',      'team_vs_team',              'American football'),

    ('TN',  FALSE, TRUE,  FALSE, TRUE,  TRUE,  TRUE,  TRUE,  FALSE, TRUE,  FALSE, 'player_1',  'player_2',  'player_vs_player',          'Tennis: surface + rankings + singles/doubles context'),
    ('MMA', FALSE, TRUE,  FALSE, FALSE, TRUE,  TRUE,  FALSE, TRUE,  FALSE, FALSE, 'fighter_1', 'fighter_2', 'fighter_vs_fighter',        'MMA: weight classes + event bouts'),
    ('DRT', FALSE, TRUE,  FALSE, FALSE, TRUE,  TRUE,  FALSE, FALSE, FALSE, TRUE,  'player_1',  'player_2',  'player_vs_player',          'Darts: legs/sets + rankings'),
    ('ESP', FALSE, TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, 'side_1',    'side_2',    'participant_vs_participant','Esports can be team or player based')

ON CONFLICT (sport_code) DO UPDATE
SET
    uses_teams          = EXCLUDED.uses_teams,
    uses_players        = EXCLUDED.uses_players,
    uses_coaches        = EXCLUDED.uses_coaches,
    uses_seasons        = EXCLUDED.uses_seasons,
    uses_rounds         = EXCLUDED.uses_rounds,
    uses_rankings       = EXCLUDED.uses_rankings,
    uses_surfaces       = EXCLUDED.uses_surfaces,
    uses_weight_classes = EXCLUDED.uses_weight_classes,
    uses_sets           = EXCLUDED.uses_sets,
    uses_legs           = EXCLUDED.uses_legs,
    match_side_1_label  = EXCLUDED.match_side_1_label,
    match_side_2_label  = EXCLUDED.match_side_2_label,
    entity_model        = EXCLUDED.entity_model,
    notes               = EXCLUDED.notes,
    updated_at          = NOW();

COMMIT;