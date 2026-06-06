/*
===============================================================================
MATCHMATRIX SQL 116_J
PRO HARVEST READINESS TASKS V1
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
    'HARVEST_DB_READY',
    'DB připravená na hromadný harvest',
    'DATA',
    DATE '2026-06-08',
    'IN_PROGRESS',
    12,
    70,
    'Ověřit governance, master tabulky, staging flow, raw payload storage, indexy a storage limity.'
),
(
    'HARVEST_PROVIDER_ROUTING_READY',
    'Provider routing připravený na harvest',
    'PROVIDER',
    DATE '2026-06-09',
    'IN_PROGRESS',
    13,
    65,
    'Ověřit provider routing master, provider health, coverage, fallback a PRO limity.'
),
(
    'HARVEST_PEOPLE_READY',
    'People vrstva připravená na harvest',
    'PEOPLE',
    DATE '2026-06-15',
    'IN_PROGRESS',
    14,
    45,
    'Dotáhnout players, coaches, player profiles, season stats, match stats a people provider matrix.'
),
(
    'HARVEST_MEDIA_READY',
    'Media vrstva připravená na harvest',
    'MEDIA',
    DATE '2026-06-18',
    'IN_PROGRESS',
    15,
    55,
    'Dotáhnout media ingest, parsery, media merge, scoring, entity matcher a video feed přípravu.'
),
(
    'HARVEST_PANEL_READY',
    'OPS panel připravený na harvest',
    'PANEL',
    DATE '2026-06-20',
    'IN_PROGRESS',
    16,
    60,
    'Doplnit panel o harvest readiness, People readiness, Media readiness, roadmap a governance přehled.'
),
(
    'HARVEST_LOCKS_READY',
    'Lock systém připravený na více PC',
    'RUNTIME',
    DATE '2026-06-22',
    'PLANNED',
    17,
    0,
    'Ověřit worker locks, active runs, scheduler guard a ochranu proti duplicitnímu harvestu.'
),
(
    'HARVEST_DRY_RUN_READY',
    'Harvest dry-run připravený',
    'DATA',
    DATE '2026-06-25',
    'PLANNED',
    18,
    0,
    'Spustit testovací harvest přes planner a ověřit bezpečné zápisy do public/staging/ops.'
)

ON CONFLICT (milestone_code)
DO NOTHING;