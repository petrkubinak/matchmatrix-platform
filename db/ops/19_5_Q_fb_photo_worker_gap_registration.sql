/*
===============================================================================
MATCHMATRIX SQL 19_5_Q
FB PHOTO WORKER GAP REGISTRATION
===============================================================================

CO TO JE:
- Zápis chybějícího worker gapu pro FB PLAYER_PHOTOS.

K ČEMU TO JE:
- Roadmapa už ví, že FB PLAYER_PHOTOS jsou priorita 100.
- Reálný worker ale není v registry.
- Tímto označíme, že je potřeba vytvořit/registerovat photo_asset_discovery_worker.

KDE TO UVIDÍME:
- provider_worker_registry
- runtime_entity_audit
- PC2 / Photo dashboard

JAK SE TO VYUŽIJE:
- Další krok bude vytvoření fyzického workeru:
  workers/media/photo_asset_discovery_worker_v1.py
===============================================================================
*/

INSERT INTO ops.provider_worker_registry (
    provider,
    sport_code,
    entity,
    worker_type,
    worker_script,
    is_supported,
    is_active,
    notes,
    created_at,
    updated_at
)
VALUES (
    'wikimedia',
    'FB',
    'PLAYER_PHOTOS',
    'photo_asset_discovery',
    'workers/media/photo_asset_discovery_worker_v1.py',
    true,
    false,
    'Worker zatím fyzicky neexistuje. Potřeba vytvořit pro FB player photo discovery přes Wikidata/Wikimedia. Aktuální coverage public.players.photo_url = 27.63 %.',
    now(),
    now()
)
ON CONFLICT DO NOTHING;

INSERT INTO ops.runtime_entity_audit (
    provider,
    sport_code,
    entity,
    current_state,
    last_run_group,
    last_check_at,
    last_log_summary,
    db_evidence_summary,
    next_action,
    created_at,
    updated_at
)
VALUES (
    'wikimedia',
    'FB',
    'PLAYER_PHOTOS',
    'MISSING_WORKER',
    'PHOTO_PROVIDER_RESEARCH',
    now(),
    'FB PLAYER_PHOTOS má roadmap priority=100 a FREE source, ale registry photo worker je prázdná.',
    'FB players total=5314; players_with_photo=1468; photo coverage=27.63 %.',
    'Vytvořit workers/media/photo_asset_discovery_worker_v1.py a napojit na public.players.photo_url.',
    now(),
    now()
)
ON CONFLICT DO NOTHING;

SELECT
    provider,
    sport_code,
    entity,
    worker_type,
    worker_script,
    is_supported,
    is_active,
    notes
FROM ops.provider_worker_registry
WHERE provider='wikimedia'
  AND sport_code='FB'
  AND entity='PLAYER_PHOTOS';

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    last_log_summary,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE provider='wikimedia'
  AND sport_code='FB'
  AND entity='PLAYER_PHOTOS';