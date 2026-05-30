/*
MATCHMATRIX SQL 108_V
Panel Orchestration Summary V1

CO TO JE:
- Souhrn orchestration vrstev pro panel V18.

K ČEMU TO JE:
- Panel ukáže přehled:
  - CORE ready
  - PEOPLE ready
  - ODDS planned
  - BLOCKED
  - MIGRATION_DEBT

KDE TO UVIDÍME:
- ops.v_panel_orchestration_summary_v1
- panel V18

JAK SE TO VYUŽIJE:
- hlavní přehled platformy
- rychlé rozhodování
- plánování migrací
*/

CREATE OR REPLACE VIEW ops.v_panel_orchestration_summary_v1 AS

SELECT
    COALESCE(orchestration_layer, 'UNASSIGNED') AS orchestration_layer,
    scheduler_state,
    COUNT(*) AS rows_count,

    COUNT(*) FILTER (
        WHERE runtime_ready = true
    ) AS runtime_ready_count,

    COUNT(*) FILTER (
        WHERE scheduler_ready = true
    ) AS scheduler_ready_count,

    COUNT(*) FILTER (
        WHERE panel_ready = true
    ) AS panel_ready_count,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE scheduler_state = 'READY')
        / NULLIF(COUNT(*), 0),
        2
    ) AS ready_pct

FROM ops.v_scheduler_ready_governance_v1

GROUP BY
    COALESCE(orchestration_layer, 'UNASSIGNED'),
    scheduler_state;