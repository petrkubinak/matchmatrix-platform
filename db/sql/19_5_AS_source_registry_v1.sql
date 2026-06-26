/*
===============================================================================
MATCHMATRIX 19_5_AS - SOURCE REGISTRY V1
===============================================================================

CO TO JE:
Centrální registr všech zdrojů dat využívaných nebo kandidujících
pro MatchMatrix.

Obsahuje:
- API providery
- Oficiální weby lig
- Oficiální weby týmů
- Federace
- RSS zdroje
- Sitemapy
- Wikidata
- Wikimedia
- Open Data zdroje

-------------------------------------------------------------------------------

K ČEMU TO JE:
Zdroj pravdy pro Autonomous Source Discovery Layer.

Pokud provider:
- vrací 0 dat
- přestane fungovat
- je blokovaný
- nemá potřebnou entitu

systém zde najde alternativní zdroje.

-------------------------------------------------------------------------------

KDE TO UVIDÍME:

OPS → Source Discovery

OPS → Autonomous Brain

OPS → Provider Routing

OPS → Fix Tasks

-------------------------------------------------------------------------------

JAK SE TO VYUŽIJE:

Příklad:

VB PLAYERS
↓
api_volleyball = BLOCKED
↓
source_registry
↓
FIVB
↓
CEV
↓
Wikidata
↓
Official Team Site
↓
Source Discovery Task

-------------------------------------------------------------------------------

NAVAZUJE NA:

ops.runtime_entity_audit

ops.fix_tasks

ops.provider_routing_master

ops.v_source_discovery_priority_queue_v1

-------------------------------------------------------------------------------

DALŠÍ KROK:

19_5_AT_source_discovery_tasks_v1.sql

19_5_AU_run_source_discovery_worker_v1.py

===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.source_registry (

    source_id BIGSERIAL PRIMARY KEY,

    source_name TEXT NOT NULL,

    source_type TEXT NOT NULL,

    base_url TEXT,

    sport_code TEXT,

    entity_type TEXT,

    trust_score NUMERIC(5,2),

    automation_allowed BOOLEAN DEFAULT FALSE,

    license_review_required BOOLEAN DEFAULT TRUE,

    robots_review_required BOOLEAN DEFAULT TRUE,

    active BOOLEAN DEFAULT TRUE,

    notes TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW()

);