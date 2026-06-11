/*
MATCHMATRIX SQL 19_C

PLAYER DUPLICATE MERGE PLAN V1

CO TO JE:
- Bezpečný plán pro budoucí merge duplicitních hráčů.

K ČEMU TO JE:
- Vybere master_player_id a merge_player_id.
- MEDIUM kandidáty připraví k ruční kontrole.
- HIGH_HOLD nechá automaticky v HOLD.
- Zatím nic neslučuje ani nemaže.

KDE TO UVIDÍME:
- People Governance
- Player Duplicate Prevention
- OPS Panel

JAK SE TO VYUŽIJE:
- Slouží jako podklad pro ruční kontrolu.
- Teprve po kontrole vznikne bezpečný merge skript.
- HIGH_HOLD nikdy nepůjde automaticky.

NAVAZUJE NA:
- 19_A_create_player_duplicate_prevention_audit_v1.sql
- 19_B_create_player_duplicate_candidate_detail_v1.sql

DALŠÍ KROK:
- 19_D_create_player_duplicate_governance_dashboard_v1.sql
*/

DROP VIEW IF EXISTS ops.v_player_duplicate_merge_plan_v1;

CREATE OR REPLACE VIEW ops.v_player_duplicate_merge_plan_v1 AS

WITH candidates AS (
    SELECT
        risk_level,
        duplicate_status,
        recommended_action,
        sport_id,
        normalized_name,
        player_id,
        player_name,
        birth_date,
        nationality,
        position,
        team_id,
        provider,
        provider_player_id,
        provider_team_name,
        photo_url,
        provider_map_active
    FROM ops.v_player_duplicate_candidate_detail_v1
),

ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY sport_id, normalized_name
            ORDER BY
                CASE WHEN photo_url IS NOT NULL AND photo_url <> '' THEN 0 ELSE 1 END,
                CASE WHEN birth_date IS NOT NULL THEN 0 ELSE 1 END,
                CASE WHEN nationality IS NOT NULL AND nationality <> '' THEN 0 ELSE 1 END,
                CASE WHEN provider_map_active = true THEN 0 ELSE 1 END,
                player_id ASC
        ) AS candidate_rank,

        FIRST_VALUE(player_id) OVER (
            PARTITION BY sport_id, normalized_name
            ORDER BY
                CASE WHEN photo_url IS NOT NULL AND photo_url <> '' THEN 0 ELSE 1 END,
                CASE WHEN birth_date IS NOT NULL THEN 0 ELSE 1 END,
                CASE WHEN nationality IS NOT NULL AND nationality <> '' THEN 0 ELSE 1 END,
                CASE WHEN provider_map_active = true THEN 0 ELSE 1 END,
                player_id ASC
        ) AS master_player_id
    FROM candidates
),

plan_rows AS (
    SELECT
        sport_id,
        normalized_name,
        risk_level,
        duplicate_status,

        master_player_id,
        player_id AS merge_player_id,

        player_name,
        provider,
        provider_player_id,
        team_id,
        provider_team_name,
        birth_date,
        nationality,
        position,
        photo_url,

        CASE
            WHEN risk_level = 'HIGH_HOLD'
                THEN 'HOLD_BIRTHDATE_REVIEW'

            WHEN player_id = master_player_id
                THEN 'KEEP_MASTER'

            WHEN risk_level = 'MEDIUM'
                THEN 'MANUAL_REVIEW_MERGE_CANDIDATE'

            WHEN risk_level = 'HIGH'
                THEN 'MANUAL_REVIEW_CROSS_PROVIDER_MERGE'

            ELSE 'REVIEW'
        END AS planned_action,

        CASE
            WHEN risk_level = 'HIGH_HOLD'
                THEN false

            WHEN player_id = master_player_id
                THEN false

            WHEN risk_level IN ('MEDIUM','HIGH')
                THEN true

            ELSE false
        END AS merge_candidate,

        CASE
            WHEN risk_level = 'HIGH_HOLD'
                THEN 'Neslučovat automaticky: stejné jméno, rozdílné datum narození.'

            WHEN player_id = master_player_id
                THEN 'Vybraný master záznam ve skupině.'

            WHEN risk_level = 'MEDIUM'
                THEN 'Stejný provider a stejné normalizované jméno. Nutná ruční kontrola týmu/dalších údajů.'

            WHEN risk_level = 'HIGH'
                THEN 'Více providerů, stejné normalizované jméno. Nutná ruční kontrola.'

            ELSE 'Ruční kontrola.'
        END AS merge_reason,

        now() AS refreshed_at

    FROM ranked
)

SELECT *
FROM plan_rows
ORDER BY
    CASE planned_action
        WHEN 'HOLD_BIRTHDATE_REVIEW' THEN 1
        WHEN 'KEEP_MASTER' THEN 2
        WHEN 'MANUAL_REVIEW_CROSS_PROVIDER_MERGE' THEN 3
        WHEN 'MANUAL_REVIEW_MERGE_CANDIDATE' THEN 4
        ELSE 9
    END,
    normalized_name,
    merge_player_id;