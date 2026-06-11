/*
MATCHMATRIX SQL 23_2_A

PANEL BRAIN INVENTORY V1

CO TO JE:
- Inventura všech zdrojů rozhodování a automatizace.

K ČEMU TO JE:
- Zjistit co už systém umí.
- Zjistit které brain/view/registry již existují.
- Připravit skutečné MatchMatrix Operační Centrum.

KDE TO UVIDÍME:
- OPS
- Panel V19
- Autonomous Brain

JAK SE TO VYUŽIJE:
- Sjednocení doporučení.
- Sjednocení front.
- Sjednocení provider intelligence.
- Sjednocení development tasků.
*/

DROP VIEW IF EXISTS ops.v_panel_brain_inventory_v1;

CREATE OR REPLACE VIEW ops.v_panel_brain_inventory_v1 AS

SELECT
    schema_name,
    object_name,
    object_type,
    governance_status,
    owner_layer,
    domain_area,
    purpose,
    migration_action
FROM ops.database_object_governance
WHERE
      lower(object_name) LIKE '%brain%'
   OR lower(object_name) LIKE '%queue%'
   OR lower(object_name) LIKE '%dispatch%'
   OR lower(object_name) LIKE '%task%'
   OR lower(object_name) LIKE '%recommend%'
   OR lower(object_name) LIKE '%provider%'
   OR lower(object_name) LIKE '%completion%'
   OR lower(object_name) LIKE '%gap%'
   OR lower(object_name) LIKE '%registry%';