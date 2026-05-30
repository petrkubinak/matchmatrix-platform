/*
===============================================================================
MATCHMATRIX 105_A - TEAM POWER MODEL NOTES V1
===============================================================================

Co model dělá:
- definuje architekturu TEAM POWER ENGINE

K čemu bude sloužit:
- AI prediction layer
- match previews
- power rankings
- fantasy
- betting insights
- team analytics

Web/app využití:
- TEAM FORM
- POWER SCORE
- MATCH ADVANTAGE
- TEAM MOMENTUM
- INJURY IMPACT
- COACH IMPACT
===============================================================================
*/


CREATE TABLE IF NOT EXISTS public.team_power_model_notes (
    id BIGSERIAL PRIMARY KEY,

    model_area TEXT NOT NULL,
    model_component TEXT NOT NULL,

    description TEXT,

    importance_weight NUMERIC,

    current_status TEXT,

    future_plan TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


/*
===============================================================================
INSERT BASE COMPONENTS
===============================================================================
*/

INSERT INTO public.team_power_model_notes (
    model_area,
    model_component,
    description,
    importance_weight,
    current_status,
    future_plan
)
VALUES

-- ---------------------------------------------------------------------------
-- TEAM RESULTS
-- ---------------------------------------------------------------------------

(
    'TEAM_RESULTS',
    'team_form',
    'Poslední výsledky týmu, win streak, points trend.',
    10,
    'PLANNED',
    'Build rolling form engine from public.matches.'
),

(
    'TEAM_RESULTS',
    'home_away_strength',
    'Domácí a venkovní síla týmu.',
    8,
    'PLANNED',
    'Build split home/away analytics.'
),

(
    'TEAM_RESULTS',
    'goal_difference_form',
    'Recent goal difference trend.',
    7,
    'PLANNED',
    'Use rolling goal differential.'
),

-- ---------------------------------------------------------------------------
-- PLAYER LAYER
-- ---------------------------------------------------------------------------

(
    'PLAYER_LAYER',
    'player_form',
    'Forma hráčů podle player_match_statistics.',
    10,
    'DONE',
    'Already implemented via player_form.'
),

(
    'PLAYER_LAYER',
    'key_player_impact',
    'Dopad klíčových hráčů na sílu týmu.',
    9,
    'PLANNED',
    'Build weighted player importance.'
),

(
    'PLAYER_LAYER',
    'squad_depth',
    'Kvalita lavičky a šířka kádru.',
    7,
    'PLANNED',
    'Build secondary lineup strength.'
),

(
    'PLAYER_LAYER',
    'missing_players',
    'Dopad chybějících hráčů.',
    10,
    'PLANNED',
    'Integrate injuries/suspensions.'
),

-- ---------------------------------------------------------------------------
-- COACH LAYER
-- ---------------------------------------------------------------------------

(
    'COACH_LAYER',
    'coach_experience',
    'Zkušenosti trenéra.',
    7,
    'PLANNED',
    'Build coach historical statistics.'
),

(
    'COACH_LAYER',
    'coach_win_rate',
    'Historická úspěšnost trenéra.',
    9,
    'PLANNED',
    'Compute coach win percentages.'
),

(
    'COACH_LAYER',
    'coach_titles',
    'Historické úspěchy a trofeje.',
    6,
    'PLANNED',
    'Add achievements/titles system.'
),

(
    'COACH_LAYER',
    'coach_vs_opponent',
    'Historický výkon trenéra proti soupeři.',
    7,
    'PLANNED',
    'Head-to-head coach analytics.'
),

-- ---------------------------------------------------------------------------
-- AVAILABILITY
-- ---------------------------------------------------------------------------

(
    'AVAILABILITY',
    'injuries',
    'Zranění hráčů.',
    10,
    'PLANNED',
    'Provider integration needed.'
),

(
    'AVAILABILITY',
    'suspensions',
    'Suspendovaní hráči.',
    9,
    'PLANNED',
    'Cards/discipline integration.'
),

(
    'AVAILABILITY',
    'rotation_risk',
    'Riziko rotace sestavy.',
    5,
    'PLANNED',
    'Schedule congestion model.'
),

-- ---------------------------------------------------------------------------
-- MEDIA / PUBLIC
-- ---------------------------------------------------------------------------

(
    'MEDIA_LAYER',
    'media_momentum',
    'Media hype a public momentum.',
    5,
    'PARTIAL',
    'media_trending_players already exists.'
),

(
    'MEDIA_LAYER',
    'fan_sentiment',
    'Sentiment fanoušků a veřejnosti.',
    4,
    'FUTURE',
    'Future NLP/social layer.'
),

-- ---------------------------------------------------------------------------
-- ODDS
-- ---------------------------------------------------------------------------

(
    'ODDS_LAYER',
    'odds_movement',
    'Pohyb kurzů.',
    8,
    'PLANNED',
    'Multi-provider odds analysis.'
),

(
    'ODDS_LAYER',
    'market_confidence',
    'Síla trhu / market confidence.',
    7,
    'PLANNED',
    'Advanced betting analytics.'
),

-- ---------------------------------------------------------------------------
-- FINAL AI
-- ---------------------------------------------------------------------------

(
    'AI_LAYER',
    'team_power_score',
    'Finální agregované skóre týmu.',
    10,
    'PLANNED',
    'Combine all model layers.'
),

(
    'AI_LAYER',
    'match_prediction',
    'AI predikce zápasu.',
    10,
    'PLANNED',
    'Prediction engine.'
),

(
    'AI_LAYER',
    'match_explanation',
    'AI vysvětlení proč má tým výhodu.',
    9,
    'PLANNED',
    'Explainable AI layer.'
);