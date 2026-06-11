/*
MATCHMATRIX SQL 19_E

PLAYER DUPLICATE REVIEW QUEUE V1

CO TO JE:
- Ruční review fronta pro Player Duplicate Prevention.

K ČEMU TO JE:
- Oddělí kandidáty na ruční merge od HOLD birth_date konfliktů.
- Připraví přehled, co kontrolovat postupně.
- Harvest PC2 tím nebude blokovaný.

KDE TO UVIDÍME:
- OPS Panel
- Governance
- People Layer
- Player Duplicate Prevention

JAK SE TO VYUŽIJE:
- MANUAL_REVIEW_MERGE_CANDIDATE = později ručně ověřit a případně sloučit.
- HOLD_BIRTHDATE_REVIEW = nikdy neslučovat automaticky.
- KEEP_MASTER = pouze informačně, není třeba řešit.

NAVAZUJE NA:
- 19_C_create_player_duplicate_merge_plan_v1.sql
- 19_D_create_player_duplicate_governance_dashboard_v1.sql

DALŠÍ KROK:
- 19_F_insert_player_duplicate_governance_runtime_audit_v1.sql
*/

DROP VIEW IF EXISTS ops.v_player_duplicate_review_queue_v1;

CREATE OR REPLACE VIEW ops.v_player_duplicate_review_queue_v1 AS

SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            CASE planned_action
                WHEN 'MANUAL_REVIEW_MERGE_CANDIDATE' THEN 1
                WHEN 'HOLD_BIRTHDATE_REVIEW' THEN 2
                WHEN 'KEEP_MASTER' THEN 3
                ELSE 9
            END,
            normalized_name,
            merge_player_id
    ) AS review_order,

    sport_id,
    normalized_name,

    master_player_id,
    merge_player_id,

    player_name,
    provider,
    provider_player_id,
    team_id,
    provider_team_name,
    birth_date,
    nationality,
    position,
    photo_url,

    risk_level,
    duplicate_status,
    planned_action,
    merge_candidate,
    merge_reason,

    CASE
        WHEN planned_action = 'MANUAL_REVIEW_MERGE_CANDIDATE'
            THEN 'Zkontrolovat tým, datum narození, národnost a provider ID.'

        WHEN planned_action = 'HOLD_BIRTHDATE_REVIEW'
            THEN 'HOLD: stejné jméno, rozdílný birth_date. Automaticky neslučovat.'

        WHEN planned_action = 'KEEP_MASTER'
            THEN 'Master záznam skupiny. Bez akce.'

        ELSE
            'Ruční kontrola.'
    END AS review_instruction,

    now() AS refreshed_at

FROM ops.v_player_duplicate_merge_plan_v1
WHERE planned_action <> 'KEEP_MASTER';