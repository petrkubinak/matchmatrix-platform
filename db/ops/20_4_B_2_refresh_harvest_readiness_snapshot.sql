/*
MATCHMATRIX SCRIPT

NÁZEV:
20_4_B_2_refresh_harvest_readiness_snapshot.sql

CO TO JE:
Refresh snapshotu harvest připravenosti.

K ČEMU TO JE:
Naplní ops.harvest_readiness_snapshot
aktuálním stavem CORE / PEOPLE / MEDIA.

KDE TO UVIDÍME:
OPS Panel
Harvest Command Center
Budoucí Web Admin

JAK SE TO VYUŽIJE:
Panel nebude počítat miliony řádků.
Bude číst poslední snapshot.
*/

BEGIN;

UPDATE ops.harvest_readiness_snapshot
SET
    is_active = false,
    updated_at = now()
WHERE is_active = true;

INSERT INTO ops.harvest_readiness_snapshot
(
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

    is_active,
    created_at,
    updated_at
)
VALUES

-- FB
(
now(),
'FB','Football',
2030,6854,105506,5340,47,
'READY','READY','PARTIAL_READY','DATA_GAP',
'READY','WAITING','WAITING','WAITING','WAITING',
'HARVEST_READY',
1,
'HISTORICAL_CORE',
'SPUSTIT HISTORICKÝ CORE HARVEST',
'Po dokončení pokračovat CURRENT_CORE → PEOPLE → MEDIA → ODDS.',
true,now(),now()
),

-- HB
(
now(),
'HB','Handball',
212,1005,9275,0,0,
'READY','DATA_GAP','DATA_GAP','DATA_GAP',
'READY','WAITING','WAITING','WAITING','WAITING',
'HARVEST_READY',
2,
'HISTORICAL_CORE',
'SPUSTIT HISTORICKÝ CORE HARVEST',
'Po CORE řešit PEOPLE providery.',
true,now(),now()
),

-- HK
(
now(),
'HK','Hockey',
263,394,2430,1950,110,
'READY','READY','PARTIAL_READY','DATA_GAP',
'READY','WAITING','WAITING','WAITING','WAITING',
'HARVEST_READY',
3,
'HISTORICAL_CORE',
'SPUSTIT HISTORICKÝ CORE HARVEST',
'Po CORE navázat PEOPLE a MEDIA.',
true,now(),now()
),

-- BK
(
now(),
'BK','Basketball',
427,214,1114,862,68,
'READY','READY','PARTIAL_READY','DATA_GAP',
'READY','WAITING','WAITING','WAITING','WAITING',
'HARVEST_READY',
4,
'HISTORICAL_CORE',
'SPUSTIT HISTORICKÝ CORE HARVEST',
'Po CORE navázat PEOPLE a MEDIA.',
true,now(),now()
),

-- BSB
(
now(),
'BSB','Baseball',
78,61,2945,7109,8,
'READY','READY','PARTIAL_READY','DATA_GAP',
'READY','WAITING','WAITING','WAITING','WAITING',
'HARVEST_READY',
5,
'HISTORICAL_CORE',
'SPUSTIT HISTORICKÝ CORE HARVEST',
'Po CORE navázat PEOPLE a MEDIA.',
true,now(),now()
);

COMMIT;