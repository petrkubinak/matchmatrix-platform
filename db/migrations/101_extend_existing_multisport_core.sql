ROLLBACK;
BEGIN;

-- =========================================================
-- 101_extend_existing_multisport_core.sql
-- Rozšíření EXISTUJÍCÍHO multisport základu
-- Nic nevytváří znovu, jen doplňuje co chybí
-- =========================================================

-- ---------------------------------------------------------
-- 1) public.sports - rozšíření existující tabulky
-- ---------------------------------------------------------
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = 'sports'
    ) THEN
        ALTER TABLE public.sports
            ADD COLUMN IF NOT EXISTS sport_key TEXT,
            ADD COLUMN IF NOT EXISTS is_team_sport BOOLEAN NOT NULL DEFAULT TRUE,
            ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE,
            ADD COLUMN IF NOT EXISTS sort_order INTEGER NOT NULL DEFAULT 100;
    ELSE
        RAISE EXCEPTION 'Tabulka public.sports neexistuje. Nejdřív pošli její strukturu nebo export.';
    END IF;
END $$;

-- Doplnění sport_key podle code jen tam, kde chybí
UPDATE public.sports
SET sport_key = CASE UPPER(code)
    WHEN 'FB'  THEN 'football'
    WHEN 'HK'  THEN 'hockey'
    WHEN 'BK'  THEN 'basketball'
    WHEN 'TN'  THEN 'tennis'
    WHEN 'MMA' THEN 'mma'
    WHEN 'DRT' THEN 'darts'
    WHEN 'VB'  THEN 'volleyball'
    WHEN 'HB'  THEN 'handball'
    WHEN 'BSB' THEN 'baseball'
    WHEN 'RGB' THEN 'rugby'
    WHEN 'CK'  THEN 'cricket'
    WHEN 'FH'  THEN 'field_hockey'
    WHEN 'AFB' THEN 'american_football'
    WHEN 'ESP' THEN 'esports'
    ELSE LOWER(code)
END
WHERE sport_key IS NULL;

-- unique constraint na sport_key jen pokud ještě není
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'uq_sports_sport_key'
    ) THEN
        ALTER TABLE public.sports
        ADD CONSTRAINT uq_sports_sport_key UNIQUE (sport_key);
    END IF;
END $$;

-- ---------------------------------------------------------
-- 2) seed / update sportů do existující public.sports
-- ---------------------------------------------------------
INSERT INTO public.sports (code, sport_key, name, is_team_sport, is_active, sort_order)
VALUES
    ('FB',  'football',          'Football',            TRUE,  TRUE,  10),
    ('HK',  'hockey',            'Hockey',              TRUE,  TRUE,  20),
    ('BK',  'basketball',        'Basketball',          TRUE,  TRUE,  30),
    ('TN',  'tennis',            'Tennis',              FALSE, TRUE,  40),
    ('MMA', 'mma',               'MMA',                 FALSE, TRUE,  50),
    ('DRT', 'darts',             'Darts',               FALSE, TRUE,  60),
    ('VB',  'volleyball',        'Volleyball',          TRUE,  TRUE,  70),
    ('HB',  'handball',          'Handball',            TRUE,  TRUE,  80),
    ('BSB', 'baseball',          'Baseball',            TRUE,  TRUE,  90),
    ('RGB', 'rugby',             'Rugby',               TRUE,  TRUE,  100),
    ('CK',  'cricket',           'Cricket',             TRUE,  TRUE,  110),
    ('FH',  'field_hockey',      'Field Hockey',        TRUE,  TRUE,  120),
    ('AFB', 'american_football', 'American Football',   TRUE,  TRUE,  130),
    ('ESP', 'esports',           'Esports',             FALSE, TRUE,  140)
ON CONFLICT (code) DO UPDATE
SET
    sport_key      = EXCLUDED.sport_key,
    name           = EXCLUDED.name,
    is_team_sport  = EXCLUDED.is_team_sport,
    is_active      = EXCLUDED.is_active,
    sort_order     = EXCLUDED.sort_order;

-- ---------------------------------------------------------
-- 3) ops.provider_sport_matrix - vytvořit jen pokud není
-- ---------------------------------------------------------
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
    CONSTRAINT uq_provider_sport_matrix UNIQUE (provider, sport_code),
    CONSTRAINT fk_provider_sport_matrix_sport
        FOREIGN KEY (sport_code) REFERENCES public.sports(code)
);

-- ---------------------------------------------------------
-- 4) ops.sport_dimension_rules - vytvořit jen pokud není
-- ---------------------------------------------------------
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
    CONSTRAINT uq_sport_dimension_rules UNIQUE (sport_code),
    CONSTRAINT fk_sport_dimension_rules_sport
        FOREIGN KEY (sport_code) REFERENCES public.sports(code)
);

INSERT INTO ops.sport_dimension_rules (
    sport_code, uses_teams, uses_players, uses_coaches, uses_seasons, uses_rounds,
    uses_rankings, uses_surfaces, uses_weight_classes, uses_sets, uses_legs,
    match_side_1_label, match_side_2_label, entity_model, notes
)
VALUES
    ('FB',  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',     'away',     'team_vs_team',             'Football'),
    ('HK',  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',     'away',     'team_vs_team',             'Hockey'),
    ('BK',  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',     'away',     'team_vs_team',             'Basketball'),
    ('VB',  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, TRUE,  FALSE, 'home',     'away',     'team_vs_team',             'Volleyball'),
    ('HB',  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',     'away',     'team_vs_team',             'Handball'),
    ('BSB', TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',     'away',     'team_vs_team',             'Baseball'),
    ('RGB', TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',     'away',     'team_vs_team',             'Rugby'),
    ('CK',  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',     'away',     'team_vs_team',             'Cricket'),
    ('FH',  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',     'away',     'team_vs_team',             'Field hockey'),
    ('AFB', TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, 'home',     'away',     'team_vs_team',             'American football'),
    ('TN',  FALSE, TRUE,  FALSE, TRUE,  TRUE,  TRUE,  TRUE,  FALSE, TRUE,  FALSE, 'player_1', 'player_2', 'player_vs_player',         'Tennis'),
    ('MMA', FALSE, TRUE,  FALSE, FALSE, TRUE,  TRUE,  FALSE, TRUE,  FALSE, FALSE, 'fighter_1','fighter_2','fighter_vs_fighter',       'MMA'),
    ('DRT', FALSE, TRUE,  FALSE, FALSE, TRUE,  TRUE,  FALSE, FALSE, FALSE, TRUE,  'player_1', 'player_2', 'player_vs_player',         'Darts'),
    ('ESP', FALSE, TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, 'side_1',   'side_2',   'participant_vs_participant','Esports')
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
    notes               = EXCLUDED.notes;

-- ---------------------------------------------------------
-- 5) společná trigger funkce jen pokud ji ještě nemáš
-- ---------------------------------------------------------
CREATE OR REPLACE FUNCTION public.set_updated_at_generic()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;

COMMIT;