/*
===============================================================================
MATCHMATRIX SQL 116_F
SECOND PC MILESTONE TASKS V1

CO TO JE:
- Dílčí úkoly k milníku SECOND_PC_READY.

K ČEMU TO JE:
- Aby bylo jasné, co přesně musí být hotové před červencovým hromadným harvestem.

KDE TO UVIDÍME:
- OPS roadmap dashboard
- budoucí Mission Control / Project panel

JAK SE TO VYUŽIJE:
- příprava druhého PC
- kontrola připravenosti PRO harvestu
===============================================================================
*/

INSERT INTO ops.project_milestones (
    milestone_code,
    milestone_name,
    category,
    planned_date,
    status,
    priority,
    progress_percent,
    description
)
VALUES
(
    'SECOND_PC_BUY',
    'Koupit druhé výkonné PC',
    'INFRASTRUCTURE',
    DATE '2026-06-10',
    'PLANNED',
    20,
    0,
    'Pořídit druhé PC určené pro harvest, backfill a pomocné výpočty.'
),
(
    'SECOND_PC_INSTALL',
    'Nainstalovat základní software',
    'INFRASTRUCTURE',
    DATE '2026-06-12',
    'PLANNED',
    21,
    0,
    'Nainstalovat Windows, Python 3.14, Git, VS Code, Docker Desktop, DBeaver a PostgreSQL klient.'
),
(
    'SECOND_PC_PROJECT_SYNC',
    'Synchronizovat MatchMatrix projekt',
    'INFRASTRUCTURE',
    DATE '2026-06-13',
    'PLANNED',
    22,
    0,
    'Naklonovat nebo synchronizovat C:\\MatchMatrix-platform na druhé PC.'
),
(
    'SECOND_PC_ENV_CONFIG',
    'Nastavit .env konfiguraci',
    'INFRASTRUCTURE',
    DATE '2026-06-13',
    'PLANNED',
    23,
    0,
    'Nastavit bezpečně .env soubory pro ingest, providery a přístup k databázi.'
),
(
    'SECOND_PC_DB_CONNECTION',
    'Ověřit připojení k PostgreSQL',
    'INFRASTRUCTURE',
    DATE '2026-06-14',
    'PLANNED',
    24,
    0,
    'Ověřit, že druhé PC vidí hlavní PostgreSQL databázi a umí zapisovat do OPS logů.'
),
(
    'SECOND_PC_WORKER_TEST',
    'Otestovat jeden bezpečný worker',
    'INFRASTRUCTURE',
    DATE '2026-06-14',
    'PLANNED',
    25,
    0,
    'Spustit testovací worker bez rizika duplicitního harvestu.'
),
(
    'SECOND_PC_LOCK_TEST',
    'Otestovat worker locks',
    'INFRASTRUCTURE',
    DATE '2026-06-15',
    'PLANNED',
    26,
    0,
    'Ověřit, že druhé PC respektuje ops.worker_locks a nespouští duplicitní joby.'
),
(
    'SECOND_PC_HARVEST_DRY_RUN',
    'Spustit harvest dry-run',
    'INFRASTRUCTURE',
    DATE '2026-06-15',
    'PLANNED',
    27,
    0,
    'Spustit malý bezpečný test harvestu přes planner a ověřit zápisy do OPS.'
)

ON CONFLICT (milestone_code)
DO NOTHING;