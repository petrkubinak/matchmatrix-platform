/*
MATCHMATRIX SQL 17_9_I
TEAM DUPLICATE PREVENTION DASHBOARD V1

CO TO JE:
- Souhrnný dashboard pro stav ochrany proti duplicitám týmů.

K ČEMU TO JE:
- Ukáže, co je opraveno, co je bezpečné a co čeká na ruční kontrolu.

KDE TO UVIDÍME:
- OPS Panel / DATA QUALITY / TEAM DUPLICATE PREVENTION.

JAK SE TO VYUŽIJE:
- Panel V18 ukáže stav po každém ingestu.
- Pokud se objeví nová CRITICAL/HIGH duplicita, worker nebo provider půjde do kontroly.
*/

CREATE OR REPLACE VIEW ops.v_team_duplicate_prevention_dashboard_v1 AS

WITH audit AS (
    SELECT
        identity_status,
        risk_level,
        COUNT(*) AS groups_count
    FROM ops.v_team_canonical_identity_audit_v1
    GROUP BY identity_status, risk_level
),

hold AS (
    SELECT
        COUNT(*) AS hold_count
    FROM ops.team_same_name_review_hold
    WHERE review_status = 'HOLD_MANUAL_REVIEW'
),

summary AS (
    SELECT
        COALESCE(SUM(groups_count) FILTER (WHERE risk_level = 'CRITICAL'), 0) AS critical_count,
        COALESCE(SUM(groups_count) FILTER (WHERE risk_level = 'HIGH'), 0) AS high_count,
        COALESCE(SUM(groups_count) FILTER (WHERE risk_level = 'MEDIUM'), 0) AS medium_count,
        COALESCE(SUM(groups_count) FILTER (WHERE risk_level = 'LOW'), 0) AS low_count,
        COALESCE(SUM(groups_count), 0) AS total_groups
    FROM audit
)

SELECT
    now() AS checked_at,

    s.critical_count,
    s.high_count,
    s.medium_count,
    s.low_count,
    s.total_groups,

    h.hold_count,

    CASE
        WHEN s.critical_count > 0 THEN 'BLOCK_INGEST'
        WHEN s.high_count > h.hold_count THEN 'REVIEW_REQUIRED'
        WHEN s.high_count = h.hold_count THEN 'CONTROLLED_HOLD'
        ELSE 'OK'
    END AS prevention_status,

    CASE
        WHEN s.critical_count > 0
            THEN 'Existuje CRITICAL duplicita. Nepouštět nové team merge/insert workery bez kontroly.'
        WHEN s.high_count > h.hold_count
            THEN 'Existují nové HIGH duplicity mimo hold seznam. Nutná kontrola.'
        WHEN s.high_count = h.hold_count
            THEN 'Všechny HIGH případy jsou v ručním HOLD seznamu. Automatický merge je bezpečně zastaven.'
        ELSE 'Bez ostrého rizika duplicit týmů.'
    END AS status_note

FROM summary s
CROSS JOIN hold h;