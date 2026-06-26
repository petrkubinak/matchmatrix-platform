UPDATE ops.database_object_governance
SET
    domain_area = 'OPS',
    owner_layer = 'Data Gap Layer',
    what_is_it = 'Hlavní engine pro vyhodnocení datových mezer V2.',
    purpose = 'Převádí coverage_status providerů na srozumitelný gap status.',
    app_usage = 'OPS Panel -> Roadmapa -> Data Gap.',
    depends_on = 'ops.provider_entity_coverage',
    risk_if_wrong = 'Panel může chybně ukazovat, co je READY a co chybí.',
    migration_action = 'KEEP',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name = 'v_data_gap_engine_v2';

UPDATE ops.database_object_governance
SET
    domain_area = 'PANEL',
    owner_layer = 'Data Gap Layer',
    what_is_it = 'Panelové view pro zobrazení datových mezer V2.',
    purpose = 'Zobrazuje provider, sport, entitu, status, důvod a další krok.',
    app_usage = 'OPS Panel -> Roadmapa -> DATA GAP / CO CHYBÍ.',
    depends_on = 'ops.v_data_gap_engine_v2',
    risk_if_wrong = 'Uživatel může řešit špatné nebo staré data gap položky.',
    migration_action = 'KEEP',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name = 'v_data_gap_panel_v2';

UPDATE ops.database_object_governance
SET
    domain_area = 'INGEST',
    owner_layer = 'Ingest Layer',
    what_is_it = 'Přehled ingest plánů a schopností providerů.',
    purpose = 'Spojuje ingest_entity_plan, pravidla sportů a provider_sport_matrix.',
    app_usage = 'DBeaver audit / budoucí OPS panel ingest přehled.',
    depends_on = 'ops.ingest_entity_plan, ops.sport_entity_rules, ops.provider_sport_matrix, ops.sport_dimension_rules',
    risk_if_wrong = 'Může vzniknout špatný plán harvestu nebo špatná priorita entity.',
    migration_action = 'KEEP',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name = 'v_ingest_overview';

UPDATE ops.database_object_governance
SET
    domain_area = 'INGEST',
    owner_layer = 'Planner Layer',
    what_is_it = 'Aktuální fronta ingest planneru.',
    purpose = 'Ukazuje pending/running/error joby a zda jsou připravené ke spuštění.',
    app_usage = 'Scheduler, worker run_ingest_planner_jobs, DBeaver audit.',
    depends_on = 'ops.ingest_planner',
    risk_if_wrong = 'Worker může spustit špatnou nebo nepřipravenou úlohu.',
    migration_action = 'KEEP',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name = 'v_ingest_planner_queue';

UPDATE ops.database_object_governance
SET
    domain_area = 'INGEST',
    owner_layer = 'Planner Layer',
    what_is_it = 'Souhrn stavu ingest planneru podle provider/sport/entity/run_group.',
    purpose = 'Počítá počet jobů podle statusu a pomáhá sledovat stav fronty.',
    app_usage = 'OPS Panel / DBeaver monitoring planneru.',
    depends_on = 'ops.ingest_planner',
    risk_if_wrong = 'Panel může ukazovat chybný stav planner fronty.',
    migration_action = 'KEEP',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name = 'v_ingest_planner_status';