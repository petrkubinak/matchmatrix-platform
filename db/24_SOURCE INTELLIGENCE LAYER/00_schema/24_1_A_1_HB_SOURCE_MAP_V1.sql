/*
===============================================================================
MATCHMATRIX
===============================================================================

Skript:
24_1_A_1_HB_SOURCE_MAP_V1.sql

Vrstva:
24_SOURCE_INTELLIGENCE_LAYER

Oblast:
24_1_MASTER_SOURCE_MAP

Sport:
HB - Handball

Účel:
Založit první Master Source Map pro házenou.

Co skript dělá:
- vytvoří tabulku ops.source_intelligence_map
- připraví centrální evidenci zdrojů dat
- umožní sledovat odkud bereme hráče, trenéry, fotky, historii, média a statistiky

Výsledek:
Vznikne hlavní tabulka Source Intelligence Layer.

Budoucí využití:
- People Layer
- Coach Layer
- Media Layer
- Historical Layer
- Knowledge Graph
- AI predikce
- Harvest Command Center

Verze:
V1

===============================================================================
*/

CREATE SCHEMA IF NOT EXISTS ops;

CREATE TABLE IF NOT EXISTS ops.source_intelligence_map (
    source_map_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,
    sport_name TEXT,

    entity_type TEXT NOT NULL,
    source_name TEXT NOT NULL,
    source_type TEXT NOT NULL,

    base_url TEXT,
    country_code TEXT,
    league_name TEXT,
    team_name TEXT,

    priority_order INTEGER DEFAULT 100,
    trust_score INTEGER DEFAULT 50,
    automation_score INTEGER DEFAULT 0,

    access_type TEXT DEFAULT 'UNKNOWN',
    license_status TEXT DEFAULT 'NEEDS_REVIEW',
    robots_status TEXT DEFAULT 'NEEDS_REVIEW',

    supports_players BOOLEAN DEFAULT FALSE,
    supports_coaches BOOLEAN DEFAULT FALSE,
    supports_photos BOOLEAN DEFAULT FALSE,
    supports_profiles BOOLEAN DEFAULT FALSE,
    supports_career_history BOOLEAN DEFAULT FALSE,
    supports_transfers BOOLEAN DEFAULT FALSE,
    supports_injuries BOOLEAN DEFAULT FALSE,
    supports_stats BOOLEAN DEFAULT FALSE,
    supports_media BOOLEAN DEFAULT FALSE,
    supports_historical_data BOOLEAN DEFAULT FALSE,
    supports_live_data BOOLEAN DEFAULT FALSE,

    historical_from_year INTEGER,
    expected_depth TEXT DEFAULT 'UNKNOWN',

    current_status TEXT DEFAULT 'DISCOVERY',
    last_checked_at TIMESTAMPTZ,
    next_action TEXT,

    notes TEXT,

    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_source_intelligence_map_unique
ON ops.source_intelligence_map (
    sport_code,
    entity_type,
    source_name,
    source_type
);

COMMENT ON TABLE ops.source_intelligence_map IS
'MatchMatrix Source Intelligence Layer - centrální mapa zdrojů dat pro sporty, hráče, trenéry, fotky, historii, média a statistiky.';