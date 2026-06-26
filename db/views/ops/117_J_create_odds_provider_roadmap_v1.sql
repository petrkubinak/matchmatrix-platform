/*
===============================================================================
MATCHMATRIX SQL 117_J
ODDS PROVIDER ROADMAP V1

CO TO JE:
- Centrální roadmapa providerů pro Odds vrstvu.

K ČEMU TO JE:
- Eviduje dostupné providery.
- Rozlišuje free a paid varianty.
- Určuje priority implementace.
- Slouží jako plán pro PRO harvest.

KDE TO UVIDÍME:
- OPS Panel
- Odds Dashboard
- Harvest Dashboard
- Mission Control

JAK SE TO VYUŽIJE:
- plánování odds harvestu
- příprava providerů
- rozhodování o placených službách
- řízení rozvoje Odds vrstvy

VLIV NA HARVEST:
- Přímý
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.odds_provider_roadmap (
    id BIGSERIAL PRIMARY KEY,

    provider_code TEXT NOT NULL,
    provider_name TEXT NOT NULL,

    sport_code TEXT NOT NULL,

    free_available BOOLEAN DEFAULT FALSE,
    paid_available BOOLEAN DEFAULT TRUE,

    historical_odds BOOLEAN DEFAULT FALSE,
    live_odds BOOLEAN DEFAULT FALSE,
    pre_match_odds BOOLEAN DEFAULT FALSE,

    implementation_priority INTEGER DEFAULT 100,

    provider_status TEXT DEFAULT 'PLANNED',

    next_action TEXT,

    notes TEXT,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);