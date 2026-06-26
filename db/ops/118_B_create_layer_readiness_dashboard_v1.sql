/*
MATCHMATRIX SQL 118_B
CREATE LAYER READINESS DASHBOARD V1

CO TO JE:
- Vytvoří readiness dashboard nad hlavní architekturou MatchMatrix.
- Každé vrstvě přiřadí aktuální připravenost v procentech.

K ČEMU TO JE:
- Aby panel V18 věděl, které vrstvy jsou hotové, částečné nebo blokované.
- Abychom neměli readiness jen v dokumentech, ale přímo v DB.

KDE TO UVIDÍME:
- OPS Panel V18 -> Harvest Command Center
- OPS Panel V18 -> Architecture
- OPS Panel V18 -> Project Readiness

JAK SE TO VYUŽIJE:
- V18 bude číst readiness po vrstvách.
- Později můžeme procenta přepočítávat automaticky podle reálných auditů.
*/

CREATE TABLE IF NOT EXISTS ops.layer_readiness_status (
    id BIGSERIAL PRIMARY KEY,
    layer_code TEXT NOT NULL UNIQUE,
    readiness_percent NUMERIC(5,2) NOT NULL DEFAULT 0,
    readiness_status TEXT NOT NULL DEFAULT 'UNKNOWN',
    readiness_note TEXT,
    blocking_issue TEXT,
    next_action TEXT,
    source_type TEXT NOT NULL DEFAULT 'MANUAL_BASELINE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO ops.layer_readiness_status (
    layer_code,
    readiness_percent,
    readiness_status,
    readiness_note,
    blocking_issue,
    next_action,
    source_type
)
VALUES
('PROVIDER', 95.00, 'READY',
 'Provider registry, coverage a jobs jsou připravené pro hlavní sporty.',
 NULL,
 'Doplnit další free/paid providery pro chybějící people, media a odds vrstvy.',
 'MANUAL_BASELINE'),

('RAW', 100.00, 'READY',
 'Raw ukládání existuje pro hlavní ingest větve a umožňuje reprocessing.',
 NULL,
 'Držet raw payloady jako auditní základ.',
 'MANUAL_BASELINE'),

('STAGING', 95.00, 'READY',
 'Staging vrstva je připravená pro core, people, odds i media data.',
 NULL,
 'Doplnit jen nové staging tabulky při přidání nového provideru nebo entity.',
 'MANUAL_BASELINE'),

('MERGE', 90.00, 'READY',
 'Merge do public modelu funguje pro hlavní core vrstvy a část people/media.',
 'Některé people, media a odds merge větve jsou ještě částečné.',
 'Doplnit merge workery pro chybějící sportovní vrstvy.',
 'MANUAL_BASELINE'),

('PUBLIC', 95.00, 'READY',
 'Public model obsahuje hlavní produkční tabulky pro web, ratingy a tikety.',
 NULL,
 'Udržovat public model jako stabilní kontrakt pro web.',
 'MANUAL_BASELINE'),

('PEOPLE', 75.00, 'PARTIAL',
 'People vrstva má základní players/provider map pro více sportů.',
 'Chybí profily, fotky, coaches, rankings a širší statistiky u více sportů.',
 'Prioritně doplnit FB, HK, BK a potom ostatní sporty.',
 'MANUAL_BASELINE'),

('MEDIA', 75.00, 'PARTIAL',
 'Media vrstva má články a první football/basketball/hockey zdroje.',
 'Chybí video, highlights, širší linkování na hráče/zápasy a další sporty.',
 'Doplnit media command center a další zdroje.',
 'MANUAL_BASELINE'),

('ODDS', 55.00, 'PARTIAL',
 'Odds vrstva má základ a plán providerů.',
 'Chybí širší odds coverage, historické odds a napojení TheOdds do V18.',
 'Přenést TheOdds Command Center z V11 a ověřit další odds providery.',
 'MANUAL_BASELINE'),

('ML_MMR', 75.00, 'PARTIAL',
 'Ratingy a predikční logika jsou rozpracované a částečně připravené.',
 'Chybí finální validace modelů a napojení na větší objem dat.',
 'Po doplnění dat spustit validaci modelů a prediction pipeline.',
 'MANUAL_BASELINE'),

('TICKET_ENGINE', 60.00, 'PARTIAL',
 'Ticket Engine má základní logiku, ale není ještě finálně napojený na web.',
 'Chybí UI, settlement audit a produkční doporučovací vrstva.',
 'Doplnit webové napojení a audit výsledků tiketů.',
 'MANUAL_BASELINE'),

('WEB', 20.00, 'NOT_READY',
 'Webová vrstva je zatím základní a není připravená na platící uživatele.',
 'Chybí registrace, login, předplatné, Stripe, uživatelské profily a admin.',
 'Po V18 začít systematicky stavět Web V1.',
 'MANUAL_BASELINE'),

('OPS', 95.00, 'READY',
 'OPS vrstva má governance, planner, scheduler, runtime audit a panelový základ.',
 NULL,
 'Napojit V18 výhradně na ACTIVE_MASTER a ACTIVE_PANEL objekty.',
 'MANUAL_BASELINE'),

('AUTONOMOUS_BRAIN', 85.00, 'PARTIAL',
 'Autonomní mozek umí doporučovat další akce a číst stav OPS.',
 'Ještě není plně uzavřená smyčka akce -> výsledek -> učení -> další akce.',
 'Doplnit result learning a bezpečné autonomous execution flow.',
 'MANUAL_BASELINE'),

('SECOND_PC', 30.00, 'PLANNED',
 'Druhý harvest server je navržený, ale ještě není fyzicky zapojený do provozu.',
 'Chybí Git sync, .env, DB connection, lock test a worker test.',
 'Připravit second PC checklist a testovací harvest.',
 'MANUAL_BASELINE')
ON CONFLICT (layer_code) DO UPDATE SET
    readiness_percent = EXCLUDED.readiness_percent,
    readiness_status = EXCLUDED.readiness_status,
    readiness_note = EXCLUDED.readiness_note,
    blocking_issue = EXCLUDED.blocking_issue,
    next_action = EXCLUDED.next_action,
    source_type = EXCLUDED.source_type,
    updated_at = now();

CREATE OR REPLACE VIEW ops.v_layer_readiness_dashboard_v1 AS
SELECT
    m.layer_order,
    m.layer_code,
    m.layer_name,
    r.readiness_percent,
    r.readiness_status,
    CASE
        WHEN r.readiness_percent >= 90 THEN 'GREEN'
        WHEN r.readiness_percent >= 75 THEN 'YELLOW'
        WHEN r.readiness_percent >= 50 THEN 'ORANGE'
        ELSE 'RED'
    END AS readiness_color,
    r.readiness_note,
    r.blocking_issue,
    r.next_action,
    m.panel_usage,
    r.source_type,
    r.updated_at
FROM ops.master_architecture_map m
LEFT JOIN ops.layer_readiness_status r
    ON r.layer_code = m.layer_code
ORDER BY m.layer_order;

CREATE OR REPLACE VIEW ops.v_layer_readiness_summary_v1 AS
SELECT
    ROUND(AVG(readiness_percent), 2) AS overall_readiness_percent,
    COUNT(*) AS total_layers,
    COUNT(*) FILTER (WHERE readiness_status = 'READY') AS ready_layers,
    COUNT(*) FILTER (WHERE readiness_status = 'PARTIAL') AS partial_layers,
    COUNT(*) FILTER (WHERE readiness_status = 'NOT_READY') AS not_ready_layers,
    COUNT(*) FILTER (WHERE readiness_status = 'PLANNED') AS planned_layers,
    MIN(readiness_percent) AS weakest_layer_percent,
    MAX(readiness_percent) AS strongest_layer_percent
FROM ops.layer_readiness_status;

SELECT * FROM ops.v_layer_readiness_dashboard_v1;

SELECT * FROM ops.v_layer_readiness_summary_v1;