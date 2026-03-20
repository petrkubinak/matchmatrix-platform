ROLLBACK;
BEGIN;

-- =========================================================
-- 107_create_ops_provider_sport_matrix.sql
-- Provider x sport capabilities
-- =========================================================

CREATE TABLE IF NOT EXISTS ops.provider_sport_matrix (
    id                      BIGSERIAL PRIMARY KEY,
    provider                TEXT NOT NULL,
    sport_code              TEXT NOT NULL,
    sport_name              TEXT,
    is_enabled              BOOLEAN NOT NULL DEFAULT TRUE,

    supports_leagues        BOOLEAN NOT NULL DEFAULT TRUE,
    supports_teams          BOOLEAN NOT NULL DEFAULT TRUE,
    supports_fixtures       BOOLEAN NOT NULL DEFAULT TRUE,
    supports_players        BOOLEAN NOT NULL DEFAULT FALSE,
    supports_player_stats   BOOLEAN NOT NULL DEFAULT FALSE,
    supports_odds           BOOLEAN NOT NULL DEFAULT FALSE,
    supports_coaches        BOOLEAN NOT NULL DEFAULT FALSE,
    supports_standings      BOOLEAN NOT NULL DEFAULT FALSE,

    notes                   TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_ops_provider_sport_matrix UNIQUE (provider, sport_code),
    CONSTRAINT fk_ops_provider_sport_matrix_sport
        FOREIGN KEY (sport_code) REFERENCES public.sports(code)
);

CREATE INDEX IF NOT EXISTS idx_ops_provider_sport_matrix_provider
    ON ops.provider_sport_matrix (provider);

CREATE INDEX IF NOT EXISTS idx_ops_provider_sport_matrix_sport
    ON ops.provider_sport_matrix (sport_code);

INSERT INTO ops.provider_sport_matrix (
    provider, sport_code, sport_name, is_enabled,
    supports_leagues, supports_teams, supports_fixtures,
    supports_players, supports_player_stats, supports_odds,
    supports_coaches, supports_standings, notes
)
VALUES
    ('api_football', 'FB',  'Football',          TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,  'Hlavní football provider'),
    ('api_hockey',   'HK',  'Hockey',            TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, 'Hockey provider'),
    ('api_basketball','BK', 'Basketball',        TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, 'Basketball provider'),
    ('api_tennis',   'TN',  'Tennis',            TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, 'Tennis provider'),
    ('api_mma',      'MMA', 'MMA',               TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, 'MMA provider'),
    ('api_darts',    'DRT', 'Darts',             TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, 'Darts provider'),
    ('api_volleyball','VB', 'Volleyball',        TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, 'Volleyball provider'),
    ('api_handball', 'HB',  'Handball',          TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, 'Handball provider'),
    ('api_baseball', 'BSB', 'Baseball',          TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, 'Baseball provider'),
    ('api_rugby',    'RGB', 'Rugby',             TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, 'Rugby provider'),
    ('api_cricket',  'CK',  'Cricket',           TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, 'Cricket provider'),
    ('api_field_hockey','FH','Field Hockey',     TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, 'Field hockey provider'),
    ('api_american_football','AFB','American Football', TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, 'American football provider'),
    ('api_esports',  'ESP', 'Esports',           TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, 'Esports provider')

ON CONFLICT (provider, sport_code) DO UPDATE
SET
    sport_name            = EXCLUDED.sport_name,
    is_enabled            = EXCLUDED.is_enabled,
    supports_leagues      = EXCLUDED.supports_leagues,
    supports_teams        = EXCLUDED.supports_teams,
    supports_fixtures     = EXCLUDED.supports_fixtures,
    supports_players      = EXCLUDED.supports_players,
    supports_player_stats = EXCLUDED.supports_player_stats,
    supports_odds         = EXCLUDED.supports_odds,
    supports_coaches      = EXCLUDED.supports_coaches,
    supports_standings    = EXCLUDED.supports_standings,
    notes                 = EXCLUDED.notes,
    updated_at            = NOW();

COMMIT;