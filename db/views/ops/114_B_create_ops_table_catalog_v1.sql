/*
===============================================================================
MATCHMATRIX SQL 114_B
OPS TABLE GOVERNANCE CATALOG V1
===============================================================================
*/

DELETE FROM ops.database_object_governance
WHERE schema_name = 'ops'
  AND object_type = 'TABLE';

INSERT INTO ops.database_object_governance (
    schema_name,
    object_name,
    object_type,
    governance_status,
    is_master,
    domain_area,
    owner_layer,
    migration_action,
    what_is_it,
    purpose,
    cleanup_note,
    reviewed_by,
    reviewed_at,
    updated_at
)
VALUES
-- GOVERNANCE
('ops','database_object_governance','TABLE','ACTIVE_MASTER',true,'GOVERNANCE','DB Governance','KEEP','Hlavní governance tabulka DB objektů.','Evidence master/active/legacy/drop objektů.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','schema_migrations','TABLE','ACTIVE_MASTER',true,'GOVERNANCE','Migration Layer','KEEP','Evidence spuštěných migrací.','Hlídá historii SQL změn.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),

-- PLANNER / INGEST
('ops','ingest_planner','TABLE','ACTIVE_MASTER',true,'INGEST','Planner Layer','KEEP','Hlavní fronta ingest jobů.','Řídí pending/running/done/error ingest úlohy.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','ingest_targets','TABLE','ACTIVE_MASTER',true,'INGEST','Target Layer','KEEP','Hlavní seznam ingest targetů.','Definuje provider/league/season/run_group cíle.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','ingest_entity_plan','TABLE','ACTIVE_MASTER',true,'INGEST','Entity Plan Layer','KEEP','Plán entit pro ingest.','Definuje entity, priority, scope a worker.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','ingest_runtime_config','TABLE','ACTIVE_MASTER',true,'INGEST','Runtime Config','KEEP','Konfigurace runtime ingestů.','Řídí sezóny, budget a režimy.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),

-- RUNTIME
('ops','job_runs','TABLE','ACTIVE_MASTER',true,'RUNTIME','Runtime Layer','KEEP','Historie běhů jobů.','Základ pro runtime metriky a health score.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','jobs','TABLE','ACTIVE_MASTER',true,'RUNTIME','Job Registry','KEEP','Registr jobů.','Definuje dostupné joby.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','runtime_execution_history','TABLE','ACTIVE_MASTER',true,'RUNTIME','Runtime History','KEEP','Historie runtime execution.','Zdroj pro alerty, health a audit.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','runtime_entity_audit','TABLE','ACTIVE_MASTER',true,'RUNTIME','Runtime Audit','KEEP','Audit runtime stavu entit.','Zdroj pravdy CONFIRMED/RUNNABLE/PARTIAL.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','active_worker_runs','TABLE','ACTIVE_MASTER',true,'RUNTIME','Active Runs','KEEP','Aktivní běžící workery.','Chrání proti paralelním konfliktům.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','scheduler_queue','TABLE','ACTIVE_MASTER',true,'SCHEDULER','Scheduler Layer','KEEP','Scheduler fronta.','Řídí plánované běhy.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','worker_locks','TABLE','ACTIVE_MASTER',true,'RUNTIME','Lock Layer','KEEP','Worker locky.','Ochrana proti duplicitním běhům.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),

-- PROVIDERS
('ops','provider_entity_coverage','TABLE','ACTIVE_MASTER',true,'PROVIDER','Provider Coverage','KEEP','Hlavní provider coverage tabulka.','Zdroj pro routing, panel, scheduler.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','provider_jobs','TABLE','ACTIVE_MASTER',true,'PROVIDER','Provider Jobs','KEEP','Definice provider jobů.','Napojení provider/entity na job_code.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','provider_people_audit','TABLE','ACTIVE_MASTER',true,'PEOPLE','People Provider Audit','KEEP','Audit PEOPLE providerů.','Rozhoduje použitelnost hráčů/trenérů/statistik.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','provider_sport_matrix','TABLE','ACTIVE_MASTER',true,'PROVIDER','Provider Matrix','KEEP','Provider/sport capability matrix.','Určuje podporu entit podle sportu.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','provider_accounts','TABLE','ACTIVE',false,'PROVIDER','Provider Accounts','KEEP','Provider účty a limity.','Budget a API plánování.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','provider_worker_registry','TABLE','ACTIVE',false,'PROVIDER','Provider Worker Registry','KEEP','Mapování provider workerů.','Používá dispatch command layer.','Ověřit po sjednocení worker_registry.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','provider_switch_recommendations','TABLE','ACTIVE_REVIEW',false,'PROVIDER','Provider Switching','REVIEW','Doporučení změny providerů.','Fallback/switch rozhodování.','Ověřit aktuální využití.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','provider_coaches_runtime_checklist','TABLE','ACTIVE_REVIEW',false,'PEOPLE','Coaches Checklist','REVIEW','Checklist trenérských endpointů.','Pomocný audit pro coaches layer.','Ověřit po PEOPLE master matrix.','ChatGPT + Petr DB audit',NOW(),NOW()),

-- WORKERS
('ops','worker_registry','TABLE','ACTIVE_MASTER',true,'WORKER','Worker Registry','KEEP','Hlavní registr workerů.','Scheduler a resolver.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','worker_capability_registry','TABLE','ACTIVE_MASTER',true,'WORKER','Worker Capability','KEEP','Capability registry workerů.','AI launcher a execution rules.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','worker_execution_rules','TABLE','ACTIVE_MASTER',true,'WORKER','Execution Rules','KEEP','Pravidla spuštění workerů.','AI worker selector.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','worker_dependency_graph','TABLE','ACTIVE_MASTER',true,'WORKER','Dependency Graph','KEEP','Závislosti workerů.','Dependency-aware orchestrace.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','unified_worker_registry','TABLE','ACTIVE_MASTER',true,'WORKER','Unified Worker Registry','KEEP','Sjednocený worker registry.','Scheduler governance.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),

-- AI / AUTONOMOUS / REPAIR
('ops','autonomous_execution_queue','TABLE','ACTIVE_MASTER',true,'AUTONOMOUS','Autonomous Queue','KEEP','Fronta autonomních akcí.','Autonomous OPS execution.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','dispatch_queue','TABLE','ACTIVE_MASTER',true,'DISPATCH','Dispatch Queue','KEEP','Dispatch fronta.','Run Next / Dispatch engine.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','fix_tasks','TABLE','ACTIVE_MASTER',true,'REPAIR','Fix Tasks','KEEP','AI fix task queue.','Opravy parserů/providerů/runtime chyb.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','ai_action_execution_log','TABLE','ACTIVE',false,'AI_OPS','AI Action Log','KEEP','Log AI akcí.','Historie autonomních rozhodnutí.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','brain_recommendation_log','TABLE','ACTIVE',false,'AI_OPS','Brain Log','KEEP','Log doporučení OPS brain.','Audit rozhodnutí AI OPS.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','repair_outcome_catalog','TABLE','ACTIVE',false,'REPAIR','Repair Catalog','KEEP','Katalog repair výsledků.','Learning oprav.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','repair_outcome_learning','TABLE','ACTIVE',false,'REPAIR','Repair Learning','KEEP','Learning výsledků oprav.','Zpětná vazba pro repair engine.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','repair_reset_audit','TABLE','ACTIVE',false,'REPAIR','Repair Reset Audit','KEEP','Audit resetů repair položek.','Kontrola ručních oprav.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),

-- PEOPLE
('ops','people_master_provider_matrix','TABLE','ACTIVE_MASTER',true,'PEOPLE','People Master Matrix','KEEP','Master matrix PEOPLE providerů.','Rozhoduje providery pro hráče/trenéry/profily/statistiky.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','people_quality_backfill_queue','TABLE','ACTIVE',false,'PEOPLE','People Backfill','KEEP','People quality backfill queue.','Doplňování hráčů/profilů/statistik.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','player_enrichment_plan','TABLE','ACTIVE',false,'PEOPLE','Player Enrichment','KEEP','Plán enrichmentu hráčů.','Doplňování profilů/fotek/detailů.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','fixture_player_stats_queue','TABLE','ACTIVE',false,'PEOPLE','Player Match Stats Queue','KEEP','Fronta match statistik hráčů.','People stats pipeline.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),

-- MEDIA
('ops','media_article_velocity_log','TABLE','ACTIVE',false,'MEDIA','Media Velocity','KEEP','Velocity log článků.','Trending/media score.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','media_asset_enrichment_queue','TABLE','ACTIVE',false,'MEDIA','Media Asset Enrichment','KEEP','Fronta enrichmentu media assetů.','Thumbnail/video/media enrichment.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','media_discovery_requests','TABLE','ACTIVE',false,'MEDIA','Media Discovery','KEEP','Požadavky na media discovery.','Vyhledávání nových zdrojů.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','media_job_runs','TABLE','ACTIVE',false,'MEDIA','Media Job Runs','KEEP','Běhy media workerů.','Audit media pipeline.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','media_refresh_queue','TABLE','ACTIVE',false,'MEDIA','Media Refresh Queue','KEEP','Fronta refreshů media obsahu.','Aktualizace článků/videí.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','media_source_discovery_candidates','TABLE','ACTIVE',false,'MEDIA','Media Discovery Candidates','KEEP','Kandidáti media zdrojů.','Rozšiřování media providerů.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','media_source_health_audit','TABLE','ACTIVE',false,'MEDIA','Media Source Health','KEEP','Health audit media zdrojů.','Kontrola dostupnosti web/RSS zdrojů.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),

-- SPORT GOVERNANCE
('ops','sport_completion_audit','TABLE','ACTIVE_MASTER',true,'SPORT','Sport Completion','KEEP','Audit dokončenosti sportů.','Zdroj pro completion dashboard.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','sport_dimension_rules','TABLE','ACTIVE_MASTER',true,'SPORT','Sport Dimensions','KEEP','Pravidla dimenzí sportů.','Team/player/ranking/surface model.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','sport_entity_rules','TABLE','ACTIVE_MASTER',true,'SPORT','Sport Entity Rules','KEEP','Pravidla entit sportů.','Požadavky na league/team/player/match.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','sports_import_plan','TABLE','ACTIVE_MASTER',true,'SPORT','Sports Import Plan','KEEP','Import plán sportů.','Budget a režim sportů.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','league_import_plan','TABLE','LEGACY_KEEP',false,'SPORT','Legacy League Plan','KEEP','Starší league import plán.','Historický import plán před ingest_targets.','Nahrazeno ops.ingest_targets.','ChatGPT + Petr DB audit',NOW(),NOW()),

-- DEVELOPMENT
('ops','development_task_queue','TABLE','ACTIVE',false,'DEVELOPMENT','Development Queue','KEEP','Fronta vývojových úkolů.','Roadmapa a další kroky.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),

-- FOOTBALL / LEGACY
('ops','fb_entity_audit','TABLE','LEGACY_KEEP',false,'FOOTBALL','FB Entity Audit','KEEP','Historický football entity audit.','Starší football audit vrstva.','Ponechat jako historii.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','fb_players_pro_priority_buckets','TABLE','ACTIVE_REVIEW',false,'FOOTBALL','FB People Priority Buckets','REVIEW','Priority bucket pro FB players PRO režim.','Použít při PRO backfillu.','Ověřit před PRO aktivací.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','eu_batch_1','TABLE','LEGACY_KEEP',false,'FOOTBALL','EU Batch Legacy','KEEP','Historický EU batch seznam.','Použití v původních FB run groups.','Ponechat do cleanup fáze.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','eu_batch_100','TABLE','LEGACY_KEEP',false,'FOOTBALL','EU Batch Legacy','KEEP','Historický EU batch seznam.','Použití v původních FB run groups.','Ponechat do cleanup fáze.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','eu_keep_ids','TABLE','LEGACY_KEEP',false,'FOOTBALL','EU Keep IDs','KEEP','Historický seznam EU league IDs.','Použití v původním FB whitelistu.','Ponechat do cleanup fáze.','ChatGPT + Petr DB audit',NOW(),NOW()),

-- API / BUDGET
('ops','api_budget_status','TABLE','ACTIVE',false,'API','API Budget','KEEP','Stav API budgetu.','Denní request limity.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW()),
('ops','api_request_log','TABLE','ACTIVE',false,'API','API Request Log','KEEP','Log API requestů.','Budget tracking.','Nemazat.','ChatGPT + Petr DB audit',NOW(),NOW());

CREATE OR REPLACE VIEW ops.v_master_table_catalog_v1 AS
SELECT
    schema_name,
    object_name,
    object_type,
    governance_status,
    is_master,
    domain_area,
    owner_layer,
    migration_action,
    master_replacement,
    what_is_it,
    purpose,
    cleanup_note,
    reviewed_by,
    reviewed_at,
    updated_at
FROM ops.database_object_governance
WHERE schema_name='ops'
  AND object_type='TABLE'
ORDER BY
    CASE governance_status
        WHEN 'ACTIVE_MASTER' THEN 1
        WHEN 'ACTIVE' THEN 2
        WHEN 'ACTIVE_PANEL' THEN 3
        WHEN 'ACTIVE_REVIEW' THEN 4
        WHEN 'LEGACY_KEEP' THEN 5
        WHEN 'DROP_CANDIDATE' THEN 6
        ELSE 99
    END,
    domain_area,
    object_name;