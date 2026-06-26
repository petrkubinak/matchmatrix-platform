/*
===============================================================================
MATCHMATRIX SQL 19_5_P
FB PLAYER PHOTO WIKIMEDIA TEST AUDIT
===============================================================================

CO TO JE:
- Audit připravenosti prvního free photo harvestu:
  FB player photos přes Wikimedia/Wikipedia/Wikidata.

K ČEMU TO JE:
- FB PLAYER_PHOTOS má nejvyšší prioritu 100.
- Je FREE.
- Nečeká na placeného providera.
- Potřebujeme zjistit, jestli už máme worker/frontu pro photo_asset_discovery_worker.

KDE TO UVIDÍME:
- Photo Provider Research
- PC2 Photo Harvest Readiness
- OPS worker registry
- public.players.photo_url

JAK SE TO VYUŽIJE:
- Pokud existuje worker, vytvoříme/spustíme PC2 command.
- Pokud worker neexistuje, připravíme nový photo_asset_discovery_worker.
===============================================================================
*/

SELECT *
FROM ops.v_photo_provider_research_v1
WHERE sport_code = 'FB'
  AND entity_type = 'PLAYER_PHOTOS';

SELECT *
FROM ops.v_pc2_photo_harvest_readiness_v1
WHERE sport_code = 'FB'
  AND entity_type = 'PLAYER_PHOTOS';

SELECT *
FROM ops.v_pc2_photo_ready_for_test_v1
WHERE sport_code = 'FB'
  AND entity_type = 'PLAYER_PHOTOS';

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
WHERE worker_script ILIKE '%photo%'
   OR worker_script ILIKE '%image%'
   OR worker_type ILIKE '%photo%'
   OR entity ILIKE '%photo%';

SELECT
    provider,
    sport_code,
    entity,
    pull_worker,
    parse_worker,
    merge_worker,
    source_table,
    target_table,
    runtime_ready,
    panel_ready,
    scheduler_ready,
    migration_state,
    notes
FROM ops.unified_worker_registry
WHERE pull_worker ILIKE '%photo%'
   OR parse_worker ILIKE '%photo%'
   OR merge_worker ILIKE '%photo%'
   OR entity ILIKE '%photo%';

SELECT
    COUNT(*) AS fb_players_total,
    COUNT(*) FILTER (WHERE photo_url IS NOT NULL AND length(trim(photo_url)) > 0) AS fb_players_with_photo,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE photo_url IS NOT NULL AND length(trim(photo_url)) > 0)
        / NULLIF(COUNT(*), 0),
        2
    ) AS fb_photo_pct
FROM public.players
WHERE sport_id = (
    SELECT id FROM public.sports WHERE code = 'FB' LIMIT 1
);