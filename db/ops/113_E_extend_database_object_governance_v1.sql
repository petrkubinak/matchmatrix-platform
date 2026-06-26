/*
===============================================================================
MATCHMATRIX SQL 113_E
EXTEND DATABASE OBJECT GOVERNANCE V1

CO TO JE:
- Rozšíří governance tabulku o popisné sloupce.

K ČEMU TO JE:
- Aby každý DB objekt měl jasně uvedeno:
  co to je, k čemu to je, kdo to používá a jestli je master.

KDE TO UVIDÍME:
- ops.database_object_governance
- později OPS panel / Database Governance záložka

JAK SE TO VYUŽIJE:
- DB cleanup
- dokumentace projektu
- ochrana proti používání starých view/tabulek
===============================================================================
*/

ALTER TABLE ops.database_object_governance
    ADD COLUMN IF NOT EXISTS domain_area TEXT,
    ADD COLUMN IF NOT EXISTS owner_layer TEXT,
    ADD COLUMN IF NOT EXISTS what_is_it TEXT,
    ADD COLUMN IF NOT EXISTS purpose TEXT,
    ADD COLUMN IF NOT EXISTS web_usage TEXT,
    ADD COLUMN IF NOT EXISTS app_usage TEXT,
    ADD COLUMN IF NOT EXISTS depends_on TEXT,
    ADD COLUMN IF NOT EXISTS used_by_objects TEXT,
    ADD COLUMN IF NOT EXISTS risk_if_wrong TEXT,
    ADD COLUMN IF NOT EXISTS migration_action TEXT;

COMMENT ON COLUMN ops.database_object_governance.domain_area IS
'Logical project area: CORE, PEOPLE, MEDIA, ODDS, OPS, INGEST, AI, PANEL, PROVIDER, GOVERNANCE.';

COMMENT ON COLUMN ops.database_object_governance.owner_layer IS
'Main owner layer of the object, for example Core Layer, People Layer, OPS Layer.';

COMMENT ON COLUMN ops.database_object_governance.what_is_it IS
'Human description: what this object is.';

COMMENT ON COLUMN ops.database_object_governance.purpose IS
'Human description: what this object is used for.';

COMMENT ON COLUMN ops.database_object_governance.web_usage IS
'Where this object can appear in future MatchMatrix web application.';

COMMENT ON COLUMN ops.database_object_governance.app_usage IS
'Where this object is used in internal tools, OPS panel, workers, scheduler, or scripts.';

COMMENT ON COLUMN ops.database_object_governance.depends_on IS
'Important upstream tables/views this object depends on.';

COMMENT ON COLUMN ops.database_object_governance.used_by_objects IS
'Important downstream views/tools/workers/panels using this object.';

COMMENT ON COLUMN ops.database_object_governance.risk_if_wrong IS
'What can go wrong if this object is outdated or incorrectly used.';

COMMENT ON COLUMN ops.database_object_governance.migration_action IS
'Recommended action: KEEP, REPLACE, ARCHIVE, CHECK_DEPENDENCIES, DROP_LATER.';