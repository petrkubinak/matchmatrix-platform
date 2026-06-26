/*
MATCHMATRIX SQL 19_5_E

CO TO JE:
- Audit PEOPLE_PIPELINE_V22 pro AFB players.

K ČEMU TO JE:
- Potvrzení správného workeru před přesměrováním PC2 commandu.

KDE TO UVIDÍME:
- ops.unified_worker_registry
- ops.provider_worker_registry

JAK SE TO VYUŽIJE:
- Navazuje skript 19_5_F.
*/

SELECT
    provider,
    sport_code,
    entity,
    pull_worker,
    parse_worker,
    merge_worker,
    runtime_ready,
    panel_ready,
    scheduler_ready,
    migration_state
FROM ops.unified_worker_registry
WHERE provider='api_american_football'
  AND sport_code='AFB'
  AND entity='players';

SELECT
    provider,
    sport_code,
    entity,
    worker_type,
    worker_script,
    is_supported,
    is_active
FROM ops.provider_worker_registry
WHERE provider='api_american_football'
  AND sport_code='AFB'
  AND entity='players';