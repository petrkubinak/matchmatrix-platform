UPDATE ops.database_object_governance
SET
    domain_area = 'AI_OPS',
    owner_layer = 'OPS Layer',
    what_is_it = 'Hlavní rozhodovací view Autonomous OPS Brain V5.',
    purpose = 'Vyhodnocuje kandidáty, skóre, worker registry a doporučuje RUN / WAIT / HOLD.',
    app_usage = 'OPS Panel záložka AI OPS -> Autonomous OPS Brain.',
    depends_on = 'ops.v_autonomous_ops_brain_v4, ops.provider_worker_registry',
    risk_if_wrong = 'Panel nebo dispatcher může doporučit starší nebo špatnou akci.',
    migration_action = 'KEEP',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name = 'v_autonomous_ops_brain_v5';

UPDATE ops.database_object_governance
SET
    domain_area = 'AI_OPS',
    owner_layer = 'OPS Layer',
    what_is_it = 'Souhrnné view Autonomous OPS Brain.',
    purpose = 'Agreguje doporučení Brainu podle provider/sport/entity/run_group.',
    app_usage = 'OPS souhrny, budoucí dashboard autonomního řízení.',
    depends_on = 'ops.v_autonomous_ops_brain_v5',
    risk_if_wrong = 'Souhrn může ukazovat špatný stav doporučených akcí.',
    migration_action = 'KEEP',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name = 'v_autonomous_ops_brain_summary_v1';

UPDATE ops.database_object_governance
SET
    domain_area = 'OPS',
    owner_layer = 'Automation Layer',
    what_is_it = 'Finální runtime-ready fronta automatizace.',
    purpose = 'Filtruje pouze akce, které mají provider, worker, run_group a runtime podmínky.',
    app_usage = 'Autonomous dispatcher / automation readiness.',
    depends_on = 'ops.v_automation_ready_queue_v3',
    risk_if_wrong = 'Automat může spouštět nedokončené nebo blokované entity.',
    migration_action = 'KEEP',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name = 'v_automation_ready_queue_v4';

UPDATE ops.database_object_governance
SET
    domain_area = 'PROVIDER',
    owner_layer = 'Provider Routing Layer',
    what_is_it = 'Hlavní provider routing master V2.',
    purpose = 'Spojuje coverage, runtime audit, sport completion, people audit a provider matrix.',
    app_usage = 'Provider routing, automation queue, audit providerů.',
    depends_on = 'ops.provider_entity_coverage, ops.runtime_entity_audit, ops.sport_completion_audit, ops.provider_people_audit, ops.provider_sport_matrix',
    risk_if_wrong = 'Systém může vybrat špatného primary/fallback providera.',
    migration_action = 'KEEP',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name = 'v_provider_routing_master_v2';

UPDATE ops.database_object_governance
SET
    domain_area = 'OPS',
    owner_layer = 'Project Readiness Layer',
    what_is_it = 'Hlavní dashboard dokončenosti sportů V2.',
    purpose = 'Počítá CORE/PEOPLE/MEDIA/ODDS procenta a doporučený focus sportu.',
    app_usage = 'OPS Panel -> Roadmapa -> Dokončenost sportů.',
    depends_on = 'ops.sport_completion_audit, ops.v_sport_daily_budget_monitor_v1',
    risk_if_wrong = 'Panel může ukazovat špatnou prioritu projektu.',
    migration_action = 'KEEP',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name = 'v_sport_completion_dashboard_v2';