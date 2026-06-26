/*
===============================================================================
MATCHMATRIX SQL 114_A
CREATE MASTER VIEW CATALOG V1

CO TO JE:
- Oficiální katalog všech auditovaných OPS objektů.

K ČEMU TO JE:
- Rychle ukáže, co je MASTER, ACTIVE, PANEL, LEGACY, REVIEW nebo DROP.

KDE TO UVIDÍME:
- DBeaver
- OPS Panel
- budoucí DB Governance záložka

JAK SE TO VYUŽIJE:
- bezpečný cleanup DB
- orientace mezi view
- ochrana proti duplicitám mezi chaty
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_master_view_catalog_v1 AS
SELECT
    schema_name,
    object_name,
    object_type,
    governance_status,
    is_master,
    domain_area,
    owner_layer,
    migration_action,
    master_replacement,
    what_is_it,
    purpose,
    app_usage,
    depends_on,
    risk_if_wrong,
    cleanup_note,
    reviewed_by,
    reviewed_at,
    updated_at
FROM ops.database_object_governance
WHERE schema_name = 'ops'
ORDER BY
    CASE governance_status
        WHEN 'ACTIVE_MASTER' THEN 1
        WHEN 'ACTIVE' THEN 2
        WHEN 'ACTIVE_PANEL' THEN 3
        WHEN 'ACTIVE_REVIEW' THEN 4
        WHEN 'LEGACY_KEEP' THEN 5
        WHEN 'DROP_CANDIDATE' THEN 6
        ELSE 99
    END,
    domain_area,
    object_name;