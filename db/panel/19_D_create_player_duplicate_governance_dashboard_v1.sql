/*
MATCHMATRIX SQL 19_D

PLAYER DUPLICATE GOVERNANCE DASHBOARD V1

CO TO JE:
- Souhrnný governance dashboard pro duplicity hráčů.

K ČEMU TO JE:
- Jediný pohled na stav Player Duplicate Prevention.
- Ukazuje kolik hráčů je čistých, kolik je kandidátů na merge a kolik je v HOLD.

KDE TO UVIDÍME:
- OPS Panel
- Governance
- People Layer
- Project Readiness

JAK SE TO VYUŽIJE:
- Kontrola připravenosti People Layer.
- Rozhodnutí před PC2 People Harvestem.
- Vstup pro AI doporučení.

NAVAZUJE NA:
- 19_A_create_player_duplicate_prevention_audit_v1.sql
- 19_B_create_player_duplicate_candidate_detail_v1.sql
- 19_C_create_player_duplicate_merge_plan_v1.sql

DALŠÍ KROK:
- 19_E_create_player_duplicate_review_queue_v1.sql
*/

DROP VIEW IF EXISTS ops.v_player_duplicate_governance_dashboard_v1;

CREATE OR REPLACE VIEW ops.v_player_duplicate_governance_dashboard_v1 AS

WITH players_summary AS (

    SELECT
        COUNT(*) AS total_players
    FROM public.players

),

audit_summary AS (

    SELECT

        SUM(
            CASE
                WHEN duplicate_status = 'SINGLE_OK'
                THEN player_count
                ELSE 0
            END
        ) AS single_ok_players,

        SUM(
            CASE
                WHEN duplicate_status = 'SAME_PROVIDER_DUPLICATE_CANDIDATE'
                THEN player_count
                ELSE 0
            END
        ) AS merge_candidate_players,

        SUM(
            CASE
                WHEN duplicate_status = 'SAME_NAME_DIFFERENT_BIRTHDATE_HOLD'
                THEN player_count
                ELSE 0
            END
        ) AS hold_players

    FROM ops.v_player_duplicate_prevention_audit_v1

),

merge_summary AS (

    SELECT

        COUNT(*) FILTER (
            WHERE planned_action = 'KEEP_MASTER'
        ) AS keep_master_count,

        COUNT(*) FILTER (
            WHERE planned_action = 'MANUAL_REVIEW_MERGE_CANDIDATE'
        ) AS manual_merge_review_count,

        COUNT(*) FILTER (
            WHERE planned_action = 'HOLD_BIRTHDATE_REVIEW'
        ) AS hold_review_count

    FROM ops.v_player_duplicate_merge_plan_v1

)

SELECT

    p.total_players,

    a.single_ok_players,
    a.merge_candidate_players,
    a.hold_players,

    ROUND(
        100.0 * a.single_ok_players /
        NULLIF(p.total_players,0),
        2
    ) AS clean_players_pct,

    m.keep_master_count,
    m.manual_merge_review_count,
    m.hold_review_count,

    CASE

        WHEN a.hold_players = 0
         AND a.merge_candidate_players = 0
            THEN 'READY'

        WHEN a.hold_players <= 100
         AND a.merge_candidate_players <= 300
            THEN 'CONTROLLED_HOLD'

        ELSE
            'REVIEW_REQUIRED'

    END AS governance_status,

    CASE

        WHEN a.hold_players = 0
         AND a.merge_candidate_players = 0
            THEN 'Player Duplicate Prevention dokončeno.'

        ELSE
            'Dokončit ruční review kandidátů a HOLD skupin.'
    END AS recommended_next_action,

    now() AS refreshed_at

FROM players_summary p
CROSS JOIN audit_summary a
CROSS JOIN merge_summary m;