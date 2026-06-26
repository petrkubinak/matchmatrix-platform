/*
MATCHMATRIX SQL 118_C
CREATE PROJECT ROADMAP MILESTONES V1

CO TO JE:
- Vytvoří hlavní roadmapu projektu MatchMatrix.

K ČEMU TO JE:
- Aby V18 panel ukazoval milníky projektu, stav přípravy a další cíle.

KDE TO UVIDÍME:
- OPS Panel V18 -> Project Roadmap
- OPS Panel V18 -> Launch Progress
- OPS Panel V18 -> Harvest Command Center

JAK SE TO VYUŽIJE:
- Panel bude zobrazovat, co je hotovo, co běží, co je plánované a co blokuje release.
*/

CREATE TABLE IF NOT EXISTS ops.project_roadmap_milestones_v1 (
    id BIGSERIAL PRIMARY KEY,
    milestone_order INTEGER NOT NULL,
    milestone_code TEXT NOT NULL UNIQUE,
    milestone_name TEXT NOT NULL,
    milestone_area TEXT NOT NULL,
    target_date DATE,
    progress_percent NUMERIC(5,2) NOT NULL DEFAULT 0,
    milestone_status TEXT NOT NULL DEFAULT 'PLANNED',
    what_is_it TEXT,
    purpose TEXT,
    blocking_issue TEXT,
    next_action TEXT,
    panel_usage TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO ops.project_roadmap_milestones_v1 (
    milestone_order,
    milestone_code,
    milestone_name,
    milestone_area,
    target_date,
    progress_percent,
    milestone_status,
    what_is_it,
    purpose,
    blocking_issue,
    next_action,
    panel_usage
)
VALUES
(1, 'GOVERNANCE_DONE', 'Database Governance Completed', 'GOVERNANCE', '2026-06-06', 100.00, 'DONE',
 'Kompletní audit databázových objektů.',
 'Určit MASTER, ACTIVE, PANEL, REVIEW, LEGACY a DROP objekty.',
 NULL,
 'Používat governance jako hlavní pravdu pro V18.',
 'Governance Dashboard'),

(2, 'ARCHITECTURE_MAP_DONE', 'Master Architecture Map', 'ARCHITECTURE', '2026-06-06', 100.00, 'DONE',
 'Databázová mapa všech vrstev MatchMatrix.',
 'Dát panelu i dokumentaci jednu architekturu.',
 NULL,
 'Napojit na V18 Architecture tab.',
 'Architecture Dashboard'),

(3, 'LAYER_READINESS_DONE', 'Layer Readiness Dashboard', 'READINESS', '2026-06-06', 100.00, 'DONE',
 'Readiness procenta po hlavních vrstvách.',
 'Ukázat slabé a silné části projektu.',
 NULL,
 'Později nahradit ruční baseline automatickým výpočtem.',
 'Harvest Command Center'),

(4, 'V18_MASTER_PANEL', 'V18 Master OPS Panel', 'PANEL', '2026-06-15', 35.00, 'IN_PROGRESS',
 'Nový hlavní panel nad ACTIVE_MASTER a ACTIVE_PANEL objekty.',
 'Nahradit staré panelové vazby a sjednotit řízení projektu.',
 'Ještě není napojený celý Harvest, People, Media, Odds a Roadmap modul.',
 'Postavit V18 nad master view a readiness tabulkami.',
 'V18 Panel'),

(5, 'THEODDS_COMMAND_CENTER', 'TheOdds Command Center Migration', 'ODDS', '2026-06-18', 20.00, 'PLANNED',
 'Přenos TheOdds funkcí ze starého V11 panelu.',
 'Zobrazit odds health, coverage, matching a run status.',
 'TheOdds část zatím není ve V18.',
 'Vytvořit V18 modul pro Odds Command Center.',
 'Odds Command Center'),

(6, 'PEOPLE_EXPANSION', 'People Layer Expansion', 'PEOPLE', '2026-06-30', 75.00, 'IN_PROGRESS',
 'Rozšíření hráčů, profilů, statistik, trenérů a fotek.',
 'Dostat people vrstvu pro hlavní sporty do produkční úrovně.',
 'Chybí profily, coaches, fotky a širší stats u více sportů.',
 'Priorita FB, HK, BK, potom další sporty.',
 'People Command Center'),

(7, 'MEDIA_EXPANSION', 'Media Layer Expansion', 'MEDIA', '2026-06-30', 75.00, 'IN_PROGRESS',
 'Rozšíření článků, videí, highlights a linkování.',
 'Zvýšit hodnotu webu a engagement uživatelů.',
 'Chybí širší video/highlights a hlubší entity linking.',
 'Doplnit Media Command Center a další zdroje.',
 'Media Command Center'),

(8, 'PRO_HARVEST_READY', 'PRO Harvest Ready', 'HARVEST', '2026-07-01', 65.00, 'IN_PROGRESS',
 'Připravenost na placený provider režim a masivní harvest.',
 'Využít vyšší API limity pro historický backfill.',
 'Ještě chybí finální V18 řízení, locks testy a second PC příprava.',
 'Dokončit harvest readiness engine.',
 'Harvest Command Center'),

(9, 'SECOND_PC_READY', 'Second PC Harvest Server Ready', 'INFRA', '2026-07-15', 30.00, 'PLANNED',
 'Druhý výkonný počítač pro masivní harvest.',
 'Oddělit těžké batch workery od hlavního PC.',
 'Chybí fyzické zapojení, Git sync, .env, DB test a lock test.',
 'Připravit second PC checklist.',
 'Second PC / Harvest'),

(10, 'MASSIVE_BACKFILL_START', 'Massive Historical Backfill Start', 'HARVEST', '2026-07-20', 20.00, 'PLANNED',
 'Start velkého historického stahování napříč sporty.',
 'Naplnit databázi miliony záznamů pro ratingy, predikce a web.',
 'Čeká se na PRO režim, V18 řízení a second PC.',
 'Spustit řízený harvest přes planner a scheduler.',
 'Harvest Progress'),

(11, 'WEB_V1_BUILD', 'Web V1 Build', 'WEB', '2026-08-31', 20.00, 'PLANNED',
 'První použitelná verze webu pro uživatele.',
 'Zobrazit data, týmy, hráče, zápasy, predikce a tikety.',
 'Chybí login, registrace, předplatné, UI moduly a admin.',
 'Po V18 začít systematicky stavět Web V1.',
 'Launch Progress'),

(12, 'WEB_BETA', 'Web Beta', 'WEB', '2026-09-30', 10.00, 'PLANNED',
 'Interní beta webu.',
 'Ověřit reálné použití platformy.',
 'Závisí na Web V1 a datech.',
 'Připravit beta checklist.',
 'Launch Progress'),

(13, 'PUBLIC_BETA', 'Public Beta', 'RELEASE', '2026-11-30', 0.00, 'PLANNED',
 'Veřejná beta pro první uživatele.',
 'Ověřit produkt mimo interní prostředí.',
 'Závisí na webu, datech, platbách a provozní stabilitě.',
 'Připravit release checklist.',
 'Project Roadmap'),

(14, 'FIRST_PAYING_USERS', 'First Paying Users', 'BUSINESS', '2026-12-31', 0.00, 'PLANNED',
 'První platící uživatelé MatchMatrix.',
 'Ověřit obchodní model.',
 'Závisí na webu, Stripe, obsahu, predikcích a důvěře uživatelů.',
 'Připravit pricing, subscription a launch plán.',
 'Launch Progress')
ON CONFLICT (milestone_code) DO UPDATE SET
    milestone_order = EXCLUDED.milestone_order,
    milestone_name = EXCLUDED.milestone_name,
    milestone_area = EXCLUDED.milestone_area,
    target_date = EXCLUDED.target_date,
    progress_percent = EXCLUDED.progress_percent,
    milestone_status = EXCLUDED.milestone_status,
    what_is_it = EXCLUDED.what_is_it,
    purpose = EXCLUDED.purpose,
    blocking_issue = EXCLUDED.blocking_issue,
    next_action = EXCLUDED.next_action,
    panel_usage = EXCLUDED.panel_usage,
    updated_at = now();

CREATE OR REPLACE VIEW ops.v_project_roadmap_milestones_v1 AS
SELECT
    milestone_order,
    milestone_code,
    milestone_name,
    milestone_area,
    target_date,
    progress_percent,
    milestone_status,
    CASE
        WHEN milestone_status = 'DONE' THEN 'GREEN'
        WHEN milestone_status = 'IN_PROGRESS' THEN 'YELLOW'
        WHEN milestone_status = 'PLANNED' THEN 'BLUE'
        WHEN milestone_status = 'BLOCKED' THEN 'RED'
        ELSE 'GRAY'
    END AS milestone_color,
    what_is_it,
    purpose,
    blocking_issue,
    next_action,
    panel_usage,
    updated_at
FROM ops.project_roadmap_milestones_v1
ORDER BY milestone_order;

CREATE OR REPLACE VIEW ops.v_project_roadmap_summary_v1 AS
SELECT
    COUNT(*) AS total_milestones,
    COUNT(*) FILTER (WHERE milestone_status = 'DONE') AS done_milestones,
    COUNT(*) FILTER (WHERE milestone_status = 'IN_PROGRESS') AS in_progress_milestones,
    COUNT(*) FILTER (WHERE milestone_status = 'PLANNED') AS planned_milestones,
    COUNT(*) FILTER (WHERE milestone_status = 'BLOCKED') AS blocked_milestones,
    ROUND(AVG(progress_percent), 2) AS avg_progress_percent,
    MIN(target_date) FILTER (WHERE milestone_status <> 'DONE') AS next_target_date
FROM ops.project_roadmap_milestones_v1;

SELECT * FROM ops.v_project_roadmap_milestones_v1;

SELECT * FROM ops.v_project_roadmap_summary_v1;