/*
MATCHMATRIX SQL 18_1_D
PLAYER PROVIDER MAP GOVERNANCE DASHBOARD V1

CO TO JE:
- Dashboard integrity provider map pro hráče.

K ČEMU TO JE:
- Ukáže stav mezi:
  public.players
  public.player_provider_map
  public.player_external_identity

KDE TO UVIDÍME:
- OPS Panel V18 → People Layer → Provider Governance.

JAK SE TO VYUŽIJE:
- Kontrola před připojením nových People providerů.
- Pokud se objeví CRITICAL mimo HOLD, zastavit people provider ingest.
*/

CREATE OR REPLACE VIEW ops.v_player_provider_map_governance_dashboard_v1 AS
WITH audit AS (
    SELECT
        governance_issue,
        risk_level,
        COUNT(*) AS rows_count
    FROM ops.v_player_provider_map_governance_audit_v1
    GROUP BY governance_issue, risk_level
),

hold AS (
    SELECT
        COUNT(*) AS hold_count
    FROM ops.player_provider_collision_review_hold
    WHERE review_status = 'HOLD_MANUAL_REVIEW'
),

summary AS (
    SELECT
        COALESCE(SUM(rows_count) FILTER (WHERE risk_level = 'CRITICAL'), 0) AS critical_rows,
        COALESCE(SUM(rows_count) FILTER (WHERE risk_level = 'MEDIUM'), 0) AS medium_rows,
        COALESCE(SUM(rows_count) FILTER (WHERE risk_level = 'LOW'), 0) AS low_rows,
        COALESCE(SUM(rows_count), 0) AS total_rows
    FROM audit
)

SELECT
    now() AS checked_at,

    s.critical_rows,
    s.medium_rows,
    s.low_rows,
    s.total_rows,
    h.hold_count,

    CASE
        WHEN s.critical_rows > 0 AND h.hold_count = 0
            THEN 'BLOCK_PEOPLE_PROVIDER_INGEST'
        WHEN s.critical_rows > 0 AND h.hold_count > 0
            THEN 'CONTROLLED_HOLD'
        WHEN s.medium_rows > 0
            THEN 'REVIEW_REQUIRED'
        ELSE 'OK'
    END AS governance_status,

    CASE
        WHEN s.critical_rows > 0 AND h.hold_count > 0
            THEN 'CRITICAL provider identity kolize jsou v HOLD seznamu. Automatické opravy jsou zastavené.'
        WHEN s.critical_rows > 0
            THEN 'Existují CRITICAL provider identity kolize mimo HOLD. Nepouštět people provider ingest.'
        WHEN s.medium_rows > 0
            THEN 'Existují hráči bez provider mapy nebo jiné střední problémy.'
        ELSE 'Provider map governance je bez ostrých problémů.'
    END AS status_note

FROM summary s
CROSS JOIN hold h;