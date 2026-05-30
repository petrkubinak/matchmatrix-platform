/*
MATCHMATRIX SQL 109_Q Create Panel Run Next Button Source V1

CO TO JE:
- Panelový zdroj pro tlačítko SPUSTIT DALŠÍ.

K ČEMU TO JE:
- Panel dostane jeden připravený řádek, který může bezpečně nabídnout ke spuštění.
- Už nebere data přímo z obecné fronty.
- Odděluje bezpečné spuštění od blokovaných položek.

KDE TO UVIDÍME:
- MATCHMATRIX CONTROL PANEL V18
- Tlačítko SPUSTIT DALŠÍ
- Sekce RUN NEXT / FRONTA KE SPUŠTĚNÍ

JAK SE TO VYUŽIJE:
- GUI načte první řádek z ops.v_panel_run_next_button_source_v1.
- Pokud can_execute = true, panel může nabídnout spuštění.
- Pokud není kandidát, panel zobrazí důvod.
*/


CREATE OR REPLACE VIEW ops.v_panel_run_next_button_source_v1 AS
SELECT
    c.queue_position,

    c.provider,
    c.sport_code,
    c.entity,
    c.league_id,
    c.season,
    c.run_group,

    c.ai_decision,
    c.ai_risk_level,
    c.priority_score,
    c.ai_reason,

    true AS can_execute,

    'SPUSTIT DALŠÍ'::text AS button_label,

    (
        'AI doporučuje opatrné spuštění: '
        || c.provider
        || ' / '
        || c.sport_code
        || ' / '
        || c.entity
        || COALESCE(' / liga ' || c.league_id::text, '')
        || COALESCE(' / sezóna ' || c.season::text, '')
    ) AS panel_message,

    (
        'Spustí se pouze bezpečný kandidát z AI fronty. Riziko: '
        || c.ai_risk_level
        || '. Důvod: '
        || c.ai_reason
    ) AS panel_detail,

    c.generated_at

FROM ops.v_run_next_execution_candidate_v1 c;


CREATE OR REPLACE VIEW ops.v_panel_run_next_button_state_v1 AS
SELECT
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM ops.v_panel_run_next_button_source_v1
        )
        THEN true
        ELSE false
    END AS has_candidate,

    COALESCE(
        (
            SELECT can_execute
            FROM ops.v_panel_run_next_button_source_v1
            LIMIT 1
        ),
        false
    ) AS can_execute,

    COALESCE(
        (
            SELECT button_label
            FROM ops.v_panel_run_next_button_source_v1
            LIMIT 1
        ),
        'NIC KE SPUŠTĚNÍ'
    ) AS button_label,

    COALESCE(
        (
            SELECT panel_message
            FROM ops.v_panel_run_next_button_source_v1
            LIMIT 1
        ),
        'AI nenašla žádný bezpečný kandidát ke spuštění.'
    ) AS panel_message,

    COALESCE(
        (
            SELECT panel_detail
            FROM ops.v_panel_run_next_button_source_v1
            LIMIT 1
        ),
        'Všechny dostupné položky jsou buď blokované, nebo čekají na další ověření.'
    ) AS panel_detail,

    now() AS generated_at;