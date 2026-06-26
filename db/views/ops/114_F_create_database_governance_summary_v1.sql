/*
===============================================================================
MATCHMATRIX SQL 114_F
DATABASE GOVERNANCE SUMMARY V1

CO TO JE:
- Centrální přehled governance celého projektu.

K ČEMU TO JE:
- Ukazuje kolik objektů je ACTIVE_MASTER, ACTIVE, REVIEW,
  LEGACY nebo DROP.
- Slouží jako vstup pro cleanup a dependency audit.

KDE TO UVIDÍME:
- DBeaver
- OPS Panel (budoucí Governance záložka)

JAK SE TO VYUŽIJE:
- Audit databáze
- Cleanup
- Release readiness
- Dokumentace projektu
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_database_governance_summary_v1 AS
SELECT
    schema_name,
    object_type,
    governance_status,
    COUNT(*) AS object_count
FROM ops.database_object_governance
GROUP BY
    schema_name,
    object_type,
    governance_status
ORDER BY
    schema_name,
    object_type,
    governance_status;


CREATE OR REPLACE VIEW ops.v_database_governance_domains_v1 AS
SELECT
    schema_name,
    domain_area,
    governance_status,
    COUNT(*) AS object_count
FROM ops.database_object_governance
GROUP BY
    schema_name,
    domain_area,
    governance_status
ORDER BY
    schema_name,
    domain_area,
    governance_status;


CREATE OR REPLACE VIEW ops.v_database_governance_masters_v1 AS
SELECT
    schema_name,
    object_type,
    object_name,
    domain_area,
    owner_layer,
    governance_status,
    reviewed_at
FROM ops.database_object_governance
WHERE is_master = true
ORDER BY
    schema_name,
    domain_area,
    object_name;