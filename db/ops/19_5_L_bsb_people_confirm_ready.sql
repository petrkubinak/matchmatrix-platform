/*
===============================================================================
MATCHMATRIX SQL 19_5_L
BSB PEOPLE FIX
===============================================================================

CO TO JE:
- Oprava PC2 BSB PEOPLE jobu na ověřeného providera sportsdataio.

K ČEMU TO JE:
- BSB má již historicky potvrzené hotové sportsdataio PEOPLE joby.
- PC2 job 8823 je pending, ale bez league scope.
- Pro BSB people použijeme sportsdataio místo riskantního api_baseball scope.

KDE TO UVIDÍME:
- ops.ingest_planner
- ops.pc2_run_command_queue
- PC2 Command Center

JAK SE TO VYUŽIJE:
- Po opravě půjde BSB PEOPLE spustit z panelu přes PEOPLE_PIPELINE_V22.
===============================================================================
*/

BEGIN;

UPDATE ops.ingest_planner
SET
    provider = 'sportsdataio',
    provider_league_id = NULL,
    season = '2024',
    run_group = 'PC2_PEOPLE_BSB',
    status = 'pending',
    attempts = 0,
    next_run = now(),
    last_attempt = NULL,
    updated_at = now()
WHERE id = 8823;

UPDATE ops.pc2_run_command_queue
SET
    command_title = 'Spustit BSB PEOPLE Pipeline V22',
    command_text = 'python workers/run_people_pipeline_v22_from_planner.py --sport BSB --entity players --run-group PC2_PEOPLE_BSB --limit 10',
    run_status = 'READY_TO_RUN',
    worker_name = 'PEOPLE_PIPELINE_V22',
    worker_script = 'workers/run_people_pipeline_v22_from_planner.py',
    panel_action_enabled = true,
    last_result = NULL,
    last_started_at = NULL,
    last_finished_at = NULL,
    notes = 'BSB PEOPLE harvest přes PEOPLE_PIPELINE_V22 a sportsdataio.',
    action_description = 'Spustí BSB players pipeline přes specializovaný People worker.',
    purpose_description = 'Doplnění PEOPLE vrstvy pro Baseball: hráči a provider mapy.',
    target_tables = 'staging.stg_provider_players -> public.players -> public.player_provider_map',
    panel_usage = 'PC2 Command Center / PEOPLE / BSB',
    expected_result = 'BSB hráči ověřeni nebo doplněni přes PEOPLE_PIPELINE_V22.',
    updated_at = now()
WHERE id = 5;

COMMIT;

SELECT
    id,
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    status,
    attempts,
    next_run
FROM ops.ingest_planner
WHERE id = 8823;

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
    last_result
FROM ops.pc2_run_command_queue
WHERE id = 5;