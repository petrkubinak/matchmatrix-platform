/*
===============================================================================
MATCHMATRIX 19_8_A – PEOPLE SOURCE DISCOVERY REGISTRY
===============================================================================

CO TO JE:
Centrální evidence zdrojů hráčských a trenérských dat.

K ČEMU TO JE:
Evidence všech ověřených i zkoumaných providerů.

KDE TO UVIDÍME:
OPS → PEOPLE → SOURCE DISCOVERY

JAK SE TO VYUŽIJE:
People Layer
Provider Research
PC2 Planning
Photo Layer
Future Paid Provider Planning

NAVAZUJE NA:
19_7_A
19_7_A2
19_7_B
19_7_C

DALŠÍ KROK:
19_8_B Source Discovery Dashboard
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.people_source_discovery_registry (

    registry_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,

    entity_type TEXT NOT NULL,

    provider_name TEXT NOT NULL,

    access_type TEXT,

    status TEXT,

    quality_score INTEGER,

    supports_players BOOLEAN,

    supports_coaches BOOLEAN,

    supports_photos BOOLEAN,

    supports_birth_date BOOLEAN,

    supports_nationality BOOLEAN,

    supports_position BOOLEAN,

    notes TEXT,

    discovered_at TIMESTAMPTZ DEFAULT now()
);