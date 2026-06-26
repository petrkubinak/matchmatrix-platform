/*
===============================================================================
MATCHMATRIX SQL 116_C
SEED PROJECT MILESTONES V1

CO TO JE:
- První roadmapa projektu MatchMatrix.

K ČEMU TO JE:
- Centrální řízení projektu.
- Přehled strategických cílů.
- Vstup pro OPS dashboard, Mission Control a budoucí admin web.
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
    'GOVERNANCE_COMPLETE',
    'Governance Audit Complete',
    'PROJECT',
    DATE '2026-06-03',
    'DONE',
    1,
    100,
    'OPS, PUBLIC, STAGING, WORKERS, INGEST a PROJECT governance dokončeny.'
),

(
    'SECOND_PC_READY',
    'Second Harvest Server Ready',
    'INFRASTRUCTURE',
    DATE '2026-06-15',
    'PLANNED',
    2,
    0,
    'Nákup a konfigurace druhého výkonného PC pro harvest dat.'
),

(
    'FOOTBALL_100',
    'Football Layer Completion',
    'FOOTBALL',
    DATE '2026-06-30',
    'IN_PROGRESS',
    3,
    90,
    'Dokončení football people, coaches, statistics a PRO readiness.'
),

(
    'HK_BK_READY',
    'Hockey and Basketball Ready',
    'MULTISPORT',
    DATE '2026-06-30',
    'IN_PROGRESS',
    4,
    75,
    'Dokončení hlavních vrstev HK a BK.'
),

(
    'PRO_HARVEST_READY',
    'PRO Harvest Preparation Complete',
    'INFRASTRUCTURE',
    DATE '2026-06-30',
    'PLANNED',
    5,
    0,
    'Vše připraveno pro spuštění PRO harvestu.'
),

(
    'MASSIVE_BACKFILL_START',
    'Massive Historical Backfill Start',
    'DATA',
    DATE '2026-07-01',
    'PLANNED',
    6,
    0,
    'Masivní stahování historických dat všech hlavních sportů.'
),

(
    'PEOPLE_EXPANSION',
    'People Layer Expansion',
    'PEOPLE',
    DATE '2026-07-31',
    'PLANNED',
    7,
    0,
    'Rozšíření People vrstvy na další sporty.'
),

(
    'MEDIA_EXPANSION',
    'Media Layer Expansion',
    'MEDIA',
    DATE '2026-08-15',
    'PLANNED',
    8,
    0,
    'Video feedy, highlights, rozšíření zdrojů a trendů.'
),

(
    'WEB_BETA',
    'Internal Web Beta',
    'WEB',
    DATE '2026-09-01',
    'PLANNED',
    9,
    0,
    'Interní beta verze MatchMatrix webu.'
),

(
    'PUBLIC_BETA',
    'Public Beta Launch',
    'WEB',
    DATE '2026-10-01',
    'PLANNED',
    10,
    0,
    'Veřejná beta verze systému.'
),

(
    'FIRST_PAYING_USERS',
    'First Paying Users',
    'BUSINESS',
    DATE '2026-11-01',
    'PLANNED',
    11,
    0,
    'První platící uživatelé MatchMatrix.'
)

ON CONFLICT (milestone_code)
DO NOTHING;