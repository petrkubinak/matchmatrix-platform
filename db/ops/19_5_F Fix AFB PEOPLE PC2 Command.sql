/*
MATCHMATRIX SQL 19_5_F Fix AFB PEOPLE PC2 Command

CO TO JE:
- Přepis PC2 commandu pro AFB PEOPLE na správný PEOPLE_PIPELINE_V22 worker.

K ČEMU TO JE:
- AFB players nesmí běžet přes run_ingest_planner_jobs.py -> run_unified_ingest_v1.py.
- Správný worker je workers/run_people_pipeline_v22_from_planner.py.

KDE TO UVIDÍME:
- PC2 Command Center
- ops.pc2_run_command_queue

JAK SE TO VYUŽIJE:
- Z panelu půjde znovu spustit AFB PEOPLE harvest správnou cestou.
*/

UPDATE ops.pc2_run_command_queue
SET
    command_title = 'Spustit AFB PEOPLE Pipeline V22',
    command_text = 'python workers/run_people_pipeline_v22_from_planner.py --sport AFB --entity players --run-group PC2_PEOPLE_AFB --limit 10',
    run_status = 'READY_TO_RUN',
    worker_name = 'PEOPLE_PIPELINE_V22',
    worker_script = 'workers/run_people_pipeline_v22_from_planner.py',
    panel_action_enabled = true,
    last_result = NULL,
    last_started_at = NULL,
    last_finished_at = NULL,
    notes = 'AFB PEOPLE harvest přes PEOPLE_PIPELINE_V22. Nepoužívat run_unified_ingest_v1.py.',
    action_description = 'Spustí AFB players pipeline přes specializovaný People worker.',
    purpose_description = 'Doplnění PEOPLE vrstvy pro American Football: hráči a provider mapy.',
    target_tables = 'staging.stg_provider_players -> public.players -> public.player_provider_map',
    panel_usage = 'PC2 Command Center / PEOPLE / AFB',
    expected_result = 'AFB hráči ověřeni nebo doplněni přes PEOPLE_PIPELINE_V22.',
    updated_at = now()
WHERE id = 3
RETURNING
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
    last_result;