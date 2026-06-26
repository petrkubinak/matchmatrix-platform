/*
===============================================================================
MATCHMATRIX SQL 24_1_B_3
SOURCE COMMERCIAL MODEL V1
===============================================================================

VRSTVA:
24_SOURCE INTELLIGENCE LAYER

OBLAST:
24_1_B_SOURCE GOVERNANCE LAYER

VERZE:
V1

===============================================================================
CO TO JE:
===============================================================================

- Centrální obchodní model datových zdrojů MatchMatrix.
- Evidence FREE / FREEMIUM / PAID / ENTERPRISE zdrojů.
- Evidence cen, limitů, historického přístupu a ROI.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Aby bylo možné rozhodnout, které zdroje používat hned.
- Aby bylo jasné, které zdroje aktivovat až po zaplacení.
- Aby bylo možné porovnat cenu proti datové hodnotě.
- Aby MatchMatrix věděl, co má největší přínos pro harvest.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_commercial_model
- SOURCE INTELLIGENCE DASHBOARD
- SOURCE COMMAND CENTER
- OPS PANEL
- budoucí Provider Purchase Planner

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- AI Orchestrator bude vědět, zda je zdroj zdarma nebo placený.
- Panel ukáže USE_NOW / USE_WHEN_PAID_ACTIVE / RESEARCH_REQUIRED.
- Pomůže rozhodnout, které placené providery koupit jako první.
- Bude podkladem pro PRO harvest.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vytvoří nebo rozšíří tabulku ops.source_commercial_model.
- Doplní obchodní stav EHF.
- Připraví strukturu pro další zdroje všech sportů.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.source_commercial_model
(
    commercial_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,
    source_name TEXT NOT NULL,

    pricing_model TEXT,

    free_available BOOLEAN DEFAULT FALSE,
    paid_available BOOLEAN DEFAULT FALSE,
    trial_available BOOLEAN DEFAULT FALSE,

    currency_code TEXT DEFAULT 'USD',

    monthly_price NUMERIC(12,2),
    annual_price NUMERIC(12,2),

    request_limit_day INTEGER,
    request_limit_month INTEGER,

    historical_access BOOLEAN DEFAULT FALSE,
    historical_from_year INTEGER,

    player_coverage_score NUMERIC(5,2),
    coach_coverage_score NUMERIC(5,2),
    photo_coverage_score NUMERIC(5,2),
    media_coverage_score NUMERIC(5,2),
    history_coverage_score NUMERIC(5,2),

    roi_score NUMERIC(5,2),

    recommended_plan TEXT,

    current_status TEXT DEFAULT 'RESEARCH_REQUIRED',

    notes TEXT,

    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_source_commercial_model_sport
ON ops.source_commercial_model (sport_code);

CREATE INDEX IF NOT EXISTS ix_source_commercial_model_source
ON ops.source_commercial_model (source_name);

COMMENT ON TABLE ops.source_commercial_model IS
'Source Business Intelligence - obchodní model, ceny, tarify, limity a ROI zdrojů.';


INSERT INTO ops.source_commercial_model
(
    sport_code,
    source_name,
    pricing_model,
    free_available,
    paid_available,
    trial_available,
    currency_code,
    historical_access,
    player_coverage_score,
    coach_coverage_score,
    photo_coverage_score,
    media_coverage_score,
    history_coverage_score,
    roi_score,
    recommended_plan,
    current_status,
    notes
)
SELECT
    'HB',
    'European Handball Federation',
    'FREE_SOURCE',
    TRUE,
    FALSE,
    FALSE,
    'EUR',
    TRUE,
    98,
    95,
    95,
    80,
    95,
    90,
    'USE_NOW_AFTER_LEGAL_REVIEW',
    'RESEARCH_REQUIRED',
    'EHF je výborný bezplatný zdroj pro evropskou házenou, People, Coaches, Staff, Photos, History a evropské soutěže. Terms a photo license ještě vyžadují review.'
WHERE NOT EXISTS
(
    SELECT 1
    FROM ops.source_commercial_model
    WHERE sport_code = 'HB'
      AND source_name = 'European Handball Federation'
);

SELECT
    sport_code,
    source_name,
    pricing_model,
    free_available,
    paid_available,
    historical_access,
    player_coverage_score,
    coach_coverage_score,
    photo_coverage_score,
    history_coverage_score,
    roi_score,
    recommended_plan,
    current_status
FROM ops.source_commercial_model
WHERE sport_code = 'HB'
ORDER BY source_name;