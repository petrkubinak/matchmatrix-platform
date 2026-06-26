/*
===============================================================================
MATCHMATRIX SQL 113_B
DATABASE OBJECT GOVERNANCE V1

CO TO JE:
- Centrální tabulka, kde označíme DB objekty jako MASTER / ACTIVE / LEGACY / DROP_CANDIDATE.

K ČEMU TO JE:
- Aby nový chat ani panel nepoužíval staré view/tabulky omylem.

KDE TO UVIDÍME:
- V DBeaveru, později v OPS panelu.

JAK SE TO VYUŽIJE:
- Bezpečný cleanup databáze.
- Dokumentace skutečných zdrojů pravdy.
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.database_object_governance (
    id BIGSERIAL PRIMARY KEY,

    schema_name TEXT NOT NULL,
    object_name TEXT NOT NULL,
    object_type TEXT NOT NULL,

    governance_status TEXT NOT NULL DEFAULT 'UNREVIEWED',
    is_master BOOLEAN NOT NULL DEFAULT FALSE,

    master_replacement TEXT,
    used_by TEXT,
    purpose_note TEXT,
    cleanup_note TEXT,

    reviewed_at TIMESTAMPTZ,
    reviewed_by TEXT DEFAULT 'manual_audit',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_database_object_governance
    UNIQUE (schema_name, object_name)
);

CREATE INDEX IF NOT EXISTS ix_database_object_governance_status
ON ops.database_object_governance(governance_status);

COMMENT ON TABLE ops.database_object_governance IS
'Governance registry for MatchMatrix DB objects: master, active, legacy, drop candidates.';