/*
===============================================================================
MATCHMATRIX SQL 113_C
SEED OPS VIEWS TO GOVERNANCE REGISTRY

CO TO JE:
- Načte všechna OPS view do governance registru.

K ČEMU TO JE:
- Abychom mohli označit:
    MASTER
    ACTIVE
    LEGACY
    DROP_CANDIDATE

KDE TO UVIDÍME:
- ops.database_object_governance

JAK SE TO VYUŽIJE:
- Audit databáze
- Cleanup databáze
- Dokumentace zdrojů pravdy
===============================================================================
*/

INSERT INTO ops.database_object_governance (
    schema_name,
    object_name,
    object_type
)
SELECT
    'ops',
    viewname,
    'VIEW'
FROM pg_views
WHERE schemaname = 'ops'
ON CONFLICT (schema_name, object_name)
DO NOTHING;