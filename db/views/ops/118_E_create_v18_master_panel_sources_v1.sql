/*
MATCHMATRIX SQL 118_E
CREATE V18 MASTER PANEL SOURCES V1

CO TO JE:
- Vytvoří centrální rozcestník zdrojů pro V18 panel.

K ČEMU TO JE:
- Aby panel V18 věděl, z jakého MASTER view/table má číst každá záložka.

KDE TO UVIDÍME:
- OPS Panel V18 -> interní konfigurace panelu
- Governance Dashboard
- Architecture Dashboard

JAK SE TO VYUŽIJE:
- Python panel nebude mít zdroje rozházené v kódu.
- Každá záložka bude mít jasný zdroj, účel, status a doporučené použití.
*/

CREATE TABLE IF NOT EXISTS ops.v18_master_panel_sources (
    id BIGSERIAL PRIMARY KEY,
    tab_order INTEGER NOT NULL,
    tab_code TEXT NOT NULL UNIQUE,
    tab_name_cz TEXT NOT NULL,
    source_schema TEXT NOT NULL DEFAULT 'ops',
    source_object TEXT NOT NULL,
    source_type TEXT NOT NULL DEFAULT 'VIEW',
    governance_required_status TEXT NOT NULL DEFAULT 'ACTIVE_MASTER',
    what_is_it TEXT,
    purpose TEXT,
    panel_usage TEXT,
    refresh_mode TEXT NOT NULL DEFAULT 'MANUAL_REFRESH',
    is_enabled BOOLEAN NOT NULL DEFAULT true,
    priority_level TEXT NOT NULL DEFAULT 'NORMAL',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO ops.v18_master_panel_sources (
    tab_order,
    tab_code,
    tab_name_cz,
    source_schema,
    source_object,
    source_type,
    governance_required_status,
    what_is_it,
    purpose,
    panel_usage,
    refresh_mode,
    is_enabled,
    priority_level
)
VALUES
(1, 'OPS_CENTER', 'OPS Centrum',
 'ops', 'v_operations_center_summary_v1', 'VIEW', 'ACTIVE_MASTER',
 'Hlavní provozní souhrn MatchMatrix.',
 'Ukázat základní stav OPS, běhů, problémů a doporučení.',
 'Horní přehled panelu V18.',
 'AUTO_REFRESH', true, 'HIGH'),

(2, 'HARVEST_READINESS', 'Harvest připravenost',
 'ops', 'v_harvest_readiness_summary_v1', 'VIEW', 'ACTIVE_MASTER',
 'Centrální KPI připravenosti harvestu.',
 'Ukázat, zda je projekt připraven na masivní harvest.',
 'Harvest Command Center.',
 'AUTO_REFRESH', true, 'HIGH'),

(3, 'ARCHITECTURE_MAP', 'Architektura',
 'ops', 'v_master_architecture_map_v1', 'VIEW', 'ACTIVE_MASTER',
 'Mapa hlavních vrstev projektu.',
 'Zobrazit celý tok Provider -> Web -> OPS -> Brain.',
 'Architecture Dashboard.',
 'MANUAL_REFRESH', true, 'HIGH'),

(4, 'LAYER_READINESS', 'Připravenost vrstev',
 'ops', 'v_layer_readiness_dashboard_v1', 'VIEW', 'ACTIVE_MASTER',
 'Readiness dashboard po vrstvách.',
 'Ukázat slabé a silné části projektu.',
 'Project Readiness.',
 'AUTO_REFRESH', true, 'HIGH'),

(5, 'PROJECT_ROADMAP', 'Roadmapa projektu',
 'ops', 'v_project_roadmap_milestones_v1', 'VIEW', 'ACTIVE_MASTER',
 'Milníky projektu MatchMatrix.',
 'Ukázat, co je hotovo, rozpracováno a plánováno.',
 'Project Roadmap / Launch Progress.',
 'MANUAL_REFRESH', true, 'HIGH'),

(6, 'AUTONOMOUS_BRAIN', 'Autonomní mozek',
 'ops', 'v_autonomous_ops_brain_v5', 'VIEW', 'ACTIVE_MASTER',
 'Rozhodovací mozek OPS.',
 'Doporučit další nejlepší akci podle dat.',
 'Autonomní OPS.',
 'AUTO_REFRESH', true, 'HIGH'),

(7, 'AUTONOMOUS_SUMMARY', 'Souhrn autonomního mozku',
 'ops', 'v_autonomous_ops_brain_summary_v1', 'VIEW', 'ACTIVE_MASTER',
 'Souhrn doporučení autonomního mozku.',
 'Rychlé KPI pro AI/OPS rozhodování.',
 'Autonomní OPS horní KPI.',
 'AUTO_REFRESH', true, 'HIGH'),

(8, 'PROVIDERS', 'Provideři',
 'ops', 'v_provider_routing_master_v2', 'VIEW', 'ACTIVE_MASTER',
 'Hlavní provider routing master.',
 'Ukázat stav providerů, routing a rozhodnutí.',
 'Provider Command Center.',
 'AUTO_REFRESH', true, 'HIGH'),

(9, 'PEOPLE_SUMMARY', 'People souhrn',
 'ops', 'v_people_pipeline_summary_v1', 'VIEW', 'ACTIVE_MASTER',
 'Souhrn people vrstvy.',
 'Ukázat připravenost hráčů po sportech.',
 'People Command Center.',
 'AUTO_REFRESH', true, 'HIGH'),

(10, 'PEOPLE_AUDIT', 'People audit',
 'ops', 'v_people_pipeline_audit_v1', 'VIEW', 'ACTIVE_MASTER',
 'Detailní people audit.',
 'Ukázat players/provider map/staging/public coverage.',
 'People detail.',
 'MANUAL_REFRESH', true, 'NORMAL'),

(11, 'DATA_GAP', 'Data Gap',
 'ops', 'v_data_gap_engine_v2', 'VIEW', 'ACTIVE_MASTER',
 'Datové mezery v projektu.',
 'Ukázat, co chybí po sportech a vrstvách.',
 'Data Gap Engine.',
 'AUTO_REFRESH', true, 'HIGH'),

(12, 'SPORT_COMPLETION', 'Dokončenost sportů',
 'ops', 'v_sport_completion_dashboard_v2', 'VIEW', 'ACTIVE_MASTER',
 'Dokončenost sportů napříč vrstvami.',
 'Ukázat CORE, PEOPLE, MEDIA, ODDS a celkové %.',
 'Sport Completion Dashboard.',
 'AUTO_REFRESH', true, 'HIGH'),

(13, 'RUN_NEXT', 'Run Next',
 'ops', 'v_run_next_queue_v1', 'VIEW', 'ACTIVE_MASTER',
 'Fronta doporučených dalších běhů.',
 'Ukázat co spustit jako další.',
 'Run Next.',
 'AUTO_REFRESH', true, 'HIGH'),

(14, 'ORCHESTRATION_PRIORITY', 'Priorita orchestrace',
 'ops', 'v_orchestration_priority_queue_v4', 'VIEW', 'ACTIVE_MASTER',
 'Prioritní orchestrační fronta.',
 'Řadit další práce podle přínosu a rizika.',
 'Scheduler / Orchestration.',
 'AUTO_REFRESH', true, 'HIGH'),

(15, 'ACTIVE_RUNS_LIVE', 'Aktivní běhy',
 'ops', 'v_active_runs_live_v2', 'VIEW', 'ACTIVE_MASTER',
 'Živé běhy a locky.',
 'Ukázat, co právě běží.',
 'Active Runs.',
 'AUTO_REFRESH', true, 'HIGH'),

(16, 'ACTIVE_RUNS_SUMMARY', 'Souhrn aktivních běhů',
 'ops', 'v_active_runs_summary_v1', 'VIEW', 'ACTIVE_MASTER',
 'Souhrn aktivních běhů.',
 'Ukázat počet zdravých, stale a expired běhů.',
 'Active Runs KPI.',
 'AUTO_REFRESH', true, 'HIGH'),

(17, 'RUNTIME_FEED', 'Runtime feed',
 'ops', 'v_runtime_operations_center_feed_v1', 'VIEW', 'ACTIVE_MASTER',
 'Provozní runtime feed.',
 'Ukázat poslední události a chyby workerů.',
 'Runtime Operations.',
 'AUTO_REFRESH', true, 'NORMAL'),

(18, 'AI_OPS', 'AI OPS',
 'ops', 'v_ai_ops_dashboard_panel_v1', 'VIEW', 'ACTIVE_PANEL',
 'AI OPS doporučení.',
 'Ukázat bezpečnost, riziko a doporučené akce.',
 'AI OPS Dashboard.',
 'AUTO_REFRESH', true, 'HIGH'),

(19, 'AI_OPS_SUMMARY', 'AI OPS souhrn',
 'ops', 'v_ai_ops_dashboard_panel_summary_v1', 'VIEW', 'ACTIVE_PANEL',
 'Souhrn AI OPS doporučení.',
 'Horní KPI pro AI OPS.',
 'AI OPS KPI.',
 'AUTO_REFRESH', true, 'HIGH'),

(20, 'GOVERNANCE', 'Governance',
 'ops', 'v_database_governance_summary_v1', 'VIEW', 'ACTIVE_PANEL',
 'Souhrn governance databáze.',
 'Ukázat počty MASTER, ACTIVE, REVIEW, LEGACY a DROP.',
 'Governance Dashboard.',
 'MANUAL_REFRESH', true, 'HIGH')
ON CONFLICT (tab_code) DO UPDATE SET
    tab_order = EXCLUDED.tab_order,
    tab_name_cz = EXCLUDED.tab_name_cz,
    source_schema = EXCLUDED.source_schema,
    source_object = EXCLUDED.source_object,
    source_type = EXCLUDED.source_type,
    governance_required_status = EXCLUDED.governance_required_status,
    what_is_it = EXCLUDED.what_is_it,
    purpose = EXCLUDED.purpose,
    panel_usage = EXCLUDED.panel_usage,
    refresh_mode = EXCLUDED.refresh_mode,
    is_enabled = EXCLUDED.is_enabled,
    priority_level = EXCLUDED.priority_level,
    updated_at = now();

CREATE OR REPLACE VIEW ops.v18_master_panel_sources_v1 AS
SELECT
    tab_order,
    tab_code,
    tab_name_cz,
    source_schema,
    source_object,
    source_type,
    governance_required_status,
    what_is_it,
    purpose,
    panel_usage,
    refresh_mode,
    is_enabled,
    priority_level,
    updated_at
FROM ops.v18_master_panel_sources
WHERE is_enabled = true
ORDER BY tab_order;

CREATE OR REPLACE VIEW ops.v18_master_panel_sources_summary_v1 AS
SELECT
    COUNT(*) AS total_sources,
    COUNT(*) FILTER (WHERE is_enabled = true) AS enabled_sources,
    COUNT(*) FILTER (WHERE priority_level = 'HIGH') AS high_priority_sources,
    COUNT(*) FILTER (WHERE refresh_mode = 'AUTO_REFRESH') AS auto_refresh_sources,
    COUNT(*) FILTER (WHERE refresh_mode = 'MANUAL_REFRESH') AS manual_refresh_sources
FROM ops.v18_master_panel_sources;

SELECT *
FROM ops.v18_master_panel_sources_v1;

SELECT *
FROM ops.v18_master_panel_sources_summary_v1;