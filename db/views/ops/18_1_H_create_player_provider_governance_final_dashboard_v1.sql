/*
MATCHMATRIX SQL 18_1_H
PLAYER PROVIDER GOVERNANCE FINAL DASHBOARD V1

CO TO JE:
- Finální dashboard integrity provider map pro hráče.

K ČEMU TO JE:
- Sjednocuje stav:
  1) provider identity kolizí
  2) HOLD kolizí
  3) hráčů bez provider mapy
  4) OK vazeb

KDE TO UVIDÍME:
- OPS Panel V18 → People Layer → Provider Governance.

JAK SE TO VYUŽIJE:
- Finální kontrola před připojováním dalších People providerů.
- Pokud je stav CONTROLLED_HOLD, ingest může pokračovat, ale automatické merge opravy jsou vypnuté.
*/

CREATE OR REPLACE VIEW ops.v_player_provider_governance_final_dashboard_v1 AS
WITH audit AS (
    SELECT
        governance_issue,
        risk_level,
        COUNT(*) AS rows_count
    FROM ops.v_player_provider_map_governance_audit_v1
    GROUP BY governance_issue, risk_level
),

collision_hold AS (
    SELECT
        COUNT(*) AS collision_hold_groups,
        COUNT(*) FILTER (
            WHERE suggested_action = 'POSSIBLE_PLAYER_MERGE'
        ) AS possible_merge_groups,
        COUNT(*) FILTER (
            WHERE suggested_action = 'PROVIDER_MAP_REVIEW'
        ) AS provider_map_review_groups
    FROM ops.player_provider_collision_review_hold
    WHERE review_status = 'HOLD_MANUAL_REVIEW'
),

summary AS (
    SELECT
        COALESCE(SUM(rows_count) FILTER (
            WHERE governance_issue = 'PROVIDER_IDENTITY_COLLISION'
        ), 0) AS provider_identity_collision_rows,

        COALESCE(SUM(rows_count) FILTER (
            WHERE governance_issue = 'PLAYER_WITHOUT_PROVIDER_MAP'
        ), 0) AS player_without_provider_map_rows,

        COALESCE(SUM(rows_count) FILTER (
            WHERE governance_issue = 'OK'
        ), 0) AS ok_rows,

        COALESCE(SUM(rows_count), 0) AS total_rows
    FROM audit
)

SELECT
    now() AS checked_at,

    s.provider_identity_collision_rows,
    ch.collision_hold_groups,
    ch.possible_merge_groups,
    ch.provider_map_review_groups,

    s.player_without_provider_map_rows,
    s.ok_rows,
    s.total_rows,

    CASE
        WHEN s.provider_identity_collision_rows > 0
         AND ch.collision_hold_groups = 0
            THEN 'BLOCK_PEOPLE_PROVIDER_INGEST'

        WHEN s.provider_identity_collision_rows > 0
         AND ch.collision_hold_groups > 0
            THEN 'CONTROLLED_HOLD'

        WHEN s.player_without_provider_map_rows > 0
            THEN 'REVIEW_REQUIRED'

        ELSE 'READY'
    END AS governance_status,

    CASE
        WHEN s.provider_identity_collision_rows > 0
         AND ch.collision_hold_groups > 0
            THEN 'Provider identity kolize jsou v HOLD seznamu. G. Gibson zůstává bez bezpečné provider mapy a musí být řešen ručně.'

        WHEN s.provider_identity_collision_rows > 0
            THEN 'Existují provider identity kolize mimo HOLD. Nepouštět People provider ingest.'

        WHEN s.player_without_provider_map_rows > 0
            THEN 'Existují hráči bez provider mapy. Nutná ruční kontrola.'

        ELSE 'Player provider governance je připravená.'
    END AS status_note

FROM summary s
CROSS JOIN collision_hold ch;