/*
MATCHMATRIX SQL 19_3_E
PC2 Panel Run Button View V1

CO TO JE:
- Připravuje jedno hlavní view pro tlačítko v panelu:
  "SPUSTIT DALŠÍ PC2 AKCI".

K ČEMU TO JE:
- Panel nebude hádat, co má spustit.
- Vezme první READY_TO_RUN příkaz z PC2 fronty.
- Zobrazí název, sport, vrstvu, příkaz a bezpečnostní režim.

KDE TO UVIDÍME:
- OPS Panel V18
- PC2 Command Center

JAK SE TO VYUŽIJE:
- Panel načte ops.v_pc2_panel_run_button_v1.
- Uživatel klikne RUN.
- Panel spustí command_text.
*/

CREATE OR REPLACE VIEW ops.v_pc2_panel_run_button_v1 AS
SELECT
    id AS command_id,

    'SPUSTIT DALŠÍ PC2 AKCI' AS button_label_cs,

    command_title,
    sport_code,
    sport_name,
    target_layer,
    execution_bucket,

    priority_score,

    command_text,

    run_status,
    safety_mode,

    CASE
        WHEN run_status = 'READY_TO_RUN'
         AND panel_action_enabled = true
            THEN true
        ELSE false
    END AS button_enabled,

    CASE
        WHEN safety_mode = 'MANUAL_CONFIRM'
            THEN 'Vyžaduje ruční potvrzení před spuštěním.'
        WHEN safety_mode = 'AUTO_ALLOWED'
            THEN 'Lze spustit automaticky.'
        ELSE 'Automatické spuštění zakázáno.'
    END AS safety_note_cs,

    notes,
    updated_at

FROM ops.v_pc2_next_run_command_v1;


CREATE OR REPLACE VIEW ops.v_pc2_panel_run_button_summary_v1 AS
SELECT
    COUNT(*) AS available_commands,
    COUNT(*) FILTER (
        WHERE button_enabled = true
    ) AS enabled_commands,
    MIN(priority_score) AS next_priority
FROM ops.v_pc2_panel_run_button_v1;


SELECT
    command_id,
    button_label_cs,
    command_title,
    sport_code,
    target_layer,
    run_status,
    button_enabled,
    command_text
FROM ops.v_pc2_panel_run_button_v1;