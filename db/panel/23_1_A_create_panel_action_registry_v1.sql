/*
MATCHMATRIX SQL 19_A
PANEL ACTION REGISTRY V1

CO TO JE:
- Registr skutečných akčních tlačítek pro OPS Panel V19.

K ČEMU TO JE:
- Aby v panelu nebyla nefunkční tlačítka.
- Každá akce bude mít jasný typ: WORKER, SQL_ACTION, OPEN_TAB, MANUAL_REVIEW, DISABLED.
- Panel podle toho pozná, co smí spustit a co má jen zobrazit.

KDE TO UVIDÍME:
- ops.panel_action_registry
- budoucí OPS Panel V19
- akční blok v každé záložce

JAK SE TO VYUŽIJE:
- Panel zobrazí pouze ověřené akce jako aktivní tlačítka.
- Neověřené akce ukáže jako CHYBÍ WORKER / ČEKÁ NA PRO / RUČNÍ KONTROLA.
*/

CREATE TABLE IF NOT EXISTS ops.panel_action_registry (
    id bigserial PRIMARY KEY,
    tab_code text NOT NULL,
    action_code text NOT NULL,
    action_title_cz text NOT NULL,
    action_type text NOT NULL,
    worker_code text,
    sql_action_code text,
    target_tab_code text,
    is_enabled boolean NOT NULL DEFAULT false,
    is_safe boolean NOT NULL DEFAULT false,
    requires_confirmation boolean NOT NULL DEFAULT true,
    requires_selection boolean NOT NULL DEFAULT false,
    button_color text NOT NULL DEFAULT '#3b2555',
    action_priority integer NOT NULL DEFAULT 100,
    action_description text,
    success_message_cz text,
    disabled_reason_cz text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tab_code, action_code)
);

INSERT INTO ops.panel_action_registry (
    tab_code,
    action_code,
    action_title_cz,
    action_type,
    worker_code,
    target_tab_code,
    is_enabled,
    is_safe,
    requires_confirmation,
    requires_selection,
    button_color,
    action_priority,
    action_description,
    success_message_cz,
    disabled_reason_cz
)
VALUES
('DASHBOARD','REFRESH_ALL','Obnovit panel','PYTHON_METHOD',NULL,NULL,true,true,false,false,'#3b2555',10,'Obnoví všechny živé hodnoty panelu.','Panel obnoven.',NULL),
('DASHBOARD','RUN_NEXT_SAFE','Spustit další bezpečnou akci','PYTHON_METHOD','RUN_NEXT_SAFE',NULL,true,true,true,false,'#0f6a42',20,'Spustí pouze první bezpečný RUN kandidát z fronty.','Bezpečná akce spuštěna.',NULL),
('DASHBOARD','OPEN_FIX_TASKS','Otevřít opravy','OPEN_TAB',NULL,'FIX TASKS',true,true,false,false,'#6d45b8',30,'Přejde na záložku OPRAVY.','Otevřena záložka OPRAVY.',NULL),

('PEOPLE PIPELINE','RUN_PEOPLE_PIPELINE','Spustit People pipeline','WORKER','PEOPLE_PIPELINE_V22',NULL,true,true,true,false,'#0f6a42',10,'Spustí ověřený People pipeline worker.','People pipeline spuštěna.',NULL),
('PEOPLE PIPELINE','OPEN_PROVIDER_MAP_REVIEW','Otevřít provider map review','OPEN_TAB',NULL,'GOVERNANCE',true,true,false,false,'#6d45b8',20,'Otevře Governance pro kontrolu provider map.','Otevřena Governance.',NULL),

('SPORT COMPLETION','RUN_RECOMMENDED','Spustit doporučenou akci','PYTHON_METHOD','RUN_RECOMMENDED',NULL,true,true,true,false,'#0f6a42',10,'Spustí doporučenou bezpečnou akci podle panelu.','Doporučená akce spuštěna.',NULL),
('SPORT COMPLETION','OPEN_PEOPLE','Řešit People vrstvu','OPEN_TAB',NULL,'PEOPLE PIPELINE',true,true,false,false,'#6d45b8',20,'Otevře People Command Center.','Otevřena People vrstva.',NULL),
('SPORT COMPLETION','OPEN_ODDS','Řešit kurzy','OPEN_TAB',NULL,'ODDS',true,true,false,false,'#6d45b8',30,'Otevře Odds Command Center.','Otevřeny kurzy.',NULL),

('ODDS','RUN_THEODDS','Spustit TheOdds','WORKER','THEODDS_REFRESH',NULL,true,true,true,false,'#7c3aed',10,'Spustí TheOdds ingest worker.','TheOdds spuštěn.',NULL),
('ODDS','RUN_FOOTBALL_DATA','Spustit Football-Data','WORKER','FOOTBALL_DATA_REFRESH',NULL,true,true,true,false,'#6d28d9',20,'Spustí Football-Data ingest worker.','Football-Data spuštěn.',NULL),
('ODDS','PREPARE_PRO_ODDS','Připravit PRO odds','MANUAL_REVIEW',NULL,NULL,false,false,false,false,'#555555',50,'Zatím jen plán pro placený provider.','', 'Čeká na PRO / paid plán.'),

('MEDIA','RUN_MEDIA_REFRESH','Spustit media refresh','MANUAL_REVIEW',NULL,NULL,false,false,true,false,'#555555',10,'Media worker není v registru panelu potvrzen jako bezpečný.','', 'Chybí ověřený media worker v panel action registry.'),
('MEDIA','OPEN_MEDIA_QUEUE','Otevřít media frontu','OPEN_TAB',NULL,'MEDIA',true,true,false,false,'#6d45b8',20,'Zobrazí media refresh queue.','Otevřena Media záložka.',NULL),

('PROVIDERS','OPEN_PROVIDER_MATRIX','Otevřít provider matrix','OPEN_TAB',NULL,'PROVIDER MATRIX',true,true,false,false,'#6d45b8',10,'Otevře provider matrix pro kontrolu pokrytí.','Otevřena Provider Matrix.',NULL),
('PROVIDERS','RUN_PROVIDER_TEST','Otestovat providera','MANUAL_REVIEW',NULL,NULL,false,false,true,true,'#555555',20,'Provider test musí být doplněn po registraci konkrétního workeru.','', 'Chybí konkrétní provider test worker.'),

('GOVERNANCE','OPEN_RUNTIME_AUDIT','Otevřít runtime audit','OPEN_TAB',NULL,'PEOPLE PIPELINE',true,true,false,false,'#6d45b8',10,'Otevře People/Governance runtime audit.','Otevřen runtime audit.',NULL),
('GOVERNANCE','FIX_PROVIDER_MAP_HOLD','Řešit provider map HOLD','MANUAL_REVIEW',NULL,NULL,false,false,true,true,'#555555',20,'Vyžaduje ruční kontrolu konkrétních hráčů v HOLD.','', 'Ruční kontrola – automatická oprava zakázána.'),

('ROADMAP','OPEN_TOP_TASKS','Otevřít top úkoly','OPEN_TAB',NULL,'ROADMAP',true,true,false,false,'#6d45b8',10,'Otevře roadmapu a vývojové úkoly.','Otevřena Roadmapa.',NULL),
('HARVEST','RUN_HARVEST_DRY_RUN','Spustit harvest dry-run','MANUAL_REVIEW',NULL,NULL,false,false,true,false,'#555555',10,'Dry-run worker musí být potvrzen před aktivací.','', 'Čeká na ověření dry-run workeru.')
ON CONFLICT (tab_code, action_code) DO UPDATE SET
    action_title_cz = EXCLUDED.action_title_cz,
    action_type = EXCLUDED.action_type,
    worker_code = EXCLUDED.worker_code,
    sql_action_code = EXCLUDED.sql_action_code,
    target_tab_code = EXCLUDED.target_tab_code,
    is_enabled = EXCLUDED.is_enabled,
    is_safe = EXCLUDED.is_safe,
    requires_confirmation = EXCLUDED.requires_confirmation,
    requires_selection = EXCLUDED.requires_selection,
    button_color = EXCLUDED.button_color,
    action_priority = EXCLUDED.action_priority,
    action_description = EXCLUDED.action_description,
    success_message_cz = EXCLUDED.success_message_cz,
    disabled_reason_cz = EXCLUDED.disabled_reason_cz,
    updated_at = now();