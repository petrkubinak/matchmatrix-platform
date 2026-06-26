/*
===============================================================================
MATCHMATRIX SQL 24_1_A_10
HB SOURCE COMMERCIAL MODEL V1
===============================================================================

VRSTVA:
24_SOURCE INTELLIGENCE LAYER

OBLAST:
24_4_SOURCE BUSINESS INTELLIGENCE

SPORT:
HB - HANDBALL

VERZE:
V1

===============================================================================
CO TO JE:
===============================================================================

- Evidence obchodních parametrů zdrojů.
- Evidence free a placených zdrojů.
- Evidence tarifů, cen, limitů a ROI.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Aby bylo možné rozhodovat o nákupu providerů.
- Aby bylo možné porovnávat zdroje.
- Aby bylo možné plánovat rozpočet MatchMatrix.
- Aby bylo možné sledovat návratnost investic.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_commercial_model
- SOURCE BUSINESS INTELLIGENCE
- SOURCE COMMAND CENTER
- OPS Panel

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Porovnání providerů.
- Výběr optimálního tarifu.
- Evidence cen a limitů.
- Evidence doporučeného plánu.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vytváří tabulku obchodních parametrů zdrojů.
- Zakládá první záznamy pro HB.
- Připravuje podklad pro budoucí nákup providerů.

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
'Source Business Intelligence - ceny, tarify, limity a ROI zdrojů.';


INSERT INTO ops.source_commercial_model
(
    sport_code,
    source_name,
    pricing_model,
    free_available,
    paid_available,
    trial_available,
    historical_access,
    current_status,
    notes
)
VALUES

(
    'HB',
    'European Handball Federation',
    'FREE_SOURCE',
    TRUE,
    FALSE,
    FALSE,
    TRUE,
    'RESEARCH_REQUIRED',
    'Nutné ověřit licenci a rozsah dat.'
),

(
    'HB',
    'International Handball Federation',
    'FREE_SOURCE',
    TRUE,
    FALSE,
    FALSE,
    TRUE,
    'RESEARCH_REQUIRED',
    'Nutné ověřit licenci a rozsah dat.'
),

(
    'HB',
    'Official League Websites',
    'MIXED',
    TRUE,
    FALSE,
    FALSE,
    TRUE,
    'RESEARCH_REQUIRED',
    'Každá liga může mít jiné podmínky.'
),

(
    'HB',
    'Official Club Websites',
    'MIXED',
    TRUE,
    FALSE,
    FALSE,
    TRUE,
    'RESEARCH_REQUIRED',
    'Každý klub může mít jiné podmínky.'
),

(
    'HB',
    'Wikimedia Commons',
    'FREE_SOURCE',
    TRUE,
    FALSE,
    FALSE,
    TRUE,
    'RESEARCH_REQUIRED',
    'Nutné sledovat licenci jednotlivých souborů.'
),

(
    'HB',
    'Wikidata',
    'FREE_SOURCE',
    TRUE,
    FALSE,
    FALSE,
    TRUE,
    'RESEARCH_REQUIRED',
    'Vhodné pro identity a knowledge graph.'
);

SELECT
    source_name,
    pricing_model,
    free_available,
    paid_available,
    historical_access,
    current_status
FROM ops.source_commercial_model
WHERE sport_code = 'HB'
ORDER BY source_name;