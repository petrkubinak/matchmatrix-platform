/*
MATCHMATRIX SQL 23_3_O

PC2 GO-LIVE CHECKLIST V1

CO TO JE:
- Finální checklist před zapojením nového PC2 jako harvest serveru.

K ČEMU TO JE:
- Ověřit, že PC2 může bezpečně spustit masivní harvest.
- Zabránit duplicitnímu spouštění jobů.
- Ověřit přístup k DB, Git, Pythonu, workerům, logům a API limitům.

KDE TO UVIDÍME:
- OPS Panel
- PC2 Dashboard
- Harvest Ready
- Operační Centrum

JAK SE TO VYUŽIJE:
- Před prvním spuštěním PC2.
- Před CORE history harvestem.
- Před PEOPLE history harvestem.
- Před media/asset harvestem.

NAVAZUJE NA:
- 23_3_D_create_harvest_master_plan_pc2_v1.sql
- 23_3_G_create_pc2_day1_execution_plan_v1.sql
- 23_3_I_create_pc2_phase2_people_execution_plan_v1.sql
- 23_3_N_create_provider_priority_matrix_v1.sql

DALŠÍ KROK:
- 23_3_P_create_pc2_go_live_summary_v1.sql
*/

DROP VIEW IF EXISTS ops.v_pc2_go_live_checklist_v1;

CREATE OR REPLACE VIEW ops.v_pc2_go_live_checklist_v1 AS

SELECT *
FROM (
VALUES
(1,'INFRA','PC2 hardware připravený','MANUAL_CHECK','PENDING','Ověřit CPU, RAM, SSD, síť a chlazení.'),
(2,'INFRA','Windows 11 Pro nainstalován','MANUAL_CHECK','PENDING','Ověřit systém a aktualizace.'),
(3,'INFRA','Git nainstalován','MANUAL_CHECK','PENDING','Ověřit git --version.'),
(4,'INFRA','Python 3.14 nainstalován','MANUAL_CHECK','PENDING','Ověřit C:\\Python314\\python.exe --version.'),
(5,'INFRA','VS Code nainstalován','MANUAL_CHECK','PENDING','Ověřit editor a terminál.'),
(6,'INFRA','DBeaver nainstalován','MANUAL_CHECK','PENDING','Ověřit připojení k PostgreSQL.'),

(7,'PROJECT','Repo MatchMatrix synchronizováno','MANUAL_CHECK','PENDING','Ověřit C:\\MatchMatrix-platform.'),
(8,'PROJECT','.env připraven pro PC2','MANUAL_CHECK','PENDING','Zkontrolovat DB_HOST, DB_PORT, API keys.'),
(9,'PROJECT','Python requirements nainstalované','MANUAL_CHECK','PENDING','Spustit pip install -r requirements.txt, pokud existuje.'),
(10,'PROJECT','Log složky existují','MANUAL_CHECK','PENDING','Ověřit logs, runtime_logs.'),

(11,'DB','PC2 má přístup k PostgreSQL','MANUAL_CHECK','PENDING','Ověřit připojení na DB z PC2.'),
(12,'DB','DB connection test prošel','MANUAL_CHECK','PENDING','Spustit jednoduchý SELECT now().'),
(13,'DB','Staging/public/ops schémata dostupná','SQL_CHECK','PENDING','Ověřit práva na schémata.'),
(14,'DB','Runtime logging funkční','SQL_CHECK','PENDING','Ověřit zápis do ops.runtime_execution_history.'),

(15,'OPS','Worker registry synchronizovaný','SQL_CHECK','DONE','provider_worker_registry doplněn z unified_worker_registry.'),
(16,'OPS','PC2 Phase 1 CORE queue připravená','SQL_CHECK','DONE','ops.v_pc2_phase1_core_harvest_queue_v1 hotovo.'),
(17,'OPS','PC2 Day 1 execution plan připravený','SQL_CHECK','DONE','ops.v_pc2_day1_execution_plan_v1 hotovo.'),
(18,'OPS','PC2 Phase 2 People queue připravená','SQL_CHECK','DONE','ops.v_pc2_phase2_people_harvest_queue_v1 hotovo.'),
(19,'OPS','Provider priority matrix připravená','SQL_CHECK','DONE','ops.v_provider_priority_matrix_v1 hotovo.'),

(20,'SAFETY','Lock systém ověřen','MANUAL_CHECK','PENDING','PC2 nesmí spustit stejné joby duplicitně.'),
(21,'SAFETY','Scheduler režim PC2 definován','MANUAL_CHECK','PENDING','Určit, zda PC2 pouze harvestuje nebo i scheduluje.'),
(22,'SAFETY','API limity ověřené','MANUAL_CHECK','PENDING','Ověřit FREE/PRO limity před velkým harvestem.'),
(23,'SAFETY','Backup strategie připravená','MANUAL_CHECK','PENDING','Před masivním harvestem udělat zálohu DB.'),

(24,'HARVEST','CORE history phase připravena','SQL_CHECK','DONE','36 READY úloh pro CORE historii.'),
(25,'HARVEST','PEOPLE history phase připravena','SQL_CHECK','DONE','FB/AFB READY, BK/CK review, další paid/blocked.'),
(26,'HARVEST','MEDIA phase připravena','SQL_CHECK','DONE','NHL/NBA READY, LaLiga/Bundesliga PARTIAL.'),
(27,'HARVEST','Media asset research připraven','SQL_CHECK','DONE','Player photos, team logos, coach/stadium photos prioritizované.'),

(28,'PROVIDER','API keys ověřené na PC2','MANUAL_CHECK','PENDING','Ověřit všechny .env klíče.'),
(29,'PROVIDER','Provider health před startem','SQL_CHECK','PENDING','Ověřit provider health těsně před spuštěním.'),
(30,'PROVIDER','Paid provider plán rozhodnutý','MANUAL_CHECK','PENDING','Rozhodnout PRO aktivaci a pořadí providerů.'),

(31,'PANEL','PC2 dashboard zdroje připravené','SQL_CHECK','DONE','Views 23_3_D až 23_3_N hotové.'),
(32,'PANEL','Panel napojen na PC2 views','PYTHON_PANEL','PENDING','Doplnit záložku PC2 Harvest Readiness do panelu.'),
(33,'PANEL','Akční tlačítka pouze funkční','PYTHON_PANEL','PENDING','Nepouštět neověřená tlačítka bez workeru/logu.')
) AS t(
    checklist_order,
    checklist_area,
    checklist_item,
    check_type,
    check_status,
    check_note
);