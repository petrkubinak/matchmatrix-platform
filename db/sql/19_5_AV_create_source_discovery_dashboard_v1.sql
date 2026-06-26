/*
====================================================================================================
MATCHMATRIX 19_5_AV - SOURCE DISCOVERY DASHBOARD V1
====================================================================================================

CO TO JE:
Dashboard nad Autonomous Source Discovery vrstvou.

K ČEMU TO JE:
Ukazuje přehled všech kandidátů zdrojů, které Discovery Engine doporučuje
pro doplnění chybějících dat napříč sporty a entitami.

KDE TO UVIDÍME:
OPS Panel V18
→ Provider Command Center
→ Autonomous Discovery
→ Source Discovery Dashboard

JAK SE TO VYUŽIJE:
1. Discovery Engine najde chybějící data.
2. Navrhne nejlepší zdroje.
3. Zařadí je do discovery queue.
4. Dashboard ukáže priority.
5. Autonomous Harvest Loop může zdroje automaticky ověřovat.
6. Po ověření mohou být zdroje zapsány do source_registry
   a použity jako nové harvest routy.

NAVAZUJE NA:
- ops.v_source_discovery_queue_v1
- ops.v_source_discovery_summary_v1
- ops.source_registry
- ops.provider_entity_coverage

====================================================================================================
*/

CREATE OR REPLACE VIEW ops.v_source_discovery_dashboard_v1
AS
SELECT
    queue_priority,
    sport_code,
    entity_type,
    provider,
    coverage_status,
    source_type,
    recommended_mode,
    missing_fields,
    best_score,
    discovery_task_type,
    task_status,
    suggested_action,
    generated_at
FROM ops.v_source_discovery_queue_v1
ORDER BY
    queue_priority,
    best_score DESC,
    sport_code,
    entity_type;