/*
MATCHMATRIX SCRIPT

NÁZEV:
20_4_B_3_create_harvest_readiness_snapshot_view.sql

CO TO JE:
Aktivní pohled nad posledním harvest snapshotem.

K ČEMU TO JE:
OPS Panel ani budoucí web nebudou číst tabulku přímo.
Budou číst pouze tento view.

KDE TO UVIDÍME:
OPS Panel
Harvest Command Center
Budoucí Web Admin

JAK SE TO VYUŽIJE:
Snapshot tabulka může mít historii.
View vždy vrátí pouze aktivní snapshot.
*/

CREATE OR REPLACE VIEW ops.v_harvest_readiness_current AS
SELECT
    id,
    snapshot_at,

    sport_code,
    sport_name,

    leagues_count,
    teams_count,
    matches_count,
    players_count,
    media_articles_count,

    core_status,
    people_status,
    media_status,
    odds_status,

    historical_core_status,
    current_core_status,
    current_people_status,
    current_media_status,
    current_odds_status,

    final_harvest_status,

    harvest_priority,
    next_layer_step,
    operator_action_cz,
    operator_note_cz,

    created_at,
    updated_at

FROM ops.harvest_readiness_snapshot
WHERE is_active = true
ORDER BY
    harvest_priority,
    sport_code;