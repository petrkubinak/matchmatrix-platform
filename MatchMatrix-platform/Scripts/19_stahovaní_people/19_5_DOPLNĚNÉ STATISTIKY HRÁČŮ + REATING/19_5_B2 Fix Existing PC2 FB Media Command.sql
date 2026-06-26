/*
MATCHMATRIX SQL 19_5_B2 Fix Existing PC2 FB Media Command

CO TO JE:
- Přepis existujícího PC2 commandu id=9.

K ČEMU TO JE:
- Zachováme unikátní klíč FB/MEDIA/19_3_PC2_DEPENDENCY_QUEUE.
- Command nebude spouštět planner ani unified ingest.
- Command bude spouštět přímo FB media worker.

KDE TO UVIDÍME:
- ops.pc2_run_command_queue
- PC2 Command Center

JAK SE TO VYUŽIJE:
- Panel bude moct znovu spustit FB MEDIA harvest správnou cestou.
*/

UPDATE ops.pc2_run_command_queue
SET
    command_title = 'Spustit FB MEDIA Official Site Harvest',
    command_text = 'python workers/media/pull_official_site_media_articles_v1.py',
    run_status = 'READY_TO_RUN',
    run_group = 'PC2_MEDIA_FB',
    worker_name = 'FB_MEDIA_PULL',
    worker_script = 'workers/media/pull_official_site_media_articles_v1.py',
    panel_action_enabled = true,
    last_result = NULL,
    notes = 'FB MEDIA harvest přes official_site worker. Výstup do staging.stg_media_articles. Nepoužívat run_unified_ingest_v1.py.',
    action_description = 'Spustí harvest článků z oficiálních fotbalových zdrojů.',
    purpose_description = 'Doplnění MEDIA vrstvy pro fotbal: články, ligové zprávy, týmový kontext.',
    target_tables = 'staging.stg_media_articles -> public.articles',
    panel_usage = 'PC2 Command Center / MEDIA / FB',
    expected_result = 'Nové nebo aktualizované články ve staging.stg_media_articles, následně merge do public.articles.',
    updated_at = now()
WHERE id = 9;

SELECT
    id,
    sport_code,
    target_layer,
    command_title,
    command_text,
    run_status,
    run_group,
    worker_name,
    worker_script,
    panel_action_enabled,
    notes
FROM ops.pc2_run_command_queue
WHERE id = 9;