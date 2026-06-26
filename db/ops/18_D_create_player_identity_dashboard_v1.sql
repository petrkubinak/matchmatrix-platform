/*
MATCHMATRIX SQL 18_D
PLAYER IDENTITY DASHBOARD V1

CO TO JE:
- Dashboard stavu hráčské identity a duplicit.

K ČEMU TO JE:
- Ukáže, zda máme CRITICAL/HIGH hráčské duplicity.
- Oddělí bezpečné HOLD případy od ostrých problémů.

KDE TO UVIDÍME:
- OPS Panel V18 → PEOPLE / PLAYER IDENTITY GOVERNANCE.

JAK SE TO VYUŽIJE:
- Kontrola před spuštěním people ingest workerů.
- Pokud se objeví CRITICAL/HIGH mimo HOLD, zastavit merge/insert worker.
*/

CREATE OR REPLACE VIEW ops.v_player_identity_dashboard_v1 AS
WITH audit AS (
    SELECT
        identity_status,
        risk_level,
        COUNT(*) AS groups_count
    FROM ops.v_player_canonical_identity_audit_v1
    GROUP BY identity_status, risk_level
),

hold AS (
    SELECT
        identity_status,
        risk_level,
        COUNT(*) AS hold_count
    FROM ops.player_identity_review_hold
    WHERE review_status = 'HOLD_MANUAL_REVIEW'
    GROUP BY identity_status, risk_level
),

summary AS (
    SELECT
        COALESCE(SUM(groups_count) FILTER (WHERE risk_level = 'CRITICAL'), 0) AS critical_count,
        COALESCE(SUM(groups_count) FILTER (WHERE risk_level = 'HIGH'), 0) AS high_count,
        COALESCE(SUM(groups_count) FILTER (WHERE risk_level = 'MEDIUM'), 0) AS medium_count,
        COALESCE(SUM(groups_count) FILTER (WHERE risk_level = 'LOW'), 0) AS low_count,
        COALESCE(SUM(groups_count), 0) AS total_groups
    FROM audit
),

hold_summary AS (
    SELECT
        COALESCE(SUM(hold_count), 0) AS hold_count
    FROM hold
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
        WHEN s.critical_count > 0 THEN 'BLOCK_PEOPLE_INGEST'
        WHEN s.high_count > 0 THEN 'REVIEW_REQUIRED'
        WHEN s.medium_count + s.low_count = h.hold_count THEN 'CONTROLLED_HOLD'
        ELSE 'OK'
    END AS player_identity_status,

    CASE
        WHEN s.critical_count > 0
            THEN 'Existuje CRITICAL hráčská duplicita. Nepouštět people merge/insert workery.'
        WHEN s.high_count > 0
            THEN 'Existuje HIGH hráčská duplicita. Nutná kontrola před automatickým merge.'
        WHEN s.medium_count + s.low_count = h.hold_count
            THEN 'Všechny nejasné hráčské identity jsou v HOLD seznamu. Automatický merge je bezpečně zastaven.'
        ELSE 'Bez ostrého rizika hráčských duplicit.'
    END AS status_note

FROM summary s
CROSS JOIN hold_summary h;