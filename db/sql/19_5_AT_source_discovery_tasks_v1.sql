/*
===============================================================================
MATCHMATRIX 19_5_AT - SOURCE DISCOVERY TASKS V1
===============================================================================

CO TO JE:
Fronta úkolů pro autonomní hledání nových zdrojů dat.

-------------------------------------------------------------------------------

K ČEMU TO JE:
Řídí práci Discovery Workeru.

-------------------------------------------------------------------------------

KDE TO UVIDÍME:

OPS → Source Discovery

OPS → Autonomous Brain

OPS → Fix Tasks

-------------------------------------------------------------------------------

JAK SE TO VYUŽIJE:

HK PLAYERS
↓
Provider BLOCKED
↓
Vytvoří Discovery Task
↓
Worker hledá nový zdroj
↓
Ověření
↓
Fix Task
↓
Harvest Retry

-------------------------------------------------------------------------------

NAVAZUJE NA:

19_5_AS_source_registry_v1.sql

ops.fix_tasks

ops.runtime_entity_audit

-------------------------------------------------------------------------------

DALŠÍ KROK:

19_5_AU_run_source_discovery_worker_v1.py

===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.source_discovery_tasks (

    task_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT,

    entity_type TEXT,

    provider TEXT,

    source_name TEXT,

    discovery_status TEXT,

    priority_score INTEGER,

    action_required TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    completed_at TIMESTAMPTZ

);